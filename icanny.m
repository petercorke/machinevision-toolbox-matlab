%ICANNY	Canny edge detection
%
% E = ICANNY(IM, OPTIONS) returns an edge image using the Canny edge detector.  
% The edges within IM are marked by non-zero values in E, and larger values
% correspond to stronger edges.
%
% Options::
%  'sd',S    set the standard deviation for smoothing (default 1)
%  'th0',T   set the lower hysteresis threshold (default 0.1 x strongest edge)
%  'th1',T   set the upper hysteresis threshold (default 0.5 x strongest edge)
%
% Author::
% Oded Comay, Tel Aviv University, 1996-7.
%
% See also ISOBEL, KDGAUSS.

function E = icanny(I, varargin)

    opt.sd = 1;
    opt.th0 = 0.1;
    opt.th1 = 0.5;

    opt = tb_optparse(opt, varargin);

    x= -5*opt.sd:opt.sd*5; 
    g = exp(-0.5/opt.sd^2*x.^2); 		% Create a normalized Gaussian
    g = g(g>max(g)*.005); g = g/sum(g(:));
    dg = diff(g);				% Gaussian first derivative

    dx = abs(conv2(I, dg, 'same'));		% X/Y edges
    dy = abs(conv2(I, dg', 'same'));

    [ny, nx] = size(I);
                        % Find maxima 
    dy0 = [dy(2:ny,:); dy(ny,:)]; dy2 = [dy(1,:); dy(1:ny-1,:)];
    dx0 = [dx(:, 2:nx) dx(:,nx)]; dx2 = [dx(:,1) dx(:,1:nx-1)];
    peaks = find((dy>dy0 & dy>dy2) | (dx>dx0 & dx>dx2));
    e = zeros(size(I));
    e(peaks) = sqrt(dx(peaks).^2 + dy(peaks).^2); 

    e(:,2)    = zeros(ny,1);    e(2,:) = zeros(1,nx);	% Remove artificial edges
    e(:,nx-2) = zeros(ny,1); e(ny-2,:) = zeros(1,nx);
    e(:,1)    = zeros(ny,1);    e(1,:) = zeros(1,nx);
    e(:,nx)   = zeros(ny,1);   e(ny,:) = zeros(1,nx);
    e(:,nx-1) = zeros(ny,1); e(ny-1,:) = zeros(1,nx);
    e = e/max(e(:));

    if opt.th1  == 0, E = e; return; end			 % Perform hysteresis
    E(ny,nx) = 0;

    p = find(e >= opt.th1);
    while length(p) 
      E(p) = e(p);
      e(p) = zeros(size(p));
      n = [p+1 p-1 p+ny p-ny p-ny-1 p-ny+1 p+ny-1 p+ny+1]; % direct neighbors
      On = zeros(ny,nx); On(n) = n;
      p = find(e > opt.th0 & On);
    end
