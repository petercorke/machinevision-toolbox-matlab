%LOADPPM	Load a PPM image
%
%	I = loadppm(filename)
%	I = loadppm(filename, n)
%
%	Returns a matrix containing the image loaded from the PPM format
%	file filename.  Handles ASCII (P3) and binary (P6) PGM file formats.
%	Result is returned as a 3 dimensional array where the last index
%	is the color plane.
%
%	If the filename has no extension, and open fails, a '.ppm' will
%	be appended.  If the file cannot be opened it returns [].
%
%	Wildcards are allowed in file names.  If multiple files match
%	a 4D image is returned where the last dimension is the number
%	of images contained.
%
%	I = loadpgm
%
%	Presents a file selection GUI from which the user can pick a file.
%	Uses the same path as previous call.
%
% SEE ALSO:	saveppm loadpgm



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


function I = loadppm(file, nseq)
	persistent path

	if nargin == 0,
		if isempty(path) | (path == 0),
			[file,npath] = uigetfile([pwd '/*.ppm'], 'loadpgm');
		else
			[file,npath] = uigetfile([path '/*.ppm'], 'loadpgm');
												end
		if file == 0,
			return;	% cancel button pushed
		else
			path = npath;
			clear npath;
		end
		I = loadppm2(file);
	else
		if isempty(findstr(file, '.ppm'))
			file = [file '.ppm'];
		end

		slashes = findstr(file, '/');
		if isempty(slashes),
			fpath = './';
		else
			k = slashes(end);
			fpath = file(1:k);
		end

		s = dir(file);		% do a wildcard lookup

		switch length(s),
		case 0,
			error('cant find specified file');
		case 1,
			I = loadppm2([fpath s.name]);
		otherwise,
			if nargin == 1,
				for i=1:length(s),
					I(:,:,:,i) = loadppm2([fpath s(i).name]);
				end
			else
				I(:,:,:) = loadppm2([fpath s(nseq).name]);
			end
		end
	end


function RGB = loadppm2(file)
	white = [' ' 9 10 13];	% space, tab, lf, cr
	white = setstr(white);

	fid = fopen(file, 'r');
	if fid < 0,
		fid = fopen([file '.ppm'], 'r');
	end
	if fid < 0,
		fid = fopen([file '.pnm'], 'r');
	end
	if fid < 0,
		R = [];
		disp(['Couldn''t open file' file]);
		return
	end
		
	magic = fread(fid, 2, 'char');
	while 1
		c = fread(fid,1,'char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	cols = fscanf(fid, '%d', 1);
	while 1
		c = fread(fid,1,'char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	rows = fscanf(fid, '%d', 1);
	while 1
		c = fread(fid,1,'char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	maxval = fscanf(fid, '%d', 1);
	c = fread(fid,1,'char');

	if magic(1) == 'P',
		if magic(2) == '3',
			fprintf('%s: binary PPM file (%dx%d)\n', file, cols, rows)
			I = fscanf(fid, '%d', [cols*3 rows]);
		elseif magic(2) == '6',
			fprintf('%s: binary PPM file (%dx%d)\n', file, cols, rows)
			if maxval == 1,
				fmt = 'unint1';
			elseif maxval == 15,
				fmt = 'uint4';
			elseif maxval == 255,
				fmt = 'uint8';
			elseif maxval == 2^32-1,
				fmt = 'uint32';
			end
			I = fread(fid, [cols*3 rows], fmt);
		else
			disp('Not a PPM file');
		end
	end
	%
	% now the matrix has interleaved columns of R, G, B
	%
	I = I';
	R = I(:,1:3:(cols*3));
	G = I(:,2:3:(cols*3));
	B = I(:,3:3:(cols*3));
	RGB(:,:,1) = R;
	RGB(:,:,2) = G;
	RGB(:,:,3) = B;
	fclose(fid);
