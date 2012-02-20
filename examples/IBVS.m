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

classdef IBVS < VisualServo

    properties
        lambda          % IBVS gain
        eterm
        uv_p            % previous image coordinates

        depth
        depthest
        vel_p
        theta
        smoothing
    end

    methods

        function ibvs = IBVS(cam, varargin)

            % invoke superclass constructor
            ibvs = ibvs@VisualServo(cam, varargin{:});

            % handle arguments
            opt.eterm = 0.5;
            opt.lambda = 0.08;         % control gain
            opt.depth = [];
            opt.depthest = false;
            
            opt = tb_optparse(opt, ibvs.arglist);

            % copy options to IBVS object
            ibvs.lambda = opt.lambda;
            ibvs.eterm = opt.eterm;
            ibvs.theta = 0;
            ibvs.smoothing = 0.80;
            ibvs.depth = opt.depth;
            ibvs.depthest = opt.depthest;

        end

        function init(vs)

            if ~isempty(vs.pf)
                % final pose is specified in terms of image coords
                vs.uv_star = vs.pf;
            else
                if ~isempty(vs.Tf)
                    vs.Tf = transl(0, 0, 1);
                    warning('setting Tf to default');
                end
                % final pose is specified in terms of a camera-target pose
                %   convert to image coords
                vs.uv_star = vs.camera.project(vs.P, 'Tcam', inv(vs.Tf));
            end

            %% initialize the vservo variables
            vs.camera.T = vs.T0;    % set camera back to its initial pose
            vs.Tcam = vs.T0;                % initial camera/robot pose
            
            % show the reference location, this is the view we wish to achieve
            % when Tc = Tct_star
            if 0
            vs.camera.clf()
            vs.camera.plot(vs.uv_star, '*'); % create the camera view
            vs.camera.hold(true);
            vs.camera.plot(vs.P, 'Tcam', vs.T0, 'o'); % create the camera view
            pause(2)
            vs.camera.hold(false);
            vs.camera.clf();
            end

            vs.camera.plot(vs.P);    % show initial view

            % this is the 'external' view of the points and the camera
            %plot_sphere(vs.P, 0.05, 'b')
            %cam2 = showcamera(T0);
            vs.camera.plot_camera(vs.P, 'label');
            %camup([0,-1,0]);

            vs.vel_p = [];
            vs.uv_p = [];
            vs.history = [];
        end

        function status = step(vs)
            status = 0;
            Zest = [];
            
            % compute the view
            uv = vs.camera.plot(vs.P);

            % optionally estimate depth
            if vs.depthest
                % run the depth estimator
                [Zest,Ztrue] = vs.depth_estimator(uv);
                Zest
                Ztrue
                vs.depth = Zest;
                hist.Ztrue = Ztrue(:);
                hist.Zest = Zest(:);
            end

            % compute image plane error as a column
            e = uv - vs.uv_star;   % feature error
            e = e(:);
        
            
            % compute the Jacobian
            if isempty(vs.depth)
                % exact depth from simulation (not possible in practice)
                pt = homtrans(inv(vs.Tcam), vs.P);
                J = vs.camera.visjac_p(uv, pt(3,:) );
            elseif ~isempty(Zest)
                J = vs.camera.visjac_p(uv, Zest);
            else
                J = vs.camera.visjac_p(uv, vs.depth );
            end

            % compute the velocity of camera in camera frame
            try
                v = -vs.lambda * pinv(J) * e;
            catch
                status = -1;
                return
            end

            if vs.verbose
                fprintf('v: %.3f %.3f %.3f %.3f %.3f %.3f\n', v);
            end

            v'
            % update the camera pose
            Td = trnorm(delta2tr(v));    % differential motion

            vs.Tcam = vs.Tcam * Td;       % apply it to current pose
            vs.Tcam = trnorm(vs.Tcam);

            % update the camera pose
            vs.camera.T = vs.Tcam;

            % update the history variables
            hist.uv = uv(:);
            vel = tr2delta(Td);
            hist.vel = vel;
            hist.e = e;
            hist.en = norm(e);
            hist.jcond = cond(J);
            hist.Tcam = vs.Tcam;

            vs.history = [vs.history hist];

            vs.vel_p = vel;
            vs.uv_p = uv;

            if norm(e) < vs.eterm,
                status = 1;
                return
            end
        end

        function [Zest,Ztrue] = depth_estimator(vs, uv)
            if isempty(vs.uv_p)
                Zest = [];
                Ztrue = [];
                return;
            end

            % compute Jacobian for unit depth, z=1
            J = vs.camera.visjac_p(uv, 1);
            Jv = J(:,1:3);  % velocity part, depends on 1/z
            Jw = J(:,4:6);  % rotational part, indepedent of 1/z

            % estimate image plane velocity
            uv_d =  uv(:) - vs.uv_p(:);
            
            % estimate coefficients for A (1/z) = B
            B = uv_d - Jw*vs.vel_p(4:6);
            A = Jv * vs.vel_p(1:3);

            AA = zeros(numcols(uv), numcols(uv)/2);
            for i=1:numcols(uv)
                AA(i*2-1:i*2,i) = A(i*2-1:i*2);
            end
            eta = AA\B;          % least squares solution
            1./eta'

            eta2 = A(1:2) \ B(1:2);
            1/eta2

            % first order smoothing
            vs.theta = (1-vs.smoothing) * 1./eta' + vs.smoothing * vs.theta;
            Zest = vs.theta;

            % true depth
            P_CT = homtrans(inv(vs.Tcam), vs.P);
            Ztrue = P_CT(3,:);

            if vs.verbose
                fprintf('depth %.4g, est depth %.4g, rls depth %.4g\n', ...
                    Ztrue, 1/eta, Zest);
            end
        end
    end % methods
end % class
