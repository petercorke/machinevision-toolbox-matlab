%ISOBEL Sobel edge detector
%
% OUT = ISOBEL(IM) is an edge image computed using the Sobel edge operator
% applied to the image IM.  This is the norm of the vertical and horizontal 
% gradients at each pixel.  The Sobel kernel is:
%      | -1  0  1|
%      | -2  0  2|
%      | -1  0  1|
%
% OUT = ISOBEL(IM,DX) as above but applies the kernel DX and DX' to compute
% the horizontal and vertical gradients respectively.
%
% [GX,GY] = ISOBEL(IM) as above but returns the gradient images.
%
% [GX,GY] = ISOBEL(IM,DX) as above but returns the gradient images.
%
% Notes::
% - Tends to produce quite thick edges.
% - The resulting image is the same size as the input image.
%
% See also KSOBEL, ICANNY, ICONV.



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

function [o1,o2] = isobel(i, Dx)

    if nargin < 2,
        sv = -[ -1 -2 -1
            0 0 0
            1 2 1];
        sh = sv';
    else
        % use a smoothing kernel if sigma specified
        sh = Dx;
        sv = Dx';
    end

    ih = conv2(i, sh, 'same');
    iv = conv2(i, sv, 'same');

    % return grandient components or magnitude
    if nargout == 1,
        o1 = sqrt(ih.^2 + iv.^2);
    else
        o1 = ih;
        o2 = iv;
    end
