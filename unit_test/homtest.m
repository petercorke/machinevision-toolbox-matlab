% Copyright (C) 1995-2009, by Peter I. Corke
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


clearfigs
cam1 = camera('camera 1');

P = mkgrid(3, 1.0, transl(0,0,2));
P

T = transl(0.5,-0.2,0)*trotx(-0.2)*trotz(0.3);
T = transl(-0.3, 0.4, -0.8)*trotz(0.5)*troty(.3)*trotx(.3);
cam2 = camera(T, 'camera 2');

uv1 = cam1.plot(P, 'o')
iprint('hom1a');
uv2 = cam2.plot(P, 'o')

H = homography(uv1, uv2)

homtrans(H, uv1)-uv2

cam2.hold
plot2(homtrans(H, uv1)', '+')
iprint('hom1b');
cam2.hold(0)
cam2.clf

homtrans(H, uv1)
homtrans(inv(H), uv2)


% now lets add some out of the plane points that appear to be in an
% extra row in the image at (312,912), (512,912), (712,912)

P2 = pinv(cam1.C) * [
    312 512 712
    912 912 912
      1   1   1];

P2
cam1.project(P2(1:3,:))
pause
% columns at (X,Y,Z) and any multiple will project to the same point
% set range of points to be 1, 3, 4
P2 = P2(1:3,:) * diag([1 3 4])
cam1.project(P2(1:3,:))
P = [P P2]
cam1.plot(P, 'o')
cam2.plot(P, 'o')
pause


uv1 = cam1.project(P)
uv2 = cam2.project(P)

homtrans(H, uv1)-uv2

cam2.clf
cam1.plot(P, 'o')
iprint('hom2a');
cam2.plot(P, 'o')
cam2.hold
plot2(homtrans(H, uv1)', '+')
iprint('hom2b');
