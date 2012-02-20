

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
i=iroi(im);

% attempt to find the markers using simple vision methods
i2=imorph(i,ones(3,3),'max');	% eliminate the markers
iff=flatfield(i2);		% and compute the flat field
idisp(iff-i) 
pause
[k,s]=kmeans(iff-i,3);		% now k-means segmentation
idisp(s)
pause
[l,nblobs]=ilabel(s==3);	% and assume brightest points are markers
idisp(l)
colormap(hot(nblobs));
pause
f=iblobs(l)			% now extract binary image features
hold on
for i=1:12
	if f(i).area < 100,
		plot(f(i).xc,f(i).yc,'*w')
	end
end

% now enter the refinement phase
