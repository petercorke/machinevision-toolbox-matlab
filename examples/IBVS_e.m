%IBVS_e   Implement classical IBVS for ellipse features
%
% A concrete class for simulation of image-based visual servoing (IBVS) with 
% ellipse features, a subclass of VisualServo.  Two windows are shown and
% animated:
%   - The camera view, showing the desired view and the 
%     current view
%   - The external view, showing the target points and the camera
%
% Methods::
% run            Run the simulation, complete results kept in the object
% plot_p         Plot image plane coordinates of points vs time
% plot_vel       Plot camera velocity vs time
% plot_camera    Plot camera pose vs time
% plot_jcond     Plot Jacobian condition vs time 
% plot_z         Plot point depth vs time
% plot_error     Plot feature error vs time
% plot_all       Plot all of the above in separate figures
% char           Convert object to a concise string
% display        Display the object as a string
%
% Example::
%         cam = CentralCamera('default');    
%         ibvs = IBVS_e(cam, 'example'); 
%         ibvs.run()
%
% You can change various properties of the ibvs object (initial/final pose,
% error tolerance etc. and rerun the simulation using the run() method.
%
% References::
% - Robotics, Vision & Control, Chap 15
%   P. Corke, Springer 2011.
%
% Notes::
% - The history property is a vector of structures each of which is a snapshot at
%   each simulation step of information about the image plane, camera pose, error, 
%   Jacobian condition number, error norm, image plane size and desired feature 
%   locations.
% - We approximate the ellipse by a number of points on a circle in the
% world and fit an ellipse to the projection of the points.
%
% See also VisualServo, PBVS, IBVS_l, IBVS_e.

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
        f_star
        plane
        ellipse_star
    end

    methods

        function ibvs = IBVS_e(cam, varargin)
            %IBVS_e.IBVS_e Create IBVS visual servo object
            %
            % IB = IBVS_e(camera, options)
            %
            % Options::
            % 'example'         Use set of canned parameters
            % 'niter',N         Maximum number of iterations
            % 'eterm',E         Terminate when norm of feature error < E
            % 'lambda',L        Control gain, positive definite scalar or matrix
            % 'T0',T            The initial camera pose
            % 'Tf',T            The final camera pose used only to determine desired
            %                   image plane coordinates (default 1m in z-direction)
            % 'P',p             The set of world points (3xN)
            % 'plane',P         The world plane holding the ellipse (4x1)
            % 'fps',F           Number of simulation frames per second (default t)
            % 'verbose'         Print out extra information during simulation
            %
            % Notes::
            % - If 'P' is specified it should define a set of points lying
            %   on a 3D world plane.
            %
            % See also VisualServo.
            
            % invoke superclass constructor
            ibvs = ibvs@VisualServo(cam, varargin{:});

            % handle arguments
            opt.eterm = 0.08;
            opt.plane = [];
            opt.lambda = 0.04;         % control gain
            opt.example = false;
            
            opt = tb_optparse(opt, ibvs.arglist);

            if opt.example
                % run a canned example
                fprintf('---------------------------------------------------\n');
                fprintf('canned example, ellipse + point-based IBVS\n');
                fprintf('---------------------------------------------------\n');
                ibvs.P = circle([0 0 3], 0.5, 'n', 40);
                ibvs.Tf = transl(0.5, 0.5, 1);
                ibvs.T0 = transl(0.5, 0.5, 0)*trotx(0.3);
                %ibvs.T0 = transl(-1,-0.1,-3);%*trotx(0.2);
                ibvs.plane = [0 0 1 -3];    % in plane z=3
            end
            
                ibvs.plane = opt.plane;
            

            % copy options to IBVS object
            ibvs.lambda = opt.lambda;
            ibvs.eterm = opt.eterm;
            
            clf
            subplot(121);
            ibvs.camera.plot_create(gca)
            
            % this is the 'external' view of the points and the camera
            subplot(122)
            PP = [ibvs.P ibvs.P(:,1)];
            plot3(PP(1,:), PP(2,:), PP(3,:), 'r', 'LineWidth', 5)
            plot_sphere(PP(:,1), 0.06, 'b');
            ibvs.camera.plot_camera();
            plotvol([-1 1 -1 1 -1 3.1])
            view(16, 28);
            grid on
            set(gcf, 'Color', 'w')
            
            set(gcf, 'HandleVisibility', 'Off');
            
            ibvs.type = 'ellipse';
        end

        function init(vs)
            %IBVS_e.init Initialize simulation
            %
            % IB.init() initializes the simulation.  Implicitly called by
            % IB.run().
            %
            % See also VisualServo, IBVS_e.run.

            if isempty(vs.Tf)
                vs.Tf = transl(0, 0, 1);
                warning('setting Tf to default');
            end

            % desired feature coordinates.  This vector comprises the ellipse
            % parameters (5) and the coordinaes of 1 point
            vs.f_star = [
                    vs.get_ellipse_parameters(vs.Tf)
                    vs.camera.project(vs.P(:,1), 'pose', vs.Tf)
                ];
            
            vs.ellipse_star = vs.camera.project([vs.P vs.P(:,1)], 'pose', vs.Tf);

            % initialize the vservo variables
            vs.camera.T = vs.T0;    % set camera back to its initial pose
            vs.Tcam = vs.T0;                % initial camera/robot pose
            
            vs.history = [];
            
        end

        function A = get_ellipse_parameters(vs, T)
            p = vs.camera.project(vs.P, 'pose', T);

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
            %IBVS_e.step Simulate one time step
            %
            % STAT = IB.step() performs one simulation time step of IBVS.  It is
            % called implicitly from the superclass run method.  STAT is
            % one if the termination condition is met, else zero.
            %
            % See also VisualServo, IBVS_e.run.
            
            status = 0;
            Zest = [];
            
            % plot the ellipse
            vs.camera.clf();
            vs.camera.hold(true);
            vs.camera.plot([vs.P vs.P(:,1)], 'pose', vs.Tcam, 'r-', 'LineWidth', 2);
            vs.camera.plot(vs.P(:,1), 'pose', vs.Tcam, 'bo', 'MarkerFaceColor', 'b');
            vs.camera.plot(vs.ellipse_star, 'r--', 'LineWidth', 2);
            vs.camera.plot(vs.P(:,1), 'pose', vs.Tf, 'bo');

            % compute feature vector
            f = [
                    vs.get_ellipse_parameters(vs.Tcam)
                    vs.camera.project(vs.P(:,1), 'pose', vs.Tcam)
                ];
            
            % compute image plane error as a column
            e = f - vs.f_star;   % feature error
            
            % compute the Jacobians and stack them
            Je = vs.camera.visjac_e(f(1:5), vs.plane);  % ellipse
            Jp = vs.camera.visjac_p(f(6:7), -vs.plane(4)); % point

            J = [Je; Jp];

            % compute the velocity of camera in camera frame
            v = -vs.lambda * pinv(J) * e;

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
            hist.f = f';
            vel = tr2delta(Td);
            hist.vel = vel;
            hist.e = e;
            hist.en = norm(e);
            hist.jcond = cond(J);
            hist.Tcam = vs.Tcam;

            vs.history = [vs.history hist];
            
            if norm(e) < vs.eterm
                status = 1;

                return
            end
        end
    end % methods
end % class
