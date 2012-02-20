%MKSQ	Make a test pattern comprising squares
%
%	im = MKSQ(w, numsq)
%
%	Create a square output image (W x W) with NUMSQ filled squares along 
%	the diagonal.  Pixels in the squares are set to one, all others to zero.
%
% SEE ALSO:	mkline, ihough, xyhough
%



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
function im = mksq(w, nsq)
	im = zeros(w,w);	% make the image

	k = 2^(nsq+1);		% a useful quantity
	ws = w / k;		% each square is 2ws x 2ws

	for j=1:4:k,		% for each square
		l = j*ws;		% left coord
		r = (j+2)*ws-1;		% right coord
		im(l:r,l:r) = ones(2*ws,2*ws);	% then fill it
	end
		
