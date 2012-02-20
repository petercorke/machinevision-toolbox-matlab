% CAMCALD4	Compute partial camera calibration from four coplanar points
%
%	C = CAMCALD4(D)
% 
% Solve the camera calibration using a least squares technique.  

% Input is a table of data points, D, with each row of the form [X Y u v]
% where (X, Y) are the world coordinate of the planar points with respect
% to some coordinate system whose origin lies within the plane, 
% and (u, v) are the corresponding image  plane coordinate.
%
% Output is a 3x3 partial camera calibration matrix (missing the usual third column).
%
% SEE ALSO: CAMPOSE4, CAMCALP, CAMERA, CAMCALT, INVCAMCAL
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

function t = camcald4(m)

	[rows,cols] = size(m);

	if (rows ~= 4) | (cols ~= 4)
		error('data matrix should be 4 x 4')
	end
%
% build the matrix as per Ballard and Brown p.482
%
% the row pair are one row at this point
%
	aa = [ m(:,1) m(:,2) ones(rows,1) zeros(rows,3)   ...
	       -m(:,3).*m(:,1) -m(:,3).*m(:,2)    ...
		zeros(rows,3) m(:,1) m(:,2)  ones(rows,1)  ...
	       -m(:,4).*m(:,1) -m(:,4).*m(:,2) ];
%
% reshape the matrix, so that the rows interleave
%

	aa = reshape(aa', 8, rows*2)';

	bb = reshape( [m(:,3) m(:,4)]', 1, rows*2)';

	t = aa\bb;
	t = reshape([t;1]',3,3)';
