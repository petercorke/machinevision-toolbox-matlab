%CAMCALT	Camera calibration using Tsai's two-stage method.
%
% This method works when the calibration target comprises coplanar points.
%
%	[Tcam, f, k1]] = CAMCALT(D, PAR)
%
%	Compute a 3x4 camera calibration matrix from calibration data
%	using the method of Tsai.
%
%  	D is camera calibration data with rows of the form [x y z X Y] where 
%	(x,y,z) is the world coordinate,  and (X,Y) is the image coordinate
%
%	PAR is a vector of apriori knowledge:
%		 Ncx
%		 Nfx
%		 dx
%		 dy
%		 Cx	principal point, framestore coordinate of optical
%		 Cy	axis.
%
%	The output is an estimate of the camera's pose, the focal length, and 
%	a lens radial distortion coefficient k1.
%
% REF:	"A versatile camera calibration technique for high-accuracy 3D machine
%	vision metrology using off-the-shelf TV cameras and lens"
%	R.Y. Tsai, IEEE Trans R&A RA-3, No.4, Aug 1987, pp 323-344.
%
% SEE ALSO: CAMCALP, CAMCALD, INVCAMCAL, CAMERA



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


function [Tcam, f, k1] = camcalt(camcal, par)
%
% manifest constants of camera sensor geometry and digitizer
%
	Ncx = par(1);
	Nfx = par(2);
	dx = par(3);
	dy = par(4);
	Cx = par(5);
	Cy = par(6);
%
% derived constants
%
	sx = Ncx/Nfx;
	dxp = sx * dx;

	X = Xf - Cx;
	Y = Yf - Cy;
	Xd = dx * X;
	Yd = dy * Y;

	z = [Yd.*xw Yd.*yw Yd -Xd.*xw -Xd.*yw] \ Xd;
	r1p = z(1);
	r2p = z(2);
	r4p = z(4);
	r5p = z(5);
	Txp = z(3);
	C = [r1p r2p; r4p r5p];
	if rank(C) == 2,
		Sr = r1p^2 + r2p^2 + r4p^2 + r5p^2;
		Ty2 = (Sr - sqrt(Sr^2 - 4*(r1p*r5p - r4p*r2p)^2)) / (2*(r1p*r5p - r4p*r2p)^2);
	else
		disp('unusual case')
		z = C(abs(C) > 0);
		Ty2 = 1.0 / (z(1)^2 + z(2)^2);
	end

	Ty = sqrt(Ty2);

%
% determine the sign of Ty
%

	%
	% find the calib point furthest from the center
	%
	[ymax i] = max(Xd.^2 + Yd.^2);

	r1 = r1p*Ty;
	r2 = r2p*Ty;
	r4 = r4p*Ty;
	r5 = r5p*Ty;
	Tx = Txp*Ty;
	x = r1*xw(i) + r2*yw(i) + Tx;
	y = r4*xw(i) + r5*yw(i) + Ty;

	if (sign(x) == sign(Xf(i))) & (sign(y) == sign(Yf(i))),
		Ty = Ty;
	else
		disp('sign of Ty reversed');
		Ty = -Ty;
	end

%
% determine the 3D rotation matrix R
%
	r1 = r1p*Ty;
	r2 = r2p*Ty;
	r4 = r4p*Ty;
	r5 = r5p*Ty;
	Tx = Txp*Ty;
	s = -sign(r1*r4 + r2*r5);
	R = [r1 r2 sqrt(1-r1^2-r2^2); r4 r5 s*sqrt(1-r4^2-r5^2)];
	R = [R(1:2,:); cross(R(1,:)', R(2,:)')];
	r7 = R(3,1);
	r8 = R(3,2);
	r9 = R(3,3);

	y = r4*xw+r5*yw+Ty;
	w = r7*xw+r8*yw;
	z = [y -dy*Y] \ [dy*(w.*Y)];
	f = z(1);

	if f < 0,
		disp('f is negative');
		R(1,3) = -R(1,3);
		R(2,3) = -R(2,3);
		R(3,1) = -R(3,1);
		R(3,2) = -R(3,2);
	end
	r6 = R(2,3);

%
% solve non-linear equation (8b) by minimization to find f, k1, Tz
%
	Tz = z(2);
	params = [r4 r5 r6 r7 r8 r9 dx dy sx Ty];
	z0 = [z; 0];		% add initial guess for k1
	z = fmins(@eightb, z0, 0,[],params, xw, yw, zw, Xf-Cx, Yf-Cy);
	f = z(1);
	Tz = z(2);
	k1 = z(3);
	Tcam = [R [Tx Ty Tz]'; 0 0 0 1];	% the camera transform


% optimization target function used by camcalt

%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab
% $Header: /home/autom/pic/cvsroot/image-toolbox/camcalt.m,v 1.2 2005/10/20 11:24:49 pic Exp $
% $Log: camcalt.m,v $
% Revision 1.2  2005/10/20 11:24:49  pic
% Embed optimization function in file.
%
% Revision 1.1.1.1  2002/05/26 10:50:20  pic
% initial import
%


function e = eightb(z, params, xw, yw, zw, X, Y)
	%
	% unpack the unknowns
	%
	f = z(1);
	Tz = z(2);
	k1 = z(3);

	%
	% unpack the scalar parameters
	%
	r4 = params(1);
	r5 = params(2);
	r6 = params(3);
	r7 = params(4);
	r8 = params(5);
	r9 = params(6);
	dx = params(7);
	dy = params(8);
	sx = params(9);
	Ty = params(10);

	rsq = (dx*X).^2 + (dy*Y).^2;
	res = (dy*Y).*(1+k1*rsq).*(r7*xw+r8*yw+r9*zw+Tz) - f*(r4*xw+r5*yw+r6*zw+Ty);
	e = norm(res, 2);

%	fprintf('%e [%f %e %e]\n', norm(res),f*1000,Tz*1000,k1);
