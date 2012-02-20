

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
function [lmax,x,y] = localmax(im, n)

	% get index of local maxima
	maxima = find( im > imorph(im, [1 1 1; 1 0 1; 1 1 1], 'max') );

	% sort into descending order
	[lmax,i] = sort( -im(maxima) );
	lmax = -lmax;

	% take the first n maxima
	if nargin > 1,
		lmax = lmax(1:n);
		i = i(1:n);
	end

	% convert back to subscripts
	if nargout > 1,
		[y,x] = ind2sub(size(im), maxima(i));
	end
