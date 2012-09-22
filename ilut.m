%ILUT Apply lookup table to image
%
% OUT = ILUT(IM, LUT) is an image the same size as IM (NxMxP) where each
% pixel value is mapped through the lookup table LUT (Kx1).  
%
% OUT = ILUT(IM, LUT) is an image (NxMxP) formed by mapping the image
% of index values IM (NxM) through the lookup table LUT (KxP).  An input
% pixel value of I is mapped to an output value taken from the (I+1)'th row
% of LUT.
%
% Notes::
% - If IM is an integer image then pixel value of 0 is mapped through LUT(1)
%   and so on.  The LUT must be long enough to accomodate the maximum pixel
%   value in IM.
% - If IM is a double image with pixels in the range [0,1] then the lookup table
%   is assumed to also span the range [0,1] irrespective of the number of 
%   elements it contains, and interpolation is used.
% - Various MATLAB color map generating functions can be used.
%
% See also IGAMMA, INORMHIST.


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
function out = ilut(im, lut)
    if numcols(lut) > 1
        % colormap lookup

        if ~isinteger(im)
            error('for colormap lookup mode the image must be integer');
        end
        if ndims(im) > 2
            error('for colormap lookup mode the image must be 2D');
        end
        maxval = max(im(:));
        if maxval >= numrows(lut)
            error('maximum value of image is %d, LUT (%d rows) too small', maxval, numrows(lut));
        end

        col = im2col(im);
        out = lut(col+1,:);
        out = col2im(out, im);
    else
        % map pixel values through LUT vector
    
        if isinteger(im)
            % use table lookup
            maxval = max(im(:));
            if maxval >= numrows(lut)
                error('maximum value of image is %d, LUT (%d rows) too small', maxval, numrows(lut));
            end
            out = lut(im+1);
        else
            % floating point image, use interpolation
            x = linspace(0, 1, length(lut))';
            out = interp1(x, lut, im(:), 'nearest');
            out = reshape(out, size(im));
        end
    end
