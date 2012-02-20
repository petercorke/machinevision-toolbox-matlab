%SAVEPNM	Write a PNM format file
%
%	SAVEPNM(filename, image)
%
%	Saves the image in a binary greyscale (P5) or color (P6)
%	format image file depending on the number of planes.
%
%	If the maximum pixel value is less than 1 assume image is
%	normalized in range 0-1, so values are scaled up to range 0-255.
%
% SEE ALSO:	loadpgm loadppm



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

function savepnm(fname, im, comment)

	[r,c,p] = size(im);

	fid = fopen(fname, 'w');

	% if the maximum pixel value is less than 1 assume image is
	% normalized in range 0-1.
	if max(im(:)) <= 1,
		im = istretch(im, 255);
	end
	switch p,
	case 1,
		fprintf(fid, 'P5\n');
		if nargin == 3,
			fprintf(fid, '#%s\n', comment);
		end
		fprintf(fid, '%d %d\n', c, r);
		fprintf(fid, '255\n');
		im = im';
	case 3,
		fprintf(fid, 'P6\n');
		if nargin == 3,
			fprintf(fid, '#%s\n', comment);
		end
		fprintf(fid, '%d %d\n', c, r);
		fprintf(fid, '255\n');

		% rearrange the data for writing in one hit
		R = im(:,:,1);
		G = im(:,:,2);
		B = im(:,:,3);
		R = R';
		G = G';
		B = B';
		im = [R(:)'; G(:)'; B(:)'];
	otherwise,
		fclose(fid)
		error('Image must have 1 or 3 planes');
	end

	fwrite(fid, im, 'uchar');
	fclose(fid);
