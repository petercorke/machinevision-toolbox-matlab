%CAMPOSE4	Camera pose estimation from 4 coplanar points.
%
%	T = CAMPOSE4(D, ci)
%	[T, UV0] = CAMPOSE4(D, ci)
%
% Input is a table of data points, D, with each row of the form [X Y u v]
% where (X, Y) are the world coordinate of the planar points with respect
% to some coordinate system whose origin lies within the plane, 
% and (u, v) are the corresponding image  plane coordinate.
%
% ci is a structure of camera intrinsic parameters that must contain
% focal length (f), and pixel sizes (sx, sy).
%
% Output is a homogeneous transformation, T, of the camera's pose with 
% respect to the coordinate frame of the planar points.  
% The optional result, UV0, is the coordinate of the principal point (in 
% distance units).
%
% from Ganapathy "Camera Location Determination Problem",
% Bell Labs Tech. Memo 11358-841102-20-TM, Nov 2 1984
%
% SEE ALSO: CAMPOSE4, CAMCALP, CAMERA, CAMCALT, INVCAMCAL



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

function [T, uv0] = campose4(uvXY, ci)

	t = camcald4(uvXY);
    k(1) = ci.f / ci.sx;
    k(2) = ci.f / ci.sy;
% K = [k1 k2] contains the X and Y-direction scale
% factors: k1 = kx * F, k2 = ky * F, where F is the focal length.
%

	lam1 = t(1,1)*t(3,2) - t(1,2)*t(3,1);
	lam2 = t(2,1)*t(3,2) - t(2,2)*t(3,1);
	if abs(lam1) < 1e-8,
		lam1 = 0;
	end
	if abs(lam2) < 1e-8,
		lam2 = 0;
	end

	if (lam1 == 0) & (lam2 == 0),
		r2 = (k(1)^2 + k(2)^2) / sqrt(t(1,1)^2 + t(1,2)^2 + t(2,1)^2 + t(2,2)^2);
		r = sqrt(r2);
		disp('Problem with solution: lam1 = lam2 = 0');
		i = 1;
		f = 0;
		c = 0;
		g = 0;
		h = 0;
		
		u0 = ci.u0;
		v0 = ci.v0;
	else
		r2 = (t(3,1)^2 + t(3,2)^2)/( (lam1/k(1))^2 + (lam2/k(2))^2 );
		r = sqrt(r2);
        
		i2 = 1 - r2*(t(3,1)^2 + t(3,2)^2);
		i = sqrt(i2);
		f = -lam1/k(1)*r2;
		c = lam2/k(2)*r2;

		u0 = (t(1,1)*t(3,1) + t(1,2)*t(3,2) + k(1)*c*i/r2) / (t(3,1)^2 + t(3,2)^2);
		v0 = (t(2,1)*t(3,1) + t(2,2)*t(3,2) + k(2)*f*i/r2) / (t(3,1)^2 + t(3,2)^2);

		g = t(3,1)*r;
		h = t(3,2)*r;
	end

	a = (t(1,1)*r - u0*g) / k(1);
	b = (t(1,2)*r - u0*h) / k(1);
	d = (t(2,1)*r - v0*g) / k(2);
	e = (t(2,2)*r - v0*h) / k(2);
	p = (t(1,3)*r - u0*r) / k(1);
	q = (t(2,3)*r - v0*r) / k(2);

	R = [a b c;d e f;g h i];
	P = [p q r];

	T = [R P'; 0 0 0 1];
	uv0 = [u0 v0];
