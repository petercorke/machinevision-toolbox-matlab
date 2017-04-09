classdef BundleAdjust < matlab.mixin.Copyable
    
    properties
        % Cameras and landmarks are represented by graph nodes
        %   coord(camera) -> camera pose, 6 vector
        %   vdata(camera) -> index into state vector or [] if a fixed camera
        %   coord(landmark) -> landmark position, first 3 elements of 6 vector
        %   vdata(landmark) -> index into state vector
        %
        % An edge from camera to a landmark holds the observed projection as a
        % property
        %   edata(edge) -> uv*
        
        g         % PGraph object describing visibility
        
        
        camera    % camera projection model
        
        cameras   % list of graph nodes corresponding to cameras
        points    % list of graph nodes corresponding to landmarks
        
        fixedcam     % logical array of cameras that are fixed
        fixedpoint   % logical array of landmarks that are fixed
    end
    
    properties (Dependent=true)
        ncams       % number of cameras
        nlandmarks  % number of landmark points
        ndim        % size of the linear system
    end
    
    
    methods
        
        function ba = BundleAdjust(camera)
            %BundleAdjust.BundleAdjust Bundle adjustment problem constructor
            %
            % Notes::
            % - A cameraModel file must exist on the path to evaluate the point projection
            %   and Jacobians.
            
            ba.camera = camera;  % stash the camera model
            ba.g = PGraph(6);    % initialize the graph, nodes have 6D coordinates
        end
        
        function n = get.ncams(ba)
            n = length(ba.cameras);
        end
        
        function n = get.nlandmarks(ba)
            n = length(ba.points);
        end
        
        function n = get.ndim(ba)
            n = 6*(ba.ncams - sum(ba.fixedcam)) + 3*(ba.nlandmarks - sum(ba.fixedpoint));
        end
        
        
        function n = cameraIdx(ba, i)
            n = 6*i - 5;
        end
        
        function n = landmarkIdx(ba, j)
            n = ba.ncams*6 + 3*j-2;
        end
        
        function n = cameraIdx2(ba, i)
            if ba.fixedcam(i)
                n = 0;
            else
                n = 6*(i - sum(ba.fixedcam(1:i))) - 5;
            end
        end
        
        function n = landmarkIdx2(ba, j)
            if ba.fixedpoint(j)
                n = 0;
            else
                n = 6*(ba.ncams - sum(ba.fixedcam)) + 3 * (j - sum(ba.fixedpoint(1:j))) - 2;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % METHODS TO SUPPORT BUILDING PROBLEMS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function vc = add_camera(ba, T, varargin)
            %BundleAdjust.add_camera Add camera to bundle adjustment problem
            %
            % VC = BA.add_camera(T, options) is the vertex id of a camera node added to
            % a bundle adjustment problem.  The camera has pose T which can be SE3 or a
            % vector (1x7) comprising translation and quaternion.
            %
            % VC = BA.add_camera() as above but the camera pose is the null pose in SE3.
            %
            % Options::
            % 'fixed'    This camera is fixed (anchored) and will not be adjusted in
            %            the optimization process.
            %
            % See also BundleAdjust.add_landmark, BundleAdjust.add_projection, PGraph.
            
            
            if nargin == 1
                T = SE3();
            end
            
            opt.fixed = false;
            opt = tb_optparse(opt, varargin);
            
            if isvec(T, 7)
                t = T(1:3); q = T(4:7);
            else
                [R,t] = tr2rt(T);
                q = UnitQuaternion(R).double;
                t = t';
            end
            
            if q(1) < 0
                q = -q;
            end
            x = [t q(2:4)];
            vc = ba.g.add_node(x);
            ba.cameras = [ba.cameras vc];
            ba.g.setvdata(vc, length(ba.cameras));
            
            
            ba.fixedcam = [ba.fixedcam opt.fixed];
        end
        
        function vp = add_landmark(ba, P, varargin)
            %BundleAdjust.add_landmark Add landmark to bundle adjustment problem
            %
            % VL = BA.add_landmark(P, options) is the vertex id of a landmark node added to
            % a bundle adjustment problem.  The landmark has position P (3x1).
            %
            % Options::
            % 'fixed'    This landmark is fixed (anchored) and will not be adjusted in
            %            the optimization process.
            %
            % See also BundleAdjust.add_camera, BundleAdjust.add_projection, PGraph.

            assert(isvec(P), 'P must be a 3-vector');
            
            opt.fixed = false;
            opt = tb_optparse(opt, varargin);
            
            x = [P(:); 0; 0; 0];
            vp = ba.g.add_node(x);
            ba.points = [ba.points vp];
            ba.g.setvdata(vp, length(ba.points));
            
            ba.fixedpoint = [ba.fixedpoint opt.fixed];
            
        end
        
        function e = add_projection(ba, c, p, uv)
            %BundleAdjust.add_projection Add camera to bundle adjustment problem
            %
            % EP = BA.add_projection(VC, VL, UV) is the edge id of an edge added to
            % a bundle adjustment problem.  it represents the observed projection UV (2x1) of the landmark node VL as
            % seen by the camera node VC.
            %
            % See also BundleAdjust.add_camera, BundleAdjust.add_landmark, PGraph.

            assert(isvec(uv, 2), 'uv must be a 2-vector');
            
            e = ba.g.add_edge(c, p);
            ba.g.setedata(e, uv(:));
        end
        

        
        function load_sba(ba, cameraFile, pointFile, calibFile)
            %BundleAdjust.load_sba Load bundle adjustment problem from files
            %
            % BA.load_sba(camfile, pointfile, calibfile) loads a bundle adjustment
            % problem from data files as distributed with the SBA package
            %
            % Example::
            % 
            % To solve the 7-point bundle adjustment problem distributed with SBA:
            %
            %           ba = BundleAdjust();
            %           pth = 'sba-1.6/demo/'
            %           ba.load_sba([pth '7cams.txt'], [pth '7pts.txt'], [pth 'calib.txt']);
            %
            % Reference::
            % - Sparse Bundle Adjustment package by Manolis Lourakis
            %   http://users.ics.forth.gr/~lourakis/sba
            %
            % See also BundleAdjust.add_camera, BundleAdjust.add_landmark, BundleAdjust.add_projection, PGraph.
            
            % adopted from sba-1.6/matlab/eucsbademo.m 
            
            % read in camera parameters
            [q1, q2, q3, q4, tx, ty, tz] = textread(cameraFile, '%f%f%f%f%f%f%f', 'commentstyle', 'shell');
            
            for i=1:length(q1)
                ba.add_camera( [tx(i) ty(i) tz(i) q1(i) q2(i) q3(i) q4(i)] );
            end
            
            
            % read points file line by line
            %
            % each line is a world point
            fid = fopen(pointFile);
            npts = 0;
            while ~feof(fid)
                line = fgets(fid);
                [A, count, errmsg, nextindex] = sscanf(line, '%f%f%f%f', [1, 4]); % read X, Y, Z, nframes
                if(size(A, 2)>0) % did we read anything?
                    npts=npts+1;
                    
                    % create a node for this point
                    lm = ba.add_landmark(A(1:3));
                    
                    % now find which cameras it was seen by
                    nframes = A(4);
                    for i=1:nframes % read "nframes" id, x, y triplets
                        [A, count, errmsg, j] = sscanf(line(nextindex:length(line)), '%f%f%f', [1, 3]); % read id, x, y
                        nextindex=nextindex+j; % skip the already read line prefix
                        
                        % add a landmark projection
                        ba.add_projection( ba.cameras(A(1)+1), lm, A(2:3) );
                    end
                end
            end
            fclose(fid);
            
            % read in calibration parameters
            [a1, a2, a3] = textread(calibFile, '%f%f%f', 'commentstyle', 'shell');
            % a1(1)    a2(1)  a3(1)  a2(2)    a3(2)];
            % f/rho_u  skew   u0     f/rho_v  v0
            
            ba.camera.f = a1(1);
            ba.camera.rho = [1 a1(1)/a2(2)];
            ba.camera.pp = [a3(1) a3(2)];
        end
        
        function T = getcamera(ba, ii)
            assert(all(ii > 0), 'camera indices must be > 0');
            assert(all(ii <= ba.ncams), 'camera index out of range'); 
            if nargin == 1
                ii = [1:ba.ncams];
            end
            for k=1:length(ii)
                i = ii(k);
                node = ba.cameras(i);
                qv = ba.g.coord(node);
                T(k) = SE3(qv(1:3)') * UnitQuaternion.vec(qv(4:6)).SE3;
            end
            
        end
        
        function P = getlandmark(ba, jj)
            assert(all(jj > 0), 'landmark indices must be > 0');
            assert(all(jj <= ba.nlandmarks), 'landmark index out of range');
            if nargin == 1
                jj = [1:ba.nlandmarks];
            end
            for k=1:length(jj)
                j = jj(k);
                node = ba.points(j);
                qv = ba.g.coord(node);
                P(:,k) = qv(1:3);
            end
        end


        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % METHODS TO SOLVE PROBLEMS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [ba2,e] = optimize(ba, varargin)
            %BundleAdjust.optimize  Optimize the solution
            %
            % BA2 = BA.optimize(
            

            
            opt.iterations = 1000;
            opt.animate = false;
            opt.retain = false;
            opt.lambda = 0.1;
            opt.lambdamin = 1e-8;
            opt.dxmin = 1e-8;
            opt.tol = 0.05;
            
            [opt,args] = tb_optparse(opt, varargin);
            
            %g2 = PGraph(pg.graph);  % deep copy
            
            if length(args) > 0 && isvec(args{1}, ba.ndim)
                X = args{1};
            else
                X = ba.getstate();
            end
            
            lambda = opt.lambda;
            
                        X0 = X;
            
            t0 = cputime();
            
            fprintf('Initial cost %g\n', ba.errors(X));
                            
            for i=1:opt.iterations
                if opt.animate
                    if ~opt.retain
                        clf
                    end
                    g2.plot();
                    pause(0.5)
                end
                
                tic
                
                % solve for the step
                [dX,energy] = ba.solve(X, lambda);
                % update the state
                Xnew = ba.updatestate(X, dX);
                % compute new value of cost
                enew = ba.errors(Xnew);
                
                dt = toc;
                fprintf('  total cost %g (solved in %.2g sec)', enew, dt);
                
                
                % are we there yet?
                if enew < opt.tol
                    break
                end
                
                % have we stopped moving
                if  norm(dX) < opt.dxmin
                    break
                end

                
                % do the Levenberg-Marquadt thing, was it a good update?
                if enew < energy
                    % step is accepted
                    X = Xnew;
                    if lambda > opt.lambdamin
                        lambda = lambda/sqrt(2);
                    end
                    if opt.verbose
                        fprintf(' -- step accepted: lambda = %g', lambda);
                    end
                else
                    % step is rejected
                    lambda = lambda*4;
                    if opt.verbose
                        fprintf(' -- step rejected: lambda = %g', lambda);
                    end
                end
                
                fprintf('\n');
            end
            
            tf = cputime();
            fprintf('\n * %d iterations in %.1f seconds\n', i, tf-t0);
            fprintf(' * %.2f pixels RMS error\n', sqrt(enew/ba.g.ne));
            
            % copy the object and update it
            ba2 = copy(ba);
            ba2.g = copy(ba.g);
            ba2.setstate(X);
            
            
            if nargout > 1
                e = enew;
            end
        end
        
        function [deltax,err] = solve(ba, X, lambda)
            
            if nargin < 3
                lambda =0;
            end
            
            %ba.init_tables();
            
            % create the Hessian and error vector
            [H,b,e] = ba.build_linear_system(X);
            
            % add damping term to the diagonal
            for i=1:ba.ndim
                H(i,i) = H(i,i) + lambda;
            end
            
            % solve for the state update
            % - could replace this with the Schur complement trick
            deltax = H \ b;
            
            if nargout > 1
                err = e;
            end
        end
        
        
        % build the Hessian and measurement vector
        function [H,b,etotal,J] = build_linear_system(ba, X)
            
            % allocate storage
            H = sparse(ba.ndim, ba.ndim);
            b = zeros(ba.ndim,1);
            
            etotal = 0;
            
            % loop over cameras
            for i=1:ba.ncams
                
                k = ba.cameraIdx(i);
                x = X(k:k+5);
                
                t = x(1:3); qv = x(4:6);
                
                % loop over all points viewed from this camera
                for p=ba.g.edges( ba.cameras(i) )
                    v = ba.g.vertices(p);
                    j = ba.g.vdata(v(2));
                    
                    k = ba.landmarkIdx(j);
                    x = X(k:k+2);
                    
                    P = x';
                    
                    uv = ba.g.edata(p);
                    
                    % compute Jacobians and projection
                    
                    [uvhat,JA,JB] = ba.camera.derivs(t, qv, P);
                    
                    
                    % compute reprojection error
                    e = uvhat - uv;
                    etotal = etotal + e'*e;
                    
                    ii = ba.cameraIdx2(i); jj = ba.landmarkIdx2(j);
                    
                    
                    % compute the block components of H and b for this edge
                    
                    if ~ba.fixedcam(i) & ~ba.fixedpoint(j)
                        % adjustable point and camera
                        H_ii= JA'*JA;
                        H_ij= JA'*JB;
                        H_jj= JB'*JB;
                        
                        H(ii:ii+5,ii:ii+5) = H(ii:ii+5,ii:ii+5) + H_ii;
                        H(ii:ii+5,jj:jj+2) = H(ii:ii+5,jj:jj+2) + H_ij;
                        H(jj:jj+2,ii:ii+5) = H(jj:jj+2,ii:ii+5) + H_ij';
                        H(jj:jj+2,jj:jj+2) = H(jj:jj+2,jj:jj+2) + H_jj;
                        
                        b_i = -JA'*e;
                        b_j = -JB'*e;
                        
                        b(ii:ii+5) = b(ii:ii+5) + b_i;
                        b(jj:jj+2) = b(jj:jj+2) + b_j;
                        
                        
                    elseif ba.fixedcam(i) & ~ba.fixedpoint(j)
                        % fixed camera and adjustable point
                        
                        H_jj= JB'*JB;
                        
                        H(jj:jj+2,jj:jj+2) = H(jj:jj+2,jj:jj+2) + H_jj;
                        
                        b_j = -JB'*e;
                        
                        b(jj:jj+2) = b(jj:jj+2) + b_j;
                        
                    elseif ~ba.fixedcam(i) & ba.fixedpoint(j)
                        % adjustable camera and fixed point
                        
                        H_ii= JA'*JA;
                        
                        H(ii:ii+5,ii:ii+5) = H(ii:ii+5,ii:ii+5) + H_ii;
                        
                        b_i = -JA'*e;
                        
                        b(ii:ii+5) = b(ii:ii+5) + b_i;
                    end
                    
                end
            end
            
        end
             
                
        function spyH(ba, X)
            H = build_linear_system(ba, X);
            spy(H);
        end

        
        function X = getstate(ba)
            %BundleAdjust.getstate Get the state vector
            %
            % X = BA.getstate() is a row vector containing the state vector of the
            % problem: all camera poses followed by all landmark coordinates.
            %
            % Notes::
            % - The length of the vector is given by BA.ndim.
            
            X = [];
            
            i = 0;
            for c=ba.cameras  % step through camera nodes
                X = [X  ba.g.coord(c)'];
            end
            
            
            for p=ba.points  % step through landmark nodes
                P = ba.g.coord( p );
                X = [X  P(1:3)'];
            end
        end
        
        function setstate(ba, X)
            %BundleAdjust.getstate Get the state vector
            %
            % X = BA.getstate() is a row vector containing the state vector of the
            % problem: all camera poses followed by all landmark coordinates.
            %
            % Notes::
            % - The length of the vector is given by BA.ndim.
            
            
            for i=1:ba.ncams  % step through camera nodes
                if ~ba.fixedcam(i)
                    k = ba.cameraIdx(i);
                    c = ba.cameras(i);
                    ba.g.setcoord(c, X(k:k+5));
                end
            end
            
            for j=1:ba.nlandmarks
                if ~ba.fixedpoint(j)
                    k = ba.landmarkIdx(j);
                    lm = ba.points(j);
                    ba.g.setcoord(lm, [X(k:k+2) 0 0 0]);
                end
            end
        end
        
        
        function Xnew = updatestate(ba, X, dX)
            dX = dX(:)';
            
            % for each camera we need to compound the camera pose with the
            % incremental relative pose
            for i=1:ba.ncams
                k = ba.cameraIdx(i);
                if ba.fixedcam(i)
                    Xnew(k:k+5) = X(k:k+5);
                else
                    x = X(k:k+5);
                    t = x(1:3); qv = x(4:6);  % get current pose
                    
                    k2 = ba.cameraIdx2(i);
                    dx = dX(k2:k2+5);
                    dt = dx(1:3); dqv = dx(4:6); % get incremental pose
                    tnew = t+dt;  % assume translation in old frame
                    % compound the quaternion vector rotations
                    % - function qvmul is symbolically generated by ba
                    %qvnew = qvmul(qv(1), qv(2), qv(3), dqv(1), dqv(2), dqv(3));
                    qvnew = UnitQuaternion.qvmul(qv, dqv);
                    
                    Xnew(k:k+5) = [tnew qvnew];
                end
            end
            
            % for each landmark we add the increment to its position
            for j=1:ba.nlandmarks
                k = ba.landmarkIdx(j);
                x = X(k:k+2);
                if ba.fixedpoint(j)
                    Xnew(k:k+2) = x;
                else
                    k2 = ba.landmarkIdx2(j);
                    dx = dX(k2:k2+2);
                    Xnew(k:k+2) = x + dx;
                end
            end
        end
        
        % Compute total squared reprojection error
        function etotal = errors(ba, X)
            
            if nargin < 2
                X = ba.getstate();
            end
            r = ba.getresidual(X);
            
            etotal = sum(r(:));
        end
        
        function r = getresidual(ba, X)
            % this is the squared reprojection errors
            
            if nargin == 1
                X = ba.getstate();
            end
            
            % loop over cameras
            for i=1:ba.ncams
                
                k = ba.cameraIdx(i);
                x = X(k:k+5);
                
                t = x(1:3); qv = x(4:6);
                
                % loop over all points viewed from this camera
                for p=ba.g.edges( ba.cameras(i) )
                    v = ba.g.vertices(p);
                    j = ba.g.vdata(v(2));
                    
                    k = ba.landmarkIdx(j);
                    x = X(k:k+2);
                    
                    P = x';
                    
                    uv = ba.g.edata(p);
                    
                    uvhat = ba.camera.derivs(t, qv, P);
                    
                    % compute reprojection error
                    e = uvhat - uv;
                    r(i,j) =  e'*e;
                end
            end
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SUPPORT METHODS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function plot(ba, varargin)
            clf
            ba.g.plot('dims', 3, 'only', ba.points, 'EdgeColor', 0.8*[1 1 1], varargin{:});
            axis equal
            hold on
            
            colorOrder = get(gca, 'ColorOrder');
            for i=1:ba.ncams
                T = ba.getcamera(i);
                cam(i) = ba.camera.move(T);
                cidx = mod(i-1, numrows(colorOrder))+1;
                color = colorOrder(cidx,:);
                cam(i).plot_camera('scale', 0.2, 'color', color, 'persist')
            end
            hold off
            axis equal
            xlabel('X (m)')
            ylabel('Y (m)')
            zlabel('Z (m)')
            grid on
        end
                
        function display(ba)
            %BundleAdjust.display BundleAdjust parameters
            %
            % BA.display() displays the bundle adjustment parameters in compact format.
            %
            % Notes::
            % - This method is invoked implicitly at the command line when the result
            %   of an expression is a BundleAdjust object and the command has no trailing
            %   semicolon.
            %
            % See also BundleAdjust.char.
            loose = strcmp( get(0, 'FormatSpacing'), 'loose');
            if loose
                disp(' ');
            end
            disp([inputname(1), ' = '])
            disp( char(ba) );
        end % display()
        
        function s = char(ba)
            %BundleAdjust.char Convert to string
            %
            % BA.char() is a string showing bundle adjustment parameters in compact format.
            %
            %
            % See also BundleAdjust.display.
            s = 'Bundle adjustment problem:';
            s = strvcat(s, sprintf('  %d cameras', ba.ncams));
            if any(ba.fixedcam)
                s = strvcat(s, sprintf('    locked cameras: %s', num2str(find(ba.fixedcam))));
            end
            
            s = strvcat(s, sprintf('  %d landmarks', ba.nlandmarks));
            
            s = strvcat(s, sprintf('  %d projections', ba.g.ne));
            
            s = strvcat(s, sprintf('  %d dimension linear problem', ba.ndim));
            c = ba.g.connectivity(ba.cameras);
            s = strvcat(s, sprintf('  landmarks per camera: min=%.1f, max=%.1f, avg=%.1f', min(c), max(c), mean(c)));
            c = ba.g.connectivity(ba.points);
            s = strvcat(s, sprintf('  cameras per landmark: min=%.1f, max=%.1f, avg=%.1f', min(c), max(c), mean(c)));
        end
        
    end % methods
    
end % classdef
