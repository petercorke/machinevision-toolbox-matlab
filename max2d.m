%MAX2d	Maximum of image
%
%	[r,c] = max2d(image)
%
%	Return the interpolated coordinates (r,c) of the greatest peak in image.
%
% SEE ALSO:	ihough xyhough



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


function [r,c,m] = max2d(im)

	ncols = numcols(im);
	nrows = numrows(im);

	[mx,where] = max(im(:));

    [r,c] = ind2sub(size(im), where);
    
    m = mx;
    
	%[r,c,mx2]
	% now try to interpolate the peak over a 3x3 window

	% can't interpolate if against an edge
	if (c>1) & (c<ncols) & (r>1) & (r<nrows),
		dx = [
			c-1 c c+1
			c-1 c c+1
			c-1 c c+1];
		dy = [
			r-1 r-1 r-1
			r   r  r
			r+1   r+1  r+1];

		p = im(r-1:r+1,c-1:c+1);
		c = sum(sum(dx.*p)) / sum(sum(p));
		r = sum(sum(dy.*p)) / sum(sum(p));
    end
