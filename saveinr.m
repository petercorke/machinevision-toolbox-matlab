%SAVEINR	Write an INRIMAGE format file
%
%	SAVEINR(filename, im)
%
%	Saves the specified image array in a INRIA image format file.
%
% SEE ALSO:	loadinr
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

function saveinr(fname, im)

	fid = fopen(fname, 'w');
	[r,c] = size(im');

	% build the header
	hdr = [];
	s = sprintf('#INRIMAGE-4#{\n');
	hdr = [hdr s];
	s = sprintf('XDIM=%d\n',c);
	hdr = [hdr s];
	s = sprintf('YDIM=%d\n',r);
	hdr = [hdr s];
	s = sprintf('ZDIM=1\n');
	hdr = [hdr s];
	s = sprintf('VDIM=1\n');
	hdr = [hdr s];
	s = sprintf('TYPE=float\n');
	hdr = [hdr s];
	s = sprintf('PIXSIZE=32\n');
	hdr = [hdr s];
	s = sprintf('SCALE=2**0\n');
	hdr = [hdr s];
	s = sprintf('CPU=sun\n#');
	hdr = [hdr s];

	% make it 256 bytes long and write it
	hdr256 = zeros(1,256);
	hdr256(1:length(hdr)) = hdr;
	fwrite(fid, hdr256, 'uchar');

	% now the binary data
	fwrite(fid, im', 'float32');
	fclose(fid)
