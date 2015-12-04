%ICANNY	Canny edge detection
%
% E  =  ICANNY(IM, OPTIONS) is an edge image obtained using the Canny edge
% detector algorithm.  Hysteresis filtering is applied to the gradient
% image: edge pixels > th1 are connected to adjacent pixels > th0, those
% below th0 are set to zero.
%
% Options::
%  'sd',S    set the standard deviation for smoothing (default 1)
%  'th0',T   set the lower hysteresis threshold (default 0.1 x strongest edge)
%  'th1',T   set the upper hysteresis threshold (default 0.5 x strongest edge)
%
% Reference::
% - "A Computational Approach To Edge Detection",
%   J. Canny,
%   IEEE Trans. Pattern Analysis and Machine Intelligence, 8(6):679–698, 1986.
%
% Notes::
% - Produces a zero image with single pixel wide edges having non-zero values.
% - Larger values correspond to stronger edges.
% - If th1 is zero then no hysteresis filtering is performed.
% - A color image is automatically converted to greyscale first.
%
%
% See also ISOBEL, KDGAUSS.

% http://robotics.eecs.berkeley.edu/~sastry/ee20/cacode.html

function E  =  icanny(I, varargin)
    
    % convert color image to greyscale
    if iscolor(I)
        I  =  imono(I);
    end
    
    opt.sigma  =  1;
    opt.th1  =  0.1;
    
    opt  =  tb_optparse(opt, varargin);
    
    
    % compute gradients
    dg  =  kdgauss(opt.sigma);
    Ix  =  abs(conv2(I, dg, 'same'));		% X/Y edges
    Iy  =  abs(conv2(I, dg', 'same'));
    
    
    % Norm of the gradient (Combining the X and Y directional derivatives)
    grad = sqrt(Ix.*Ix+Iy.*Iy);
    
    
    % Thresholding
    gmax = max(grad(:));
    %gmin = min(grad(:));
    gmin = 0;
    level = opt.th1*(gmax-gmin)+gmin;
    Ithresh = max(grad,level);
    
    
    E = ones(size(I)) * gmin;
    
    [U,V] = imeshgrid(Ithresh);
    k = Ithresh(:) > level;
    Z1 = interp2(U, V, Ithresh, U(k)+Ix(k)./grad(k), V(k)+Iy(k)./grad(k) );
    Z2 = interp2(U, V, Ithresh, U(k)-Ix(k)./grad(k), V(k)-Iy(k)./grad(k) );
    
    k2 = Ithresh(k) >= Z1 & Ithresh(k) >= Z2;
    i = find(k);
    i = i(k2);
    E(i) = gmax;
    
end