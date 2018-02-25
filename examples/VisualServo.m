%VisualServo  Abstract class for visual servoing
%
% VisualServo(CAMERA, OPTIONS) 
%
% Methods::
% run            Run the simulation, complete results kept in the object
% step           One simulation step (provided by the concrete class)
% init           Initialized the simulation (provided by the concrete class)
% plot_p         Plot feature values vs time
% plot_vel       Plot camera velocity vs time
% plot_camera    Plot camera pose vs time
% plot_jcond     Plot Jacobian condition vs time 
% plot_z         Plot point depth vs time
% plot_error     Plot feature error vs time
% plot_all       Plot all of the above in separate figures
% char           Convert object to a concise string
% display        Display the object as a string
%
% Properties::
% history     A vector of structs holding simulation results
%
% Notes::
% - Must be subclassed.
%
% See also PBVS, IBVS, IBVS_l, IBVS_e.

classdef VisualServo < handle
    properties
        P
        uv_star
        Tcam
        camera         % camera object
        Tf
        T0
        pf

        history         % vector of structs to hold EKF history
        
        niter
        fps

        verbose
        arglist
        axis
        
        movie
        anim
        
        type
    end

    methods

        function vs = VisualServo(cam, varargin)
            %VisualServo.VisualServo Create IBVS object
            %
            % VS = VisualServo(camera, options) creates an image-based visual servo
            % simulation object.
            %
            % Options::
            % 'niter',N         Maximum number of iterations
            % 'fps',F           Number of simulation frames per second (default t)
            % 'Tf',T            The final pose
            % 'T0',T            The initial pose
            % 'P',p             The set of world points (3xN)
            % 'targetsize',S    The target points are the corners of an SxS
            %                   square in the XY-plane at Z=0 (default S=0.5)
            % 'pstar',p         The desired image plane coordinates
            % 'verbose'         Print out extra information during simulation
            %
            % Notes::
            % - If 'P' is specified it overrides the default square target.

            
            vs.camera = cam;
            vs.history = [];

            z = 3;
            opt.niter = [];
            opt.fps = 5;
            opt.posef = [];
            opt.pose0 = cam.T;
            opt.P = [];
            opt.targetsize = 0.5;       % dimensions of target
            opt.pstar = [];
            opt.axis = [];
            opt.movie = [];
            
            [opt,vs.arglist] = tb_optparse(opt, varargin);
            vs.niter = opt.niter;
            vs.fps = opt.fps;
            vs.verbose = opt.verbose;
            if ~isempty(opt.pose0)
                vs.T0 = SE3(opt.pose0);
            end
            if ~isempty(opt.posef)
                vs.Tf = SE3(opt.posef);
            end

            % define feature points in XY plane, make vertices of a square
            if isempty(opt.P)
                opt.P = mkgrid(2, opt.targetsize);
            end
            vs.P = opt.P;
            vs.pf = opt.pstar;
            vs.axis = opt.axis;
            vs.movie = opt.movie;
        end

        function run(vs, nsteps)
            %VisualServo.run  Run visual servo simulation
            %
            % VS.run(N) run the simulation for N steps
            %
            % VS.run() as above but run it for the number of steps
            % specified in the constructor or Inf.
            %
            % Notes::
            % - Repeatedly calls the subclass step() method which returns
            %   a flag to indicate if the simulation is complete.
            
            vs.init();
            
                        if ~isempty(vs.movie)
                vs.anim = Animate(vs.movie);
            end
            
            if nargin < 2
                nsteps = vs.niter;
            end
            ksteps = 0;
            while true
                ksteps = ksteps + 1;
                status = vs.step();

                drawnow
                
                            if ~isempty(vs.movie)
                vs.anim.add();
                            else
                pause(1/vs.fps)
                            end
                
                if status > 0
                    fprintf('completed on error tolerance\n');
                    break;
                elseif status < 0
                    fprintf('failed on error\n');
                    break;
                end
                
                if ~isempty(nsteps) && (ksteps > nsteps)
                    break;
                end
            end
            
            if ~isempty(vs.movie)
                vs.anim.close();
            end

            if status == 0
                fprintf('completed on iteration count\n');
            end
        end

        function plot_p(vs)
            %VisualServo.plot_p Plot feature trajectory
            %
            % VS.plot_p() plots point feature trajectories on the image plane.
            %
            % See also VS.plot_vel, VS.plot_error, VS.plot_camera,
            % VS.plot_jcond, VS.plot_z, VS.plot_error, VS.plot_all.
            
            if isempty(vs.history)
                return
            end
            if strcmp(vs.type, 'point') == 0
                disp('Can only plot image plane trajectories for point-based IBVS');
                return
            end
            clf
            hold on
            
            % image plane trajectory
            uv = [vs.history.f]';
            % result is a vector with row per time step, each row is u1, v1, u2, v2 ...
            for i=1:numcols(uv)/2
                p = uv(:,i*2-1:i*2);    % get data for i'th point
                plot(p(:,1), p(:,2), 'b')
            end
            
            % mark the initial target shape
            plot_poly( reshape(uv(1,:), 2, []), 'o--');
            uv(end,:)
            
            % mark the final target shape
            if ~isempty(vs.uv_star)
                plot_poly(vs.uv_star, 'rh:', 'MarkerSize', 8, 'MarkerFaceColor', 'r')
            else
                plot_poly( reshape(uv(end,:), 2, []), 'rh--', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
            end
            axis([0 vs.camera.npix(1) 0 vs.camera.npix(2)]);
            daspect([1 1 1])
            set(gca, 'Ydir' , 'reverse');
            grid
            xlabel('u (pixels)');
            ylabel('v (pixels)');
            
            hold off
        end

       function plot_vel(vs)
            %VisualServo.plot_vel Plot camera trajectory
            %
            % VS.plot_vel() plots the camera velocity versus time.
            %
            % See also VS.plot_p, VS.plot_error, VS.plot_camera,
            % VS.plot_jcond, VS.plot_z, VS.plot_error, VS.plot_all.
            if isempty(vs.history)
                return
            end
            clf
            vel = [vs.history.vel]';
            plot(vel(:,1:3), '-')
            hold on
            plot(vel(:,4:6), '--')
            hold off
            ylabel('Cartesian velocity')
            grid
            xlabel('Time step')
            xaxis(length(vs.history));
            legend('v_x', 'v_y', 'v_z', '\omega_x', '\omega_y', '\omega_z')
        end

        function plot_camera(vs)
            %VisualServo.plot_camera Plot camera trajectory
            %
            % VS.plot_camera() plots the camera pose versus time.
            %
            % See also VS.plot_p, VS.plot_vel, VS.plot_error,
            % VS.plot_jcond, VS.plot_z, VS.plot_error, VS.plot_all.

            if isempty(vs.history)
                return
            end
            clf
            % Cartesian camera position vs timestep
            T = SE3( cat(3, vs.history.Tcam) );
            
            subplot(211)
            plot(T.tv');
            xaxis(length(vs.history));
            ylabel('Camera position')
            legend('X', 'Y', 'Z');
            grid
            
            subplot(212)
            plot(T.torpy)
            ylabel('Camera orientation (rad)')
            grid
            xlabel('Time step')
            xaxis(length(vs.history));
            legend('R', 'P', 'Y');
        end

        function plot_jcond(vs)
            %VisualServo.plot_jcond Plot image Jacobian condition
            %
            % VS.plot_jcond() plots image Jacobian condition versus time.
            % Indicates whether the point configuration is close to
            % singular.
            %
            % See also VS.plot_p, VS.plot_vel, VS.plot_error, VS.plot_camera,
            % VS.plot_z, VS.plot_error, VS.plot_all.  
            
            if isempty(vs.history)
                return
            end
            clf

            Jcond = [vs.history.jcond];
            % Image Jacobian condition number vs time
            plot(Jcond);
            grid
            ylabel('Jacobian condition number')
            xlabel('Time step')
            xaxis(length(vs.history));
         end


        function plot_z(vs)
            %VisualServo.plot_z Plot feature depth
            %
            % VS.plot_z() plots feature depth versus time.  If a depth estimator is
            % used it shows true and estimated depth.
            %
            % See also VS.plot_p, VS.plot_vel, VS.plot_error, VS.plot_camera,
            % VS.plot_jcond, VS.plot_error, VS.plot_all.
             if isempty(vs.history)
                return
             end
             
            if strcmp(vs.type, 'point') == 0
                disp('Z-estimator data only computed for point-based IBVS');
                return
            end
            clf
            Zest = [vs.history.Zest];
            Ztrue = [vs.history.Ztrue];
            plot(Ztrue', '-')
            hold on
            set(gca, 'ColorOrderIndex', 1);
            plot(Zest', '--')
            grid
            ylabel('Depth (m)')
            xlabel('Time step')
            xaxis(length(vs.history));
            %legend('true', 'estimate')
        end

        function out = plot_error(vs)
            %VisualServo.plot_error Plot feature error
            %
            % VS.plot_error() plots feature error versus time.
            %
            % See also VS.plot_vel, VS.plot_error, VS.plot_camera,
            % VS.plot_jcond, VS.plot_z, VS.plot_all.
            
            if isempty(vs.history)
                return
            end
            clf
            e = [vs.history.e]';
            switch vs.type
                case 'point'
                    plot(e(:,1:2:end), 'r');
                    hold on
                    plot(e(:,2:2:end), 'b');
                    hold off
                    ylabel('Feature error (pixel)')
                    
                    legend('u', 'v');
                otherwise
                    plot(e);
                    ylabel('Feature error')
            end
            grid
            xlabel('Time')
            xaxis(length(vs.history));
            
            if nargout > 0
                out = e;
            end
        end

        function plot_all(vs, name, dev)
            %VisualServo.plot_all Plot all trajectory
            %
            % VS.plot_all() plots in separate figures feature values, velocity, 
            % error and camera pose versus time.
            %
            % VS.plot_all(DEV, NAME) writes each plot to a separate file.
            % The name is an SPRINTF format specifier with a %s field that
            % is replaced with a unique per plot suffix.  DEV is the device name
            % passed to the MATLAB print function
            %
            % Example::
            %         vs.plot_all('-depsc', 'eg1%s.eps');
            %
            % See also VS.plot_vel, VS.plot_error, VS.plot_camera,
            % VS.plot_error.
            
            if nargin < 3
                dev = '-depsc';
            end
            if nargin < 2
                name = [];
            end

            figure
            vs.plot_p();
            if ~isempty(name)
                print(gcf, dev, sprintf(name, '-p'));
            end

            figure
            vs.plot_vel();
            if ~isempty(name)
                print(gcf, dev, strcat(name, '-vel'));
            end

            figure
            vs.plot_camera();
            if ~isempty(name)
                print(gcf, dev, strcat(name, '-camera'));
            end
            figure
            vs.plot_error();
            if ~isempty(name)
                print(gcf, dev, strcat(name, '-error'));
            end
            
            % optional plots depending on what history was recorded
            if isfield(vs.history, 'Zest')
                figure
                vs.plot_z();
                if ~isempty(name)
                    print(gcf, dev, strcat(name, '-z'));
                end
            end
            
            if isfield(vs.history, 'jcond')
                figure
                vs.plot_jcond();
                if ~isempty(name)
                    print(gcf, dev, strcat(name, '-jcond'));
                end
            end
          
        end

        function display(vs)
            %VisualServo.display Display parameters
            %
            % VS.display() displays the VisualServo parameters in compact single line format.
            %
            % Notes::
            % - This method is invoked implicitly at the command line when the result
            %   of an expression is a VisualServo object and the command has no trailing
            %   semicolon.
            %
            % See also VisualServo.char.

            loose = strcmp( get(0, 'FormatSpacing'), 'loose');
            if loose
                disp(' ');
            end
            disp([inputname(1), ' = '])
            disp( char(vs) );
        end % display()

        function s = char(vs)
            %VisualServo.char Convert to string
            %
            % s = VS.char() is a string showing VisualServo parameters in a compact single line format.
            %
            % See also VisualServo.display.

            s = sprintf('Visual servo object: camera=%s\n  %d iterations, %d history', ...
                vs.camera.name, vs.niter, length(vs.history));
            s = strvcat(s, [['  P= '; '     '; '     '] num2str(vs.P)]);
            if 0
            s = strvcat(s, sprintf('  T0:'));
            s = strvcat(s, [repmat('      ', 4,1) num2str(vs.T0)]);
            s = strvcat(s, sprintf('  C*_T_G:'));
            s = strvcat(s, [repmat('      ', 4,1) num2str(vs.Tf)]);
            else
                if ~isempty(vs.T0)
                    s = strvcat(s, ['  C_T0:   ' trprint(vs.T0, 'fmt', ' %g', 'angvec')]);
                end
                if ~isempty(vs.Tf)
                    s = strvcat(s, ['  C*_T_G: ' trprint(vs.Tf, 'fmt', ' %g', 'angvec')]);
                end
            end
        end
    end
end
