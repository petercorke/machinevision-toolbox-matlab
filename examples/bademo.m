% moving camera bundle adjustment problem

ncams = 10;  % number of cameras
npts = 110;  % number of landmark points
visprob = 0.65;  % probability of camera seeing a landmark
pixnoise = 0.5; % standard deviation of Gaussian noise added to camera projections
Tshift = SE3(-0.2, 0, 0);  % horizontal shift of camera at each view

% create a camera
cam = CentralCamera('default', 'noise', pixnoise)

% setup a bundle adjustment problem
ba = BundleAdjust(cam);

% create the camera nodes, all at the origin, and keep their handles ch(i)
for i=1:ncams
    if i == 1
        ch(i) = ba.add_camera( SE3, 'fixed' );
    else
        ch(i) = ba.add_camera( SE3 );
    end
end

% create a working volume containing npts random points
% x -3 -> 1
% y -2 -> 2
% z  4 -> 8
randinit
P = bsxfun(@plus, 2 * 2*(rand(3, npts) - 0.5), [-1, 0 , 6]');

% create the landmark nodes and keep their handles lh(j)
for j=1:numcols(P)
    lh(j) = ba.add_landmark( P(:,j) );
end

% slide the camera in the x-direciton
T = SE3;
for i=1:ncams
    % project all landmarks for this camera position
    [p, visible] = cam.project(P, 'pose', T);
    
    % find the subset of points that are visible
    for j=find(visible)'
        % add to the problem if visible
        if rand < visprob % with a probability
            ba.add_projection(ch(i), lh(j), p(:,j));
        end
    end
    T = T .* Tshift; % shift the camera
end

% display the problem summary
ba

figure(1)
ba.plot()

pause

% get the state vector
X = ba.getstate();

% get the initial error
ba.errors(X)

% display the Hessian
figure(2)
ba.spyH(X)
title('Hessian matrix sparsity')

% solve the problem
baf = ba.optimize(X);

figure(3)
baf.plot()
