%LOADSTEREO load & unmultiplex stereo image
%
%	[left,right] = loadstereo(im)
%	left = loadstereo(im)




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
function [L,R] = loadstereo(varargin)

	im = loadpgm(varargin{:});
	left = im(2:2:end,:);
	right = im(1:2:end,:);

	switch nargout,
	case {0},
		subplot(121)
		colormap(gray(256));
		image(left);

		subplot(122)
		colormap(gray(256));
		image(right);
	case {1},
		L = left;
	case {2}
		L = left;
		R = right;
	end
