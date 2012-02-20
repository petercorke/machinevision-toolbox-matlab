%OFLOW simple optical flow based on corner correspondance
%
%	oflow(c1, c2)
%	oflow(c1, c2, w)
%	oflow(c1, c2, w, thresh)
%
%	c1, c2 are corner structures from showcorners().  Perform exhaustive
%	cross matching between the two sets of corners using ZNCC similarity
%	measure.  Takes first 100 corners.
%
%	w is the matching window half width, match window is 2*w+1 (default 5) 
%	thresh is the minimum similarity measure for the match to be 
%	 accepted (default 0.6)
%JUNK



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


function corr = oflow(c1, c2, w, thresh)

	f1 = showcorners(c1, 150);
	f2 = showcorners(c2, 150);

	if nargin < 3,
		w = 5,
	end
	if nargin < 4,
		thresh = 0.6;
	end

	idisp(c1.im);
	drawnow
	count = 0;
	hold on
	for i=1:length(f1),
		best = -1;
		for j=1:length(f2),
			m = similarity(c1.im, c2.im, [f1(i).x f1(i).y], ...
				[f2(j).x f2(j).y], w);
			if m > best,
				best = m;
				which = j;
			end
		end
		if (best > thresh)
			arrow( ...
				[f1(i).x f1(i).y], ...
				[f2(which).x f2(which).y], ...
				'EdgeColor', 'y', ...
				'FaceColor', 'y')
			drawnow
			count = count+1;
			corresp(count).p1 = [f1(i).x f1(i).y];
			corresp(count).p2 = [f2(which).x f2(which).y];
			corresp(count).score = best;
			corresp(count).dist = norm([f1(i).x f1(i).y]-[f2(which).x f2(which).y]);
		end
	end
	hold off
	if nargout == 1,
			corr = corresp;
	else
		fprintf('%d matches\n', count);
	end
