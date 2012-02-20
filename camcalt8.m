% optimization target function used by camcalt




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
function e = eightb(z, params, xw, yw, zw, X, Y)
	%
	% unpack the unknowns
	%
	f = z(1);
	Tz = z(2);
	k1 = z(3);

	%
	% unpack the scalar parameters
	%
	r4 = params(1);
	r5 = params(2);
	r6 = params(3);
	r7 = params(4);
	r8 = params(5);
	r9 = params(6);
	dx = params(7);
	dy = params(8);
	sx = params(9);
	Ty = params(10);

	rsq = (dx*X).^2 + (dy*Y).^2;
	res = (dy*Y).*(1+k1*rsq).*(r7*xw+r8*yw+r9*zw+Tz) - f*(r4*xw+r5*yw+r6*zw+Ty);
	e = norm(res, 2);

%	fprintf('%e [%f %e %e]\n', norm(res),f*1000,Tz*1000,k1);
