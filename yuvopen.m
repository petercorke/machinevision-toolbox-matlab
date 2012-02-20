%YUVOPEN	Open a YUV4MPEG file
%
%	yuv = yuvopen(frame)
%
%	Open a yuv4mpeg format file.  This contains uncompressed color
%	images in 4:2:0 format, with a full resolution luminance plane
%	followed by U and V planes at half resolution both directions.
%
% SEE ALSO:	yuvread yuvclose



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

function yuv = yuvopen(filename)

	yuv.fp = fopen(filename, 'r');

	hdr = fgets(yuv.fp);

	yuv.hdr = hdr;
	while length(hdr) > 1,
		[s, hdr] = strtok(hdr);
		switch s(1),
		case {'Y'}
			if strcmp(s, 'YUV4MPEG2') == 0,
				fclose(yuv.fp);
				error('not a YUV4MPEG stream');
			end
		case {'W'}
			yuv.w = str2num(s(2:end));
		case {'H'}
			yuv.h = str2num(s(2:end));
		otherwise
			fprintf('found <%s>\n', s);
		end
	end
