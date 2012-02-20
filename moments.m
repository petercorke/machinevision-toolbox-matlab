%MOMENTS    return moment vector for given camera orientation
%
%   N = MOMENTS(RPY, V, DISPFLAG)
%
% where RPY is a 3-vector of roll-pitch-yaw angle, 
%   V are the 3D object vertices, 
%   DISPLAY is true if a camera's eye view is to be displayed.
%
%    Camera parameters are hard-wired as per thesis example.
%   
function N = moments(rpy,v,dispflg)
%
% camera parameters as per thesis
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


f = 12.0;
alphax = 8.3e-3;
alphay = 8.6e-3;
X0 = 0;
Y0 = 0;
    if nargin == 2,
        dispflg = 0;
    end;

    pcam = [-500 0 0]';
    rotcam = [ 0 0 1;
          -1 0 0
           0 -1 0];
    tcam = [ rotcam pcam;
         0 0 0  1];
    camera = [1/alphax    0    0    X0
            0    1/alphay  0    Y0
            0       0    -1/f   1];
    twiddle = camrpy(rpy(1), rpy(2), rpy(3));


    iv = viewtran(v, camera*inv(tcam*twiddle));
    m00 = mpq(iv, 0,0);
    m10 = mpq(iv, 1,0);
    m01 = mpq(iv, 0,1);
    m20 = mpq(iv, 2,0);
    m02 = mpq(iv, 0,2);
    m11 = mpq(iv, 1,1);
    u20 = m20 - m10^2/m00;
    u02 = m02 - m01^2/m00;
    u11 = m11 - m10*m01/m00;
    n20 = u20/m00^2;
    n02 = u02/m00^2;
    n11 = u11/m00^2;
    
    if dispflg > 0,
        showimag(iv);
        labl = sprintf('xc=%f', m10/m00);
        text(400,700, labl);
        labl = sprintf('yc=%f', m01/m00);
        text(400,600, labl);
        labl = sprintf('n20=%f', n20);
        text(400,500, labl);
        labl = sprintf('n02=%f', n02);
        text(400,400, labl);
        labl = sprintf('n11=%f', n11);
        text(400,300, labl);
        pause(0.2);
    end
    N = [n20 n02 n11 m10/m00 m01/m00];
end
