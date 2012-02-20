

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
function [r,g] = colorseg2(im)

	%idisp(im);

	[x,y] = ginput;

	x = round(x);
	y = round(y);

	rgb = sum(im, 3);
	r = im(:,:,1) ./ rgb;
	g = im(:,:,2) ./ rgb;
	b = im(:,:,3) ./ rgb;

	rr = [];
	gg = [];
	bb = [];
	for i=1:length(x),
		rr = [rr; r(y(i),x(i))];
		gg = [gg; g(y(i),x(i))];
		bb = [bb; b(y(i),x(i))];
	end
	plot(rr, gg, '.');
	xlabel('r');
	ylabel('g');
	pause
	plot(rr, bb, '.');
	xlabel('r');
	ylabel('b');

