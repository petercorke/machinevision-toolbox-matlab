%ILOGPOLAR Log-polar transform
%
% OUT = ILOGPOLAR(IM, OPTIONS) is a log-polar representation of the
% image IM.  Every pixel in IM is rendered at the coordinate (log(r), theta)
% in the output image OUT (WxH), and where (r,theta) is the polar coordinate 
% of the correspondingin pixel in the image IM.
%
% [OUT,VTH,VLOGP] = ILOGPOLAR(IM, OPTIONS) as above but also returns
% vectors VTH (1xW) and VLOGP (1xH) with the correspond theta and log(r)
% values.
%
% ILOGPOLAR(IM, OPTIONS) as above but the image is displayed. 
%
% Options::
% 'centre',C   Coordinate of the point from which radial distance is 
%              computed (default centre of the image).
% 'ntheta',N   Number of pixels in the theta direction (default 400).
% 'nlogp',N    Number of pixels in the log-p direction (default 400).
%
% Notes::
% - The log-polar image has the properties that:
%   - a rotation of the image about the centre point becomes a horizontal shift.
%   - a scale of the image (zoom) becomes a vertical shift.
%
% References::
% - http://en.wikipedia.org/wiki/Log-polar_coordinates
%
% See also IWARP.

function [out, vth, vlogp] = ilogpolar(im, varargin)

    opt.centre = isize(im)/2;
    opt.ntheta = 400;
    opt.nlogp = 400;
    opt = tb_optparse(opt, varargin);

    % create coordinate matrices for the output image
    [U,V] = imeshgrid(opt.ntheta, opt.nlogp);

    % scale U coordinate to range 0 to 2pi
    th = U/numcols(U) * 2*pi;

    % compute the maximum radius
    [w h] = isize(im);
    corners = [1 w w 1; 1 1 h h];
    d = colnorm( bsxfun(@minus, corners, opt.centre(:)));

    % scale V coordinate to range 0 to max(log(radius))
    logp = V/numrows(V) * log(max(d));

    % now compute inverse log-polar transform, which is very elegant
    % using complex numbers
    XY = exp(logp + i*th) + opt.centre(1) + i*opt.centre(2); 

    % now warp
    out_ = iwarp(im, real(XY), imag(XY) );

    if nargout == 0
        idisp(out_, 'ynormal', 'xydata', {th(1,:), logp(:,1)} );
        xlabel('\theta'); ylabel('log(r)');
    else
        out = out_;
        if nargout > 1
            vth = th(1,:);
        end
        if nargout > 2
            vlogp = logp(:,1);
        end
    end
