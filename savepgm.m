%SAVEPGM	Write a PGM format file
%
%	SAVEPGM(filename, im)
%
%	Saves the specified image array in a binary (P5) format PGM image file.
% 
% SEE ALSO:	loadpgm
%



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

function savepgm(fname, im)

	fid = fopen(fname, 'w');
	if isempty(fid),
		error('cant open file for write');
	end
	[r,c] = size(im');
	fprintf(fid, 'P5\n');
	fprintf(fid, '%d %d\n', r, c);
	fprintf(fid, '255\n');
	fwrite(fid, im', 'uchar');
	fclose(fid)
