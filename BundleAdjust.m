classdef BundleAdjust < handle
    
    properties
        g
        cam       % camera projection model
          
        cameras   % graph nodes for cameras
        points    % graph nodes for landmarks
        
        fixedcam     % camera graph nodes that are fixed
        fixedpoint   % landmark nodes that are fixed
        
%         cammap
%         nadjcam
%         
%         

cmap1
cmap2
pmap1
pmap2

    end
    
    properties (Dependent=true)
        ncams     % number of cameras
        npoints   % number of landmark points
        ndim      % size of the linear system
        ndim2
    end
    
    
    % Cameras and landmarks are represented by graph nodes
    %   coord(camera) -> camera pose, 6 vector
    %   vdata(camera) -> index into state vector or [] if a fixed camera
    %   coord(landmark) -> landmark position, first 3 elements of 6 vector
    %   vdata(landmark) -> index into state vector
    %
    % An edge from camera to a landmark holds the observed projection as a
    % property
    %   edata(edge) -> uv*
    methods
        
        function ba = BundleAdjust(camera)
            ba.cam = camera;
            ba.g = PGraph(6);
%             ba.nadjcam = 0;
        end
        
        function load_sba(ba, cameraFile, pointFile, calibFile)
            % adopted from sba-1.6/matlab/eucsbademo.m http://users.ics.forth.gr/~lourakis/sba
            
            % read in camera parameters
            [q1, q2, q3, q4, tx, ty, tz] = textread(cameraFile, '%f%f%f%f%f%f%f', 'commentstyle', 'shell');

            for i=1:length(q1)
                ba.add_camera( [tx(i) ty(i) tz(i)], [q1(i) q2(i) q3(i) q4(i)] );
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

            ba.cam.f = a1(1);
            ba.cam.rho = [1 a1(1)/a2(2)];
            ba.cam.pp = [a3(1) a3(2)];
        end
        
        function vc = add_camera(ba, T, varargin)

            opt.fixed = false;
            opt = tb_optparse(opt, varargin);
            
            [R,t] = tr2rt(T);
            q = UnitQuaternion(R).double;
            
            if q(1) < 0
                q = -q;
            end
            x = [t' q(2:4)];
            vc = ba.g.add_node(x);
            ba.cameras = [ba.cameras vc];
            ba.g.setvdata(vc, length(ba.cameras));
            
            %             if opt.fixed
            %                 ba.cammap = [ba.cammap NaN];
            %             else
            %                 ba.nadjcam = ba.nadjcam + 1;
            %                 ba.cammap = [ba.cammap ba.nadjcam];
            %             end
            ba.fixedcam = [ba.fixedcam opt.fixed];
        end
        
        function vp = add_landmark(ba, P, varargin)
            assert(isvec(P), 'P must be a 3-vector');
            
            opt.fixed = false;
            opt = tb_optparse(opt, varargin);
            
            x = [P(:); 0; 0; 0];
            vp = ba.g.add_node(x);
            ba.points = [ba.points vp];
            ba.g.setvdata(vp, length(ba.points));
            
            ba.fixedpoint = [ba.fixedpoint opt.fixed];

        end
        
        function v = add_projection(ba, c, p, uv)
            assert(isvec(uv, 2), 'uv must be a 2-vector');

            e = ba.g.add_edge(c, p);
            ba.g.setedata(e, uv(:));
        end
        
        function init_index_tables(ba)
            
            if any(ba.g.connectivity == 1)
                fprintf('some points have no projections\n');
            end
            
            k1 = 1; k2 = k1;
            
            for i=1:ba.ncams
                ba.cmap1(i) = k1;
                k1 = k1 + 6;
                if ba.fixedcam(i) == 0
                    ba.cmap2(i) = k2;
                    k2 = k2 + 6;
                else
                    ba.cmap2(i) = NaN;
                end
            end
            
            %k1 = 6*ba.ncams + 1; k2 = k1;
            for j=1:ba.npoints
                ba.pmap1(j) = k1;
                k1 = k1 + 3;
                if ba.fixedpoint(j) == 0
                    ba.pmap2(j) = k2;
                    k2 = k2 + 3;
                else
                    ba.pmap2(j) = NaN;
                end
            end
            
            ba.cmap1
            ba.cmap2
            ba.pmap1
            ba.pmap2
        end
        
        function n = get.ncams(ba)
            n = length(ba.cameras);
        end
        
        function n = get.npoints(ba)
            n = length(ba.points);
        end
        
        function n = get.ndim(ba)
            n = 6*(ba.ncams - sum(ba.fixedcam)) + 3*(ba.npoints - sum(ba.fixedpoint));
        end
        
        function n = get.ndim2(ba)
            n = 6*(ba.ncams ) + 3*(ba.npoints - sum(ba.fixedpoint));
        end
        
%         function n = cameraIdx(ba, i)
%             %n = 6*ba.cammap(i) - 5;
%             n = ba.cmap1(i);
%         end
%         
%         function n = landmarkIdx(ba, j)
%             n = ba.pmap1(j);
%         end
%         
%         function n = cameraIdx2(ba, i)
%             n = ba.cmap2(i);
%         end
%         
%         function n = landmarkIdx2(ba, j)
%             n = ba.pmap2(j);
%         end

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
        
        function display(l)
            %Link.display Display parameters
            %
            % L.display() displays the link parameters in compact single line format.  If L is a
            % vector of Link objects displays one line per element.
            %
            % Notes::
            % - This method is invoked implicitly at the command line when the result
            %   of an expression is a Link object and the command has no trailing
            %   semicolon.
            %
            % See also Link.char, Link.dyn, SerialLink.showlink.
            loose = strcmp( get(0, 'FormatSpacing'), 'loose');
            if loose
                disp(' ');
            end
            disp([inputname(1), ' = '])
            disp( char(l) );
        end % display()
        
        function s = char(ba)
            s = 'Bundle adjustment problem:';
            s = strvcat(s, sprintf('  %d cameras', ba.ncams));
            if any(ba.fixedcam)
                s = strvcat(s, sprintf('    locked cameras: %s', num2str(find(ba.fixedcam))));
            end
            
            s = strvcat(s, sprintf('  %d landmarks', ba.npoints));

            s = strvcat(s, sprintf('  %d projections', ba.g.ne));

            s = strvcat(s, sprintf('  %d dimension linear problem', ba.ndim));
            s = strvcat(s, sprintf('  average connectivity per camera %.1f', mean( ba.g.connectivity(ba.cameras) )));
            c = ba.g.connectivity(ba.points);
            s = strvcat(s, sprintf('  average connectivity per landmark %.1f', mean( c )));
        end
        
        function plot(ba, varargin)
            clf
            ba.g.plot('dims', 3, varargin{:});
            xlabel('x')
            ylabel('y')
            grid on
        end
        
        function X = getstate(ba)
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
        
        
%                 function Xnew = updatestate2(ba, X, dX)
%             dX = dX(:)';
%             
%             %dX(1:6) = 0;    % lock the first camera HACK
%             dX = [0 0 0 0 0 0 dX];
%             
%             % for each camera we need to compound the camera pose with the
%             % incremental relative pose
%             k = 1;
%             for i=1:ba.ncams
% %                 if ba.fixedcam(i)
% %                     continue;
% %                 end
%                 t = X(k:k+2); qv = X(k+3:k+5);  % get current pose
%                 dt = dX(k:k+2); dqv = dX(k+3:k+5); % get incremental pose
%                 tnew = t+dt;  % assume translation in old frame
%                 % compound the quaternion vector rotations
%                 % - function qvmul is symbolically generated by ba
%                 qvnew = qvmul(qv(1), qv(2), qv(3), dqv(1), dqv(2), dqv(3));
%                                     i
%                     qv
%                     dqv
%                     qvnew
%                 Xnew(k:k+5) = [tnew qvnew];
%                 
%                 k = k + 6;
%             end
%            
%             % simply add the delta to the landmark positions
%             Xnew = [Xnew X(k:end) + dX(k:end)];
% 
%                 end
        
        function Xnew = updatestate(ba, X, dX)
            dX = dX(:)';
            
%             %dX(1:6) = 0;    % lock the first camera HACK
%             dX = [0 0 0 0 0 0 dX];
            
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
                    qvnew = qvmul(qv(1), qv(2), qv(3), dqv(1), dqv(2), dqv(3));

                    Xnew(k:k+5) = [tnew qvnew];
                end
            end
           
%             % simply add the delta to the landmark positions
%             Xnew = [Xnew X(k:end) + dX(k:end)];


            for j=1:ba.npoints
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
        
        % Compute total reprojection error
        function etotal = errors(ba, X)
            
            etotal = 0;
            
            % unpack the camera parameters
            f = ba.cam.f;
            u0 = ba.cam.u0;
            v0 = ba.cam.v0;
            rho = ba.cam.rho;
            
            % loop over cameras
            for c=ba.cameras
                campose = ba.g.coord(c);
                i = ba.g.vdata(c);
                
                if ba.fixedcam(i)
                    % this camera is fixed
                    x = ba.g.coord(c);
                else
                    k = ba.cameraIdx(i);
                    x = X(k:k+5);
                end
                
                t = x(1:3);
                qv = x(4:6);
                
                % loop over points viewed from this camera
                for p=ba.g.edges(c)
                    v = ba.g.vertices(p);  % vertices of this edge
                    j = ba.g.vdata(v(2));
                    k = ba.landmarkIdx(j);
                    x = X(k:k+2);
                    P = x';
                    
                    uv = ba.g.edata(p);
                    
                    % estimate the projection
                    %uvhat = cam.project(P);
                    
                    % compute projection
                    uvhat = cameraModel( ...
                        t(1), t(2), t(3), qv(1), qv(2), qv(3), ...
                        P(1), P(2), P(3), ...
                        f, rho(1), rho(2), u0, v0);
                    
                    % compute reprojection error
                    e = uvhat - uv;
                    etotal = etotal + e'*e;
                end
            end
        end
        
        % build the Hessian and measurement vector
        function [H,b,etotal,J] = build_linear_system(ba, X)

            % allocate storage
            H = sparse(ba.ndim, ba.ndim);
            b = zeros(ba.ndim,1);
            
            etotal = 0;
            
            % unpack the camera parameters
            f = ba.cam.f;
            u0 = ba.cam.u0;
            v0 = ba.cam.v0;
            rho = ba.cam.rho;
            
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
                    [uvhat,JA,JB] = cameraModel( ...
                        t(1), t(2), t(3), qv(1), qv(2), qv(3), ...
                        P(1), P(2), P(3), ...
                        f, rho(1), rho(2), u0, v0);
                     
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

%         function [H,b,etotal,J] = build_linear_system(ba, X)
% 
%             % allocate storage
%             H = sparse(ba.ndim2, ba.ndim2);
%             b = zeros(ba.ndim2,1);
%             
%             etotal = 0;
%             
%             % unpack the camera parameters
%             f = ba.cam.f;
%             u0 = ba.cam.u0;
%             v0 = ba.cam.v0;
%             rho = ba.cam.rho;
%             
%             % loop over cameras
%             for c=ba.cameras
%                 
% %                 if ismember(c, ba.fixed)
% %                     continue;
% %                 end
%                 campose = ba.g.coord(c);
%                 i = ba.g.vdata(c);
%                 ii = ba.cameraIdx(i);
%                 x = X(ii:ii+5);
%                 
%                 t = x(1:3);
%                 qv = x(4:6);
% 
%                 % loop over points viewed from this camera
%                 for p=ba.g.edges(c)
%                     v = ba.g.vertices(p);
%                     j = ba.g.vdata(v(2));
%                     jj = ba.landmarkIdx(j);
%                     x = X(jj:jj+2);
%                     
%                     P = x';
%                     
%                     uv = ba.g.edata(p);
%                                         
%                     % compute Jacobians and projection
%                     [uvhat,JA,JB] = cameraModel( ...
%                         t(1), t(2), t(3), qv(1), qv(2), qv(3), ...
%                         P(1), P(2), P(3), ...
%                         f, rho(1), rho(2), u0, v0);
%                      
%                     % compute reprojection error
%                     e = uvhat - uv;
%                     etotal = etotal + e'*e;
%                     
%                     
%                     % compute the block components of H and b for this edge
%                     H_ii= JA'*JA;
%                     H_ij= JA'*JB;
%                     H_jj= JB'*JB;
%                     
%                     b_i = -JA'*e;
%                     b_j = -JB'*e;
%                                
%                     % add them into their positions in H and b
%                     H(ii:ii+5,ii:ii+5) = H(ii:ii+5,ii:ii+5) + H_ii;
%                     H(ii:ii+5,jj:jj+2) = H(ii:ii+5,jj:jj+2) + H_ij;
%                     H(jj:jj+2,ii:ii+5) = H(jj:jj+2,ii:ii+5) + H_ij';
%                     H(jj:jj+2,jj:jj+2) = H(jj:jj+2,jj:jj+2) + H_jj;
%                     
%                     b(ii:ii+5) = b(ii:ii+5) + b_i;
%                     b(jj:jj+2) = b(jj:jj+2) + b_j;
%                 end
%             end
%             
%             H = H(7:end,7:end);
%             b = b(7:end);
%         end
        
        function [newmeans,err] = solve(ba, X, lambda)
            
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
            
            spy(H)
            
%             for c=flip(ba.cameras)
%                 i = ba.g.vdata(c);
%                 
%                 if ba.fixedcam(i)
%                     % cumbersome, since we can use = [] to remove rows/columns of a sparse
%                     % matrix, would be better to build the matrix the right size
%                     k = ba.cameraIdx(i);
%                     H(k:end-6,:) = H(k+6:end,:);  % remove block of rows
%                     H(:,k:end-6) = H(:,k+6:end);  % remove block of columns
%                     H = H(1:end-6,1:end-6);     % make it smaller
%                     
%                     b(k:end-6) = b(k+6:end);
%                     b = b(1:end-6);
%                 end
%             end
            
            % solve for the state update
            % - could replace this with the Schur complement trick
            deltax = H \ b;
            
            % update the state
            newmeans = ba.updatestate(X, deltax);

            if nargout > 1
                err = e;
            end
        end
        

        function [XX,e] = optimize(ba, X, varargin)
            
            t0 = cputime();
            
            opt.iterations = 1000;
            opt.animate = false;
            opt.retain = false;
            opt.lambda = 0.1;
            opt.lambdamin = 1e-8;
            opt.tol = 0.05;
            
            opt = tb_optparse(opt, varargin);
            
            %g2 = PGraph(pg.graph);  % deep copy
            
            lambda = opt.lambda;
            
            for i=1:opt.iterations
                if opt.animate
                    if ~opt.retain
                        clf
                    end
                    g2.plot();
                    pause(0.5)
                end
                
                tic
                
                [Xnew,energy] = ba.solve(X, lambda);
                
                dt = toc;
                enew = ba.errors(Xnew);
                fprintf('Total cost %g (solved in %.2g sec)', enew, dt);

                
                % are we there yet?
                if enew < opt.tol
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
            fprintf('\n %d iterations in %.1f seconds\n', i, tf-t0);
            XX = X;
        end
    end % methods
    
    methods(Static=true)
        % Jacobians for bundle adjustment
        
        function generateModel
            % intrinsics
            syms u0 v0 rhox rhoy f real
            K = [f/rhox 0 u0; 0 f/rhoy v0; 0 0 1]
                       
            % world point
            P = sym('P', [3,1], 'real');
            
            % camera translation
            t = sym('T', [3,1], 'real');
            
            % camera rotation
            % - scalar part of quaternion is a function of the vector part
            %   which we keep as the camera rotation state
            syms qs qx qy real
            qz = sym('qz', 'real'); % since qz is a builtin function :(
            qs = sqrt(1- qx^2 - qy^2 - qz^2);
            R = UnitQuaternion.q2r([qs qx qy qz]);

            % camera projection model
            %  - homogeneous
            uvw = K * (R'*P - R'*t);
            
            %  - Euclidean
            uv = uvw(1:2) ./ uvw(3);
            uv = simplify(uv)
            
            % compute the Jacobians
            A = jacobian(uv, [t' qx qy qz]);  % wrt camera pose
            B = jacobian(uv, P);              % wrt landmark position
            
            % generate a function
            fprintf('creating file --> cameraModel.m\n');
            matlabFunction(uv, A, B, 'file', 'cameraModel', ...
                'Vars', [t(1) t(2) t(3) qx qy qz P(1) P(2) P(3) f rhox rhoy u0 v0]);

            %% quaternion vector update
            syms qs2 qx2 qy2 qz2 real
            qs2 = sqrt(1-qx2^2 - qy2^2 - qz2^2);
            
            % create two quaternions, scalar parts are functions of vector parts
            Q1 = Quaternion([qs qx qy qz]);
            Q2 = Quaternion([qs2 qx2 qy2 qz2]);
            
            % multiply them
            QQ = Q1 * Q2;

            % create a function to compute the vector part, as a function of
            % the two input vector parts
            fprintf('creating file --> qvmul.m\n');
            matlabFunction(QQ.v, 'file', 'qvmul', 'Vars', [qx qy qz qx2 qy2 qz2]);
        end
        
        function testModel
            
            cam = CentralCamera('default' );
            
            t = [0 0 0]';
            R = rpy2tr(0.3, 0.3, 0.4);
            q = UnitQuaternion(R).double
            
            T =  transl(t) * R;
            
            P = [1 2 5]';
            [p0,vis] = cam.project(P, 'Tcam', T);
            
            d = 0.00001;
            dd = d*eye(3);
            
            [UVS,JAS,JBS] = cameraModel(t(1), t(2), t(3), q(2), q(3), q(4), ...
                P(1), P(2), P(3), ...
                cam.f, cam.rho(1), cam.rho(2), cam.u0, cam.v0);
            
            %% projection
            fprintf('-- test projection function\n');
            fprintf(' toolbox\n');
            p0
            fprintf(' symbolic\n');
            UVS
            
            assert( max(abs(UVS-p0)) < 0.1, 'Error with projection equation')
            
            %% jacobian B
            fprintf('-- Jacobian B\n');
            fprintf(' toolbox\n');
            p1 = cam.project( bsxfun(@plus, P, dd), 'Tcam', T);
            
            JB = bsxfun(@minus, p1, p0) / d
            
            % symbolically derived result
            fprintf(' symbolic\n');
            JBS
            assert( max(max(abs(JBS-JB))) < 0.1, 'Error with Jacobian B equation')

            %% jacobian A
            
            R = UnitQuaternion(q).R;
            T =  rt2tr(R, t);
            
            JA = [];
            for i=1:3
                T =  rt2tr(R, t+dd(:,i));
                p = cam.project(P, 'Tcam', T);
                JA = [JA (p-p0)/d];
            end
            
            for i=1:3
                qq = q(2:4);
                qq(i) = qq(i) + d;
                qs = sqrt(1-sum(qq.^2));
                RR = UnitQuaternion([qs qq]).R;
                T =  rt2tr(RR, t);
                p = cam.project(P, 'Tcam', T);
                JA = [JA (p-p0)/d];
            end
            
            fprintf('-- Jacobian A\n');
            fprintf(' toolbox\n');
            JA
            
            % symbolically derived result
            fprintf(' symbolic\n');
            JAS
            assert( max(max(abs(JAS-JA))) < 0.1, 'Error with Jacobian A equation')

            %% test the quaternion vector update
            fprintf('-- Quaternion vector update\n');
            
            %numerically
            q1 = UnitQuaternion.rpy(.2, .3, .4)
            q2 = UnitQuaternion.rpy(.3, -0.2, 0.2)
            qq = q1*q2
            qq.v
            
            % symbolic solution
            args = num2cell([q1.v q2.v]);
            qvs = qvmul(args{:})
            
            assert( max(abs(qq.v-qvs)) < 1e-3, 'Error with quaternion-vector equation')
        end

    end
end % classdef
