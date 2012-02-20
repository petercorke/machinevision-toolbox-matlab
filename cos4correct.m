

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
function [imc, cf] = cos4correct(im, mask)

% If mask is given a maximum filter of dimension mask x mask is run over the
% data prior to fitting.


	if nargin > 1,
		fprintf('Morphological maximum filter');
		im = imorph(im, ones(mask), 'max');
		idisp(im)
		pause
	end

	[h,w] = size(im);
	[X,Y] = meshgrid(1:w,1:h);

	% Parameter vector:
	%	P(1)	xc
	%	P(2)	yc
	%	P(3)	xs
	%	P(4)	ys
	%
	func = inline(...
	  'var(im./cos(sqrt( ((y-P(2)).^2)*P(4)+((x-P(1)).^2)*P(3) )).^4)', ...
		'P', 'x', 'y', 'im');

	% assume center of fall-off is middle of image plane, and 45deg FOV
	P0 = [w/2 h/2 pi/4/w/64 pi/4/h/64];
	Pmin = [w/4 h/4 P0(3:4)/8];
	Pmax = [3*w/4 3*h/4 P0(3:4)*8];


	fprintf('\rOptimizing                  ');
	opt = optimset('fmincon');
	opt = optimset(opt, 'Display', 'iter');
	P = fmincon(func, P0, [], [], [], [], Pmin, Pmax, [], opt, ...
		X(:), Y(:), im(:));

	cf = cos(sqrt( (Y(:)-P(2)).^2*P(4)+(X(:)-P(1)).^2*P(3) )).^4;

	cf = reshape(cf, size(im));
	idisp(cf);

	imc = im ./ cf;

	pause
	idisp(imc)
