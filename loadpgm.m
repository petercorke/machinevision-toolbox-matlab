%LOADPGM	Load a PGM image
%
%	I = loadpgm(filename)
%
%	Returns a matrix containing the image loaded from the PGM format
%	file filename.  Handles ASCII (P2) and binary (P5) PGM file formats.
%
%	If the filename has no extension, and open fails, a '.pgm' will
%	be appended.  If the file cannot be opened it returns [].
%
%	Wildcards are allowed in file names.  If multiple files match
%	a 3D image is returned where the last dimension is the number
%	of images contained.
%
%	I = loadpgm
%
%	Presents a file selection GUI from which the user can pick a file.
%	Uses the same path as previous call.
%
%	Second return argument is the image creation time that comes
% from a TIMESPEC header comment (local convention).



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


function [I,t] = loadpgm(file)
	t = [];
	fid = fopen(filename, 'r');
	if fid < 0,
		fid = fopen([filename '.pgm'], 'r');
	end
	if fid < 0,
		I = [];
		error(['Couldn''t open file ' filename]);
	end
		
	white = [' ' 9 10 13];	% space, tab, lf, cr
	white = setstr(white);

	% read the PX header
	magic = fread(fid, 2, 'char');

	%  read cols and process any comment field before hand
	while 1
		c = fread(fid,1,'*char');
		if c == '#',
			comment = fgetl(fid);
			time = sscanf(comment, ' TIMESPEC %d %d');
			if length(time) == 2,
				t = time(1) + time(2)*1e-9;
			end
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	cols = fscanf(fid, '%d', 1);

	%  read rows and process any comment field before hand
	while 1
		c = fread(fid,1,'*char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	rows = fscanf(fid, '%d', 1);

	%  read maxval and process any comment field before hand
	while 1
		c = fread(fid,1,'*char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	maxval = fscanf(fid, '%d', 1);

	% read the newline
	c = fread(fid,1,'*char');

	% Process the header info and read the image
	if magic(1) == 'P',
		if magic(2) == '2',
			fprintf('%s: ASCII PGM file (%d x %d)\n', filename, rows, cols)
			I = fscanf(fid, '%d', [cols rows])';
		elseif magic(2) == '5',
			fprintf('%s: binary PGM file (%d x %d)\n', filename, rows, cols)
			if maxval == 1,
				fmt = 'unint1';
			elseif maxval == 15,
				fmt = 'uint4';
			elseif maxval == 255,
				fmt = 'uint8';
			elseif maxval == 2^16-1,
				fmt = 'uint16';
			elseif maxval == 2^32-1,
				fmt = 'uint32';
			end
			I = fread(fid, [cols rows], fmt)';
		else
			disp('Not a PGM file');
		end
	end
	fclose(fid);
