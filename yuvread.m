%YUVREAD	Read frame from a YUV4MPEG file
%
%	[y,u,v] = yuvread(yuv, skip)
%	[y,u,v, h] = yuvread(yuv, skip)
%
%	Returns the Y, U and V components from the specified frame of
%	YUV file.  Optionally returns the frame header h.
%
% SEE ALSO:	yuvopen yuv2rgb yuv2rgb2



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

function [Y,U,V, h] = yuvread(yuv, skip)


	if nargin == 1,
		skip = 0;
	end

	while skip >= 0,
		% read and display the header
		hdr = fgets(yuv.fp);
		fprintf('header: %s', hdr);


		% read the YUV data
		[Y,count] = fread(yuv.fp, yuv.w*yuv.h, 'uchar');
		if count ~= yuv.w*yuv.h,
			Y = [];
			return;
		end
		[V,count] = fread(yuv.fp, yuv.w*yuv.h/4, 'uchar');
		if count ~= yuv.w*yuv.h/4,
			Y = [];
			return;
		end
		[U,count] = fread(yuv.fp, yuv.w*yuv.h/4, 'uchar');
		if count ~= yuv.w*yuv.h/4,
			Y = [];
			return;
		end

		skip = skip - 1;
	end

	Y = reshape(Y, yuv.w, yuv.h)';
	U = reshape(U, yuv.w/2, yuv.h/2)';
	V = reshape(V, yuv.w/2, yuv.h/2)';

	if nargin == 4,
		h = hdr;
	end
