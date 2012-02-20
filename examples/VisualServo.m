%VSPLOT  Plot visual servo results
%
%  vsplot(results)
%  vsplot(results, filename)
%  vsplot(results, npoints)
%  vsplot(results, npoints, filename)
%
% Display data from results structure as several graphs.
% Display all points by default, or first npoints if specified.
%
% If filename is given those files are saved in the current directory
% with different suffixes:
%   filename-uv   for image plane trajectory
%   filename-v    for Cartesian velocity
%   filename-cart for Cartesian pose
%   filename-jc   for Jacobian condition

classdef VisualServo < handle
    properties
        P
        uv_star
        Tcam
        camera
        Tf
        T0
        pf

        history         % vector of structs to hold EKF history
        
        niter
        fps

        verbose
        arglist
    end

    methods

        function vs = VisualServo(cam, varargin)
            vs.camera = cam;
            vs.history = [];

            cam
            z = 3;
            opt.niter = [];
            opt.fps = 5;
            opt.Tf = [];
            opt.T0 = cam.T;
            opt.P = [];
            opt.targetsize = 0.5;       % dimensions of target
            opt.pstar = [];

            [opt,vs.arglist] = tb_optparse(opt, varargin);
            vs.niter = opt.niter;
            vs.fps = opt.fps;
            vs.verbose = opt.verbose;
            vs.T0 = opt.T0;
            vs.Tf = opt.Tf;

            % define feature points in XY plane, make vertices of a square
            if isempty(opt.P)
                opt.P = mkgrid(2, opt.targetsize);
            end
            vs.P = opt.P;
            vs.pf = opt.pstar;
        end

        function run(vs, nsteps)
            vs.init();

            if nargin == 1
                if isempty(vs.niter)
                    nsteps = Inf;
                else
                    nsteps = vs.niter;
                end
            end

            for k=1:nsteps
                status = vs.step();

                drawnow
                pause(1/vs.fps)
                
                if status > 0
                    fprintf('completed on error tolerance\n');
                    break;
                elseif status < 0
                    fprintf('failed on error\n');
                    break;
                end
            end

            if status == 0
                fprintf('completed on iteration count\n');
            end
        end

        function plot_p(vs)
            clf
            hold on
            % image plane trajectory
            uv = [vs.history.uv]';
            % result is a vector with row per time step, each row is u1, v1, u2, v2 ...
            for i=1:numcols(uv)/2
                p = uv(:,i*2-1:i*2);    % get data for i'th point
                plot(p(:,1), p(:,2))
            end
            plot_poly( reshape(uv(1,:), 2, []), 'o--');
            uv(end,:)
            if ~isempty(vs.uv_star)
                plot_poly(vs.uv_star, '*:')
            else
                plot_poly( reshape(uv(end,:), 2, []), 'rd--');
            end
            axis([0 vs.camera.npix(1) 0 vs.camera.npix(2)]);
            set(gca, 'Ydir' , 'reverse');
            grid
            xlabel('u (pixels)');
            ylabel('v (pixels)');
            hold off
        end

       function plot_vel(vs)
            % Cartesian velocity vs time
            clf
            vel = [vs.history.vel]';
            plot(vel(:,1:3), '-')
            hold on
            plot(vel(:,4:6), '--')
            hold off
            ylabel('Cartesian velocity')
            grid
            xlabel('Time')
            xaxis(length(vs.history));
            legend('v_x', 'v_y', 'v_z', '\omega_x', '\omega_y', '\omega_z')
        end

        function plot_camera(vs)
            
            clf
            % Cartesian camera position vs time
            T = reshape([vs.history.Tcam], 4, 4, []);
            subplot(211)
            plot(transl(T));
            ylabel('camera position')
            grid
            subplot(212)
            plot(tr2rpy(T))
            ylabel('camera orientation')
            grid
            xlabel('Time')
            xaxis(length(vs.history));
            legend('R', 'P', 'Y');
            subplot(211)
            legend('X', 'Y', 'Z');
        end

        function plot_jcond(vs)
            
            clf

            Jcond = [vs.history.jcond];
            % Image Jacobian condition number vs time
            plot(Jcond);
            grid
            ylabel('Jacobian condition number')
            xlabel('Time')
            xaxis(length(vs.history));
         end


        function plot_z(vs)
            clf
            Zest = [vs.history.Zest];
            Ztrue = [vs.history.Ztrue];
            plot(Ztrue', '-')
            hold on
            plot(Zest', '--')
            grid
            ylabel('depth (m)')
            xaxis(length(vs.history));
            %legend('true', 'estimate')
        end

        function plot_error(vs)
            % Cartesian velocity vs time
            e = [vs.history.e]';
            plot(e(:,1:2:end), 'r');
            hold on
            plot(e(:,2:2:end), 'b');
            hold off
            ylabel('Feature error (pixel)')
            grid
            xlabel('Time')
            xaxis(length(vs.history));
            legend('u', 'v');
        end

        function plot_all(vs, prefix)

            if nargin < 2
                prefix = [];
            end

            figure
            vs.plot_p();
            if ~isempty(prefix)
                iprint(strcat(prefix, '-p'));
            end

            figure
            vs.plot_vel();
            if ~isempty(prefix)
                iprint(strcat(prefix, '-vel'));
            end

            figure
            vs.plot_camera();
            if ~isempty(prefix)
                iprint(strcat(prefix, '-cam'));
            end
            figure
            vs.plot_error();
            if ~isempty(prefix)
                iprint(strcat(prefix, '-fe'));
            end
        end

        function display(vs)
            loose = strcmp( get(0, 'FormatSpacing'), 'loose');
            if loose
                disp(' ');
            end
            disp([inputname(1), ' = '])
            disp( char(vs) );
        end % display()

        function s = char(vs)
            s = sprintf('Visual servo object: camera=%s\n  %d iterations, %d history', ...
                vs.camera.name, vs.niter, length(vs.history));
            s = strvcat(s, [['  P= '; '     '; '     '] num2str(vs.P)]);
            if 0
            s = strvcat(s, sprintf('  T0:'));
            s = strvcat(s, [repmat('      ', 4,1) num2str(vs.T0)]);
            s = strvcat(s, sprintf('  T_CT*:'));
            s = strvcat(s, [repmat('      ', 4,1) num2str(vs.Tf)]);
            else
            s = strvcat(s, ['  Tc0:   ' trprint(vs.T0, 'fmt', ' %g', 'angvec')]);
            if ~isempty(vs.Tf)
                s = strvcat(s, ['  Tc*_t: ' trprint(vs.Tf, 'fmt', ' %g', 'angvec')]);
            end
            end
        end
    end
end
