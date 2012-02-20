%FLATFIELD	correct lighting unevenness
%
%	iff = flatfield(im)
%	iff = flatfield(im, mask)
%
% A least squares method is used to fit a plane to the image data. The value
% of the lighting function is returned.
%
% If mask is given a maximum filter of dimension mask x mask is run over the
% data prior to fitting.



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

function iff = flatfield(im, mask)

% equation is I = ax + by + c

	im = imorph(im, ones(mask), 'max');

	[nr,nc] = size(im);
	[X,Y] = meshgrid(1:nc,1:nr);

	A = [ X(:) Y(:) ones(nr*nc,1)];
	b = im(:);

	th = A\b;

	resid = A*th - b;
	fprintf('Residual = %f grey levels\n', max(abs(resid)));

	iff = th(1)*X + th(2)*Y + th(3);

