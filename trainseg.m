%TRAINSEG	Interactively train a color segmentation
%
%	map = trainseg(im)
%
%	Two windows are displayed, one the bivariant histogram in
%	normalized (r,g) coordinates, the other the original image.
%
%	For each pixel selected and clicked in the original image a point
%	is marked in the bivariant histogram.  By selecting numerous points
%	in the color region of interest, its extent in the (r,g) plane 
%	develops.
%
%	This map can be smoothed, expanded and filled in using morphological
%	operations.
%
% SEE ALSO: colorseg imorph



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
function map = colorseg(im)

	% convert image to (r,g) coordinates
	y = sum(im, 3);
	r = round( im(:,:,1) ./ y * 255);
	g = round( im(:,:,2) ./ y * 255);

	% display the original image

	% create and display the map
	map = zeros(256, 256);
	hm = figure
	set(gcf, 'Units', 'normalized', 'Position', [0.1 0.5 0.8 0.4])
	subplot(121)
	image(im)
	axis('equal')
	title('input image')

	subplot(122)
	image(map)
	axis('equal')
	xlabel('r');
	ylabel('g');
	colormap(gray(2));
	title('segmentation map')

	while 1,
		subplot(121)
		[y,x] = ginput(1);
		if isempty(y),
			break;
		end
		x = round(x);
		y = round(y);
		map(r(x,y), g(x,y)) = 256;
		subplot(122)
		image(map)
		drawnow
	end

	map = map';
