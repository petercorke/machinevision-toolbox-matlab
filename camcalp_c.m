%CAMCALP_C	Camera calibration matrix from parameters (central projection)
%
%	C = CAMCALP_C(cp)
%	C = CAMCALP_C(cp, Tcam)
%	C = CAMCALP_C(cp, pC, x, z)
%
%	Compute a 3x4 camera calibration matrix from given camera intrinsic
%	and extrinsic parameters.
%       CP is a camera parameter vector comprising:
%		cp(1)   f, the focal length of the lens (m)
%        	cp(2:3) alpha is a 2-element vector of horizontal and 
%			vertical pixel pitch of the sensor (pixels/m)
%	 	cp(4:5) p0 is a 2-element vector of principal point (u0, v0)
%			in pixels,
%			If length(cp) == 3, then p0 defaults to (0,0)
%
%        Tcam is the pose of the camera wrt the world frame, defaults to
%		identity matrix if not given (optical axis along Z-axis).
%
%	Alternatively the camera pose can be given by specifying the coordinates
%	of the center, pC, and unit vectors for the camera's x-axis and 
%	z-axis (optical axis).
%
%	This camera calibration matrix is for the central projection as 
%	commonly used in computer vision literature where the focal point
%	is at z=0, and rays pass through the image plane at z=f.  This model
%	has no image inversion.
%
%  	f, alphax and alphay are commonly known as the intrinsic camera 
%	parameters.  Tcam is commonly known as the extrinsic camera parameters.
%
% NOTE:	 that this calibration matrix includes the lens image inversion, so
%	that the camera coordinate system is:
%
%		0------------------> X
%		|
%		|
%		|	+ (principal point)
%		|
%		|
%		v
% 
% SEE ALSO:  camcalp, camera, pulnix
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

function C = camcalp(cp, A, B, C)
	f = cp(1);
	alpha = cp(2:3);
	if length(cp) <=3,
		p0 = [ 0 0];
	else
		p0 = cp(4:5);
	end
	if nargin == 1,
		Tcam = eye(4);
	elseif nargin == 2,
		Tcam = A;
	elseif nargin == 4,
		pC = A(:);
		x = unit(B(:));
		z = unit(C(:));
		if abs(dot(x,z)) > 1e-10,
			error('x and z vectors should be orthogonal');
		end
		R=[x unit(cross(z,x)) z];

		Tcam = transl(pC) * [R zeros(3,1); 0 0 0 1];
	end

 	C = [	alpha(1) 0 p0(1) 0; 
		0 alpha(2) p0(2) 0;
		0 0 1 0
	    ] * [ 1 0 0 0;
		  0 1 0 0;
		  0 0 1/f 0;
		  0 0 0 1] * inv(Tcam);                    
