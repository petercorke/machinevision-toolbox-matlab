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

classdef IBVS_sph < VisualServo

    properties
        pt          % phi, theta
        pt_star

        lambda          % IBVS gain
        eterm

        depth

        proj_lines
    end

    methods

        function ibvs = IBVS_sph(cam, varargin)

            % invoke superclass constructor
            ibvs = ibvs@VisualServo(cam, varargin{:});

            % handle arguments
            opt.eterm = 0.01;
            opt.lambda = 0.04;         % control gain
            opt.depth = [];
                        opt.example = false;

            
            opt = tb_optparse(opt, ibvs.arglist);

            % copy options to IBVS object
            if opt.example
                % run a canned example
                fprintf('---------------------------------------------------\n');
                fprintf('canned example, spherical IBVS with 4 points\n');
                fprintf('---------------------------------------------------\n');
                ibvs.P = mkgrid(2, 1.5, 'pose', SE3(0,0,0.5));
                ibvs.Tf = SE3(0, 0, -1.5)*SE3.Rz(1);
                ibvs.T0 = SE3(0.3, 0.3, -2)*SE3.Rz(0.2);
                %ibvs.T0 = transl(-1,-0.1,-3);%*trotx(0.2);
            end
            
            ibvs.lambda = opt.lambda;
            ibvs.eterm = opt.eterm;
            ibvs.depth = opt.depth;
            
            clf
            subplot(121);
            ibvs.camera.plot_create(gca)
            ibvs.camera.plot(ibvs.P, 'ro')
            
            % this is the 'external' view of the points and the camera
            subplot(122)
            plot_sphere(ibvs.P, 0.08, 'r');
            ibvs.camera.plot_camera('pose', ibvs.T0);
            plotvol([-2 2 -2 2 -3 1])
            view(16, 28);
            grid on
            set(gcf, 'Color', 'w')
            
            % draw lines from points to centre of sphere
            centre = ibvs.camera.T.t;
            ibvs.proj_lines = gobjects;
            for i=1:numcols(ibvs.P)
                ibvs.proj_lines(i) = plot3([centre(1) ibvs.P(1,i)], [centre(2) ibvs.P(2,i)], [centre(3) ibvs.P(3,i)], 'k')
            end
            
            set(gcf, 'HandleVisibility', 'Off');
            
            ibvs.type = 'spherical';
        end

        function init(vs)


            if isempty(vs.Tf)
                vs.Tf = transl(0, 0, -1);
                warning('setting Tf to default');
            end
            %% initialize the vservo variables
            vs.camera.T = vs.T0;    % set camera back to its initial pose
            vs.Tcam = vs.T0;                % initial camera/robot pose

            % final pose is specified in terms of a camera-target pose
            %   convert to image coords
            vs.pt_star = vs.camera.project(vs.P, 'pose', vs.Tf);



            vs.history = [];
        end

        function status = step(vs)
            status = 0;
            Zest = [];
            
                        % plot the points on mage plane
            vs.camera.clf();
            vs.camera.hold(true);
            vs.camera.plot(vs.P, 'pose', vs.Tcam, 'ro');
            vs.camera.plot(vs.pt_star, 'r*'); 
            
            % compute the view
            pt = vs.camera.project(vs.P, 'Tcam', vs.Tcam);

            % compute image plane error as a column
            e = pt - vs.pt_star;   % feature error
            e(2,:) = angdiff(e(2,:));
            e = e(:);
        
            % compute the Jacobian
            if isempty(vs.depth)
                % exact depth from simulation (not possible in practice)
                P_C = homtrans(inv(vs.Tcam), vs.P);
                J = vs.camera.visjac_p(pt, P_C(3,:) );
            else
                J = vs.camera.visjac_p(pt, vs.depth );
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

            % update the camera pose
            Td = trnorm(delta2tr(v));    % differential motion

            vs.Tcam = vs.Tcam .* SE3(Td);       % apply it to current pose

            % update the camera pose
            vs.camera.T = vs.Tcam;
            
            % draw lines from points to centre of sphere
            centre = vs.Tcam.t;
            for i=1:numcols(vs.P)
                vs.proj_lines(i).XData = [centre(1) vs.P(1,i)];
                vs.proj_lines(i).YData = [centre(2) vs.P(2,i)];
                vs.proj_lines(i).ZData = [centre(3) vs.P(3,i)];
            end

            % update the history variables
            hist.pt = pt(:);
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
