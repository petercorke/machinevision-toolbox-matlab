%ICONVOLVE Image convolution
%
% C = ICONVOLVE(IM, K, OPTIONS) is the convolution of image IM with the kernel K. 
%
% ICONVOLVE(IM, K, OPTIONS) as above but display the result.
%
% Options::
%  'same'    output image is same size as input image (default)
%  'full'    output image is larger than the input image
%  'valid'   output image is smaller than the input image, and contains only
%            valid pixels
%
% Notes::
% - If the image is color (has multiple planes) the kernel is applied to 
%   each plane, resulting in an output image with the same number of planes.
% - If the kernel has multiple planes, the image is convolved with each
%   plane of the kernel, resulting in an output image with the same number of
%   planes.
% - This function is a convenience wrapper for the MATLAB function CONV2.
% - Works for double, uint8 or uint16 images.  Image and kernel must be of
%   the same type and the result is of the same type.
% - This function replaces iconv().
%
% See also CONV2.


% Copyright (C) 1993-2011, by Peter I. Corke
%
% This file is part of The Machine Vision Toolbox for Matlab (MVTB).
% 
% MVTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% MVTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with MVTB.  If not, see <http://www.gnu.org/licenses/>.
function out = iconvolve(im, K, opt)

    if nargin < 3
        opt = 'same';
    end

    if ~isfloat(im)
        im = double(im);
    end
    if ~isfloat(K)
        K = double(K);
    end
    if size(im,3) == 1 && size(K,3) == 1
        % simple case, convolve image with kernel
        C = conv2(im, K, opt);
    elseif size(im,3) > 1 && size(K,3) == 1
        for k=1:size(im,3)
            % image has multiple planes
            C(:,:,k) = conv2(im(:,:,k), K, opt);
        end
    elseif size(im,3) == 1 && size(K,3) > 1
        for k=1:size(K,3)
            % kernel has multiple planes
            C(:,:,k) = conv2(im, K(:,:,k), opt);
        end
    else
        error('MVTB:iconvolve:badarg', 'image and kernel cannot both have multiple planes');
    end
    
    if nargout == 0
        idisp(C);
    else
        out = C;
    end
end

