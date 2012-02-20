%CAMPARAM		Default camera calibration parameters
%
%	ci = camparam
%
%	Return a camera intrinsic parameter structure:
%       focal length 8mm
%       pixel size 10um square
%       image size 1024 x 1024
%       principal point (512, 512)
%
%
% SEE ALSO:	camcalp, pulnix



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

function ci = camparam
	
	ci.f = 8e-3;		% f
	ci.sx = 10e-6;      % pixel width
	ci.sy = 10e-6;      % pixel height
	ci.u0 = 512;		% u0
	ci.v0 = 512;		% v0
    ci.nu = 1024;       % image width
    ci.nv = 1024;       % image height
