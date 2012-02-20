%LOADINR	Load an INRIMAGE format file
%
%	LOADINR(filename, im)
%
%	Load an INRIA image format file and return it as a matrix
%
% SEE ALSO:	saveinr
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
function im = loadinr(fname, im)

	fid = fopen(fname, 'r');
	if fid < 0,
		im = [];
		disp('Couldn''t open file');
		return
	end

	s = fgets(fid);
	if strcmp(s(1:12), '#INRIMAGE-4#') == 0,
		error('not INRIMAGE format');
	end

	% not very complete, only looks for the X/YDIM keys
	while 1,
		s = fgets(fid);
		n = length(s) - 1;
		if s(1) == '#',
			break
		end
		if strcmp(s(1:5), 'XDIM='),
			cols = str2num(s(6:n));
		end
		if strcmp(s(1:5), 'YDIM='),
			rows = str2num(s(6:n));
		end
		if strcmp(s(1:4), 'CPU='),
			if strcmp(s(5:n), 'sun') == 0,
				error('not sun data ordering');
			end
		end
		
	end
	disp(['INRIMAGE format file ' num2str(rows) ' x ' num2str(cols)])

	% now the binary data
	fseek(fid, 256, 'bof');
	[im count] = fread(fid, [cols rows], 'float32');
	im = im';
	if count ~= (rows*cols),
		error('file too short');
	end
	fclose(fid);
