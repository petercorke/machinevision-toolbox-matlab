%IM2COL Convert an image to pixel per row format
%
% OUT = IM2COL(IM) returns the image (HxWxP) as a pixel vector (NxP) where
% each row is a pixel value (1xP).  The pixels are in image column order 
% and there are N=WxH rows.
%
% See also COL2IM.



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

function c = im2col(im)

    im = shiftdim(im, 2);

    if ndims(im) == 3,
        c = reshape(im, 3, [])';
    else
        c = reshape(im, 1, [])';
    end
