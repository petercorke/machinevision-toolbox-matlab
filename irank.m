%IRANK Rank filter
%
% OUT = IRANK(IM, ORDER, SE) is a rank filtered version of IM.  Only 
% pixels corresponding to non-zero elements of the structuring element SE
% are ranked and the ORDER'th value in rank becomes the corresponding output 
% pixel value.  The highest rank, the maximum, is ORDER=1.
%
% OUT = IMORPH(IMAGE, SE, OP, NBINS) as above but the number of histogram
% bins can be specified.
%
% OUT = IMORPH(IMAGE, SE, OP, NBINS, EDGE) as above but the processing of edge 
% pixels can be controlled.  The value of EDGE is:
% 'border'   the border value is replicated (default)
% 'none'     pixels beyond the border are not included in the window
% 'trim'     output is not computed for pixels whose window crosses
%            the border, hence output image had reduced dimensions.
% 'wrap'     the image is assumed to wrap around
%
% Examples::
%
% 5x5 median filter:
%    irank(im, 12, ones(5,5));
%
% 3x3 non-local maximum:
%    se = ones(3,3); se(2,2) = 0;
%    im > irank(im, 1, se);
%
% Notes::
% - Is a MEX file.
% - A histogram method is used with NBINS (default 256).
%
% See also IMORPH, IVAR, IWINDOW.



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

if ~exist('irank', 3)
    error('you need to build the MEX version of irank, see vision/mex/README');
end
