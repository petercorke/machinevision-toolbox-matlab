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

classdef IBVS_l < VisualServo

    properties
        lambda          % IBVS gain
        eterm

        tr_star         % desired theta-rho coordinates
        tr_star_plot
        planes
    end

    methods

        function ibvs = IBVS_l(cam, varargin)

            % invoke superclass constructor
            ibvs = ibvs@VisualServo(cam, varargin{:});

            % handle arguments
            opt.eterm = 0.01;
            opt.planes = [];
            opt.lambda = 0.08;         % control gain
            opt.example = false;
            
            opt = tb_optparse(opt, ibvs.arglist);

            if opt.example
                % run a canned example
                fprintf('----------------------------\n');
                fprintf('canned example, line-based IBVS with three lines\n');
                fprintf('----------------------------\n');
                ibvs.planes = repmat([0 0 1 -3]', 1, 3);
                ibvs.P = circle([0 0 3], 1, 'n', 3);
                ibvs.T0 = transl(1,1,-3)*trotz(0.6);
            else
                ibvs.planes = opt.planes;
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
            vs.tr_star = vs.getlines(vs.Tf, inv(vs.camera.K));
            vs.tr_star_plot = vs.getlines(vs.Tf);

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

        function lines = getlines(vs, T, scale)
            p = vs.camera.project(vs.P, 'Tcam', T);
            if nargin > 2
                p = transformp(scale, p);
            end
            for i=1:numcols(p)
                j = mod(i,numcols(p))+1;
                theta = atan2(p(2,j)-p(2,i), p(1,i)-p(1,j));
                rho = sin(theta)*p(1,i) + cos(theta)*p(2,i);
                lines(1,i) = theta; lines(2,i) = rho;
            end
        end

        function status = step(vs)
            status = 0;
            Zest = [];
            
            % compute the view
            vs.camera.clf();
            uv = vs.camera.project(vs.P);
            tr = vs.getlines(vs.Tcam);
            vs.camera.hold(true);
            vs.camera.plot_line_tr(tr);
            vs.camera.plot_line_tr(vs.tr_star_plot, 'r--');

            tr = vs.getlines(vs.Tcam, inv(vs.camera.K));

            % compute image plane error as a column
            e = tr - vs.tr_star;   % feature error
            e = e(:);
            for i=1:2:numrows(e)
                if e(i) > pi
                    e(i) = e(i) - 2*pi;
                elseif e(i) < -pi
                    e(i) = e(i) + 2*pi;
                end
            end
        
            tr
            vs.tr_star

            J = vs.camera.visjac_l(tr, vs.planes);

            % compute the velocity of camera in camera frame
            v = -vs.lambda * pinv(J) * e;
            if vs.verbose
                fprintf('v: %.3f %.3f %.3f %.3f %.3f %.3f\n', v);
            end

            % update the camera pose
            Td = delta2tr(v);    % differential motion

            vs.Tcam = vs.Tcam * Td;       % apply it to current pose
            vs.Tcam = trnorm(vs.Tcam);

            % update the camera pose
            vs.camera.T = vs.Tcam;

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
