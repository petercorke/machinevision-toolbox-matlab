%IBVS   Implement classical IBVS for point features
%
%  results = ibvs(T)
%  results = ibvs(T, params)
%
%  Simulate IBVS with for a square target comprising 4 points is placed 
%  in the world XY plane. The camera/robot is initially at pose T and is
%  driven to the orgin.
%
%  Two windows are shown and animated:
%   1. The camera view, showing the desired view (*) and the 
%      current view (o)
%   2. The external view, showing the target points and the camera
%
% The results structure contains time-history information about the image
% plane, camera pose, error, Jacobian condition number, error norm, image
% plane size and desired feature locations.
%
% The params structure can be used to override simulation defaults by
% providing elements, defaults in parentheses:
%
%   target_size    - the side length of the target in world units (0.5)
%   target_center  - center of the target in world coords (0,0,3)
%   niter          - the number of iterations to run the simulation (500)
%   eterm          - a stopping criteria on feature error norm (0)
%   lambda         - gain, can be scalar or diagonal 6x6 matrix (0.01)
%   ci             - camera intrinsic structure (camparam)
%   depth          - depth of points to use for Jacobian, scalar for
%                    all points, of 4-vector.  If null take actual value
%                    from simulation      ([])
%
% SEE ALSO: ibvsplot

% IMPLEMENTATION NOTE
%
% 1.  As per task function notation (Chaumette papers) the error is
%     defined as actual-demand, the reverse of normal control system
%     notation.
% 2.  The gain, lambda, is always positive
% 3.  The negative sign is written into the control law

classdef IBVS_e < VisualServo

    properties
        lambda          % IBVS gain
        eterm

        E
        E_star
        plane
    end

    methods

        function ibvs = IBVS_e(cam, varargin)

            % invoke superclass constructor
            ibvs = ibvs@VisualServo(cam, varargin{:});

            % handle arguments
            opt.eterm = 0;
            opt.plane = [];
            opt.lambda = 0.04;         % control gain
            opt.example = false;
            
            opt = tb_optparse(opt, ibvs.arglist);

            if opt.example
                % run a canned example
                fprintf('---------------------------------------------------\n');
                fprintf('canned example, ellipse-based IBVS with 10 points\n');
                fprintf('---------------------------------------------------\n');
                ibvs.P = circle([0 0 3], 0.5, 'n', 10);
                ibvs.Tf = transl(0.5, 0.5, 1);
                ibvs.T0 = transl(0.5, 0.5, 0)*trotx(0.3);
                %ibvs.T0 = transl(-1,-0.1,-3);%*trotx(0.2);
                ibvs.plane = [0 0 1 -3];    % in plane z=3
            else
                ibvs.plane = opt.plane;
            end

            % copy options to IBVS object
            ibvs.lambda = opt.lambda;
            ibvs.eterm = opt.eterm;
        end

        function init(vs)

            if isempty(vs.Tf)
                vs.Tf = transl(0, 0, 1);
                warning('setting Tf to default');
            end

            % final pose is specified in terms of a camera-target pose
            %   convert to image coords
            vs.E_star = vs.getfeatures(vs.Tf);
            vs.uv_star = vs.camera.project(vs.P, 'Tcam', vs.Tf);

            %% initialize the vservo variables
            vs.camera.T = vs.T0;    % set camera back to its initial pose
            vs.Tcam = vs.T0;                % initial camera/robot pose
            
            vs.camera.plot(vs.P);    % show initial view

            % this is the 'external' view of the points and the camera
            %plot_sphere(vs.P, 0.05, 'b')
            %cam2 = showcamera(T0);
            vs.camera.visualize(vs.P, 'label');
            %camup([0,-1,0]);

            vs.history = [];
        end

        function A = getfeatures(vs, T)
            p = vs.camera.project(vs.P, 'Tcam', T);

            % convert to normalized image-plane coordinates
            p = homtrans(inv(vs.camera.K), p);
            x = p(1,:);
            y = p(2,:);

            % solve for the ellipse parameters
            % x^2 + A1 y^2 - 2 A2 xy + 2 A3 x + 2 A4 y + A5 = 0
            a = [y.^2; -2*x.*y; 2*x; 2*y; ones(1,numcols(x))]';
            b = -(x.^2)';
            A = a\b;
        end

        function status = step(vs)
            status = 0;
            Zest = [];
            
            % compute the view
            vs.camera.clf();
            uv = vs.camera.plot(vs.P);
            vs.camera.hold(true);
            vs.camera.plot(vs.uv_star, '*');

            E = vs.getfeatures(vs.Tcam);

            % compute image plane error as a column
            e = E - vs.E_star;   % feature error
            e = [e; uv(:,1) - vs.uv_star(:,1)];
        
            J = vs.camera.visjac_e(E, vs.plane);

            J = [J; vs.camera.visjac_p(uv(:,1), -vs.plane(4))];

            % compute the velocity of camera in camera frame
            v = -vs.lambda * pinv(J) * e;
            %v = v.*[1 -1 1 0 0 0]';

            % update the camera pose
            Td = delta2tr(v);    % differential motion

            vs.Tcam = vs.Tcam * Td;       % apply it to current pose
            vs.Tcam = trnorm(vs.Tcam);

            % update the camera pose
            vs.camera.T = vs.Tcam;

            if vs.verbose
                fprintf('cond: %g\n', cond(J));
                fprintf('v: %.3f %.3f %.3f %.3f %.3f %.3f\n', v);
                trprint(vs.Tcam);
                fprintf('\n');
            end

            % update the history variables
            hist.uv = uv(:);
            vel = tr2diff(Td);
            hist.vel = vel;
            hist.e = e;
            hist.en = norm(e);
            hist.jcond = cond(J);
            hist.Tcam = vs.Tcam;

            vs.history = [vs.history hist];

            if norm(e) < vs.eterm,
                status = 1;
                return
            end
        end
    end % methods
end % class
