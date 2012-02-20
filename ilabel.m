%ILABEL Label an image
%
% L = ILABEL(IM) performs connectivity analysis on the image IM and returns a
% label image L, same size as IM, where each pixel value represents the integer
% region label assigned to the corresponding pixel in IM.  Region labels are in
% the range 1 to M.
%
% [L,M] = ILABEL(IM) as above but returns the value of the maximum
% label value.
%
% [L,M,PARENTS] = ILABEL(IM) as above but also returns region hierarchy
% information.  The value of PARENTS(I) is the label of the parent or 
% enclosing	region of region I.  A value of 0 indicates that the region has
% no single enclosing region, for a binary image this means the region
% touches the edge of the image, for a multilevel image it means that it
% touches more than one other region.
%
% [L,MAXLABEL,PARENTS,CLASS] = ILABEL(IM) as above but also returns the class
% of pixels within each region.  The value of CLASS(I) is the value of the
% pixels that comprise region I.
%
% [L,MAXLABEL,PARENTS,CLASS,EDGE] = ILABEL(IM) as above but also returns the
% edge-touch status of each region.  If EDGE(I) is 1 then region I touches
% edge of the image, otherwise it does not.
%
% Notes::
% - Is a MEX file.
% - The image can be binary or multi-level
% - Connectivity is performed using 4 nearest neighbours by default. To use
%   8-way connectivity pass a second argument of 8, eg. ILABEL(IM, 8).
% - This is a "low level" function, IBLOBS is a higher level interface.
% - Connectivity is only performed within a 2D image.
%
% See also IBLOBS, IMOMENTS.



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
%
% http://www.petercorke.com

if ~exist('ilabel', 3)
    error('you need to build the MEX version of ilabel, see vision/mex/README');
end
