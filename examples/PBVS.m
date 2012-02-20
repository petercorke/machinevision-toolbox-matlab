%PBVS   Implement classical PBVS for point features
%
%  results = pbvs(T)
%  results = pbvs(T, params)
%
%  Simulate PBVS with for a square target comprising 4 points is placed 
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

% IMPLEMENTATION NOTE
%
% 1.  The gain, lambda, is always positive


classdef PBVS < VisualServo

    properties
        lambda          % PBVS gain
        eterm
    end

    methods

        function pbvs = PBVS(cam, varargin)

            % invoke superclass constructor
            pbvs = pbvs@VisualServo(cam, varargin{:});

            % handle arguments
            opt.targetsize = 0.5;       % dimensions of target
            opt.eterm = 0;
            opt.lambda = 0.05;         % control gain

            opt = tb_optparse(opt, pbvs.arglist);

            if isempty(pbvs.Tf)
                pbvs.Tf = transl(0, 0, 1);
                warning('setting Tf to default');
            end

            % copy options to PBVS object
            pbvs.lambda = opt.lambda;
            pbvs.eterm = opt.eterm;
            if isempty(pbvs.niter)
                pbvs.niter = 200;
            end

        end

        function init(vs)

            %% initialize the vservo variables
            %vs.camera.clf();
            vs.camera.T = vs.T0;    % set camera back to its initial pose
            vs.Tcam = vs.T0;        % initial camera/robot pose
            
            % show the reference location, this is the view we wish to achieve
            % when Tc = T_final
            uv_star = vs.camera.project(vs.P, 'Tcam', inv(vs.Tf));    % create the camera view
            %hold on
            %plot(uv_star(:,1), uv_star(:,2), '*');      % show desired view
            %hold off
            vs.camera.plot(vs.P);    % show initial view
            pause(1)

            % this is the 'external' view of the points and the camera
            %plot_sphere(vs.P, 0.05, 'b')
            %cam2 = showcamera(T0);
            vs.camera.plot_camera(vs.P, 'label');
            %camup([0,-1,0]);

            vs.history = [];
        end

        function status = step(vs)
            status = 0;

            
            % compute the view
            uv = vs.camera.plot(vs.P);

            Tct_est = vs.camera.estpose(vs.P, uv);
            delta =  Tct_est * inv(vs.Tf);
           
            % update the camera pose
            Td = trinterp(delta, vs.lambda);

            vs.Tcam = vs.Tcam * Td;       % apply it to current pose

            % update the camera pose
            vs.camera.T = vs.Tcam;

            % update the history variables
            hist.uv = uv(:);
            vel = tr2delta(Td);
            hist.vel = vel;
            hist.Tcam = vs.Tcam;

            vs.history = [vs.history hist];
            
            if norm(vel) < vs.eterm,
                status = 1;
            end
        end
    end % methods
end % class
