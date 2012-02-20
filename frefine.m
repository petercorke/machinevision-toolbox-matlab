%FREFINE refine estimate of fundamental matrix
%
% fr = frefine(F, uv1, uv2)
%
%  Return a refined estimate of fundamental matrix using non-linear
% optimization and enforcing the rank-2 constraint.



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

function fr = frefine(F, uv1, uv2)

	A = [];
	for i=1:numrows(uv1),
		a = [	uv1(i,1)*uv2(i,1)
			uv1(i,2)*uv2(i,1)
			uv2(i,1)
			uv1(i,1)*uv2(i,2)
			uv1(i,2)*uv2(i,2)
			uv2(i,2)
			uv1(i,1)
			uv1(i,2)
			1
		];
		A = [A; a'];
	end
	f = F';
	f = f(:);
	fprintf('Initial residual is %g\n', norm(A * f));
	fprintf('Initial determinant is %g\n', det(F));

	options = optimset('MaxFunEvals', 10000, ...
		'LevenbergMarquardt', 'on', ...
		'TolFun', 1e-16, ...
		'TolCon', 1e-16, ...
		'LargeScale', 'off' ...
		);
	fr = fmincon(@fun, f, [], [], [], [], [], [], ...
		@nlfun, options, A);
	fprintf('Final residual is %g\n', norm(A * fr));
	fr = reshape(fr, 3, 3)';
	det(fr)
	fprintf('Final determinant is %g\n', det(fr));
		
function e = fun(x, A)
	e = norm(A * x);

function [c,ceq] = nlfun(x, A)

	ceq = abs( det(reshape(x, 3, 3)) );
	c = [];
