%SAVEPPM	Write a PPM format file
%
%	SAVEPPM(filename, r, g, b)
%	SAVEPPM(filename, rgb)
%
%	Saves the specified red, green and blue planes in a binary (P6)
%	format PPM image file.
%
% SEE ALSO:	loadppm



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


function saveppm(fname, R, G, B)

	if nargin == 2,
		z = R;
		R = z(:,:,1);
		G = z(:,:,2);
		B = z(:,:,3);
	end
	[r,c] = size(R);
	fid = fopen(fname, 'w');
	fprintf(fid, 'P6\n');
	fprintf(fid, '%d %d\n', c, r);
	fprintf(fid, '255\n');
	R = R';
	G = G';
	B = B';
	im = [R(:)'; G(:)'; B(:)'];

	%im = reshape(c,r);  %commented - usage wrong needs 3 elements ...sunil
	fwrite(fid, im, 'uchar');
	fclose(fid);
