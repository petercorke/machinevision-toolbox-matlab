% Copyright (C) 1993-2013, by Peter I. Corke
%
% This file is part of The Machine Vision Toolbox for MATLAB (MVTB).
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
%
% http://www.petercorke.com

%%begin

% We will create a graphical model of a cube and show the view from a camera
% flying in an orbit around the cube

% First we create a camera object with default parameters
cam = CentralCamera('default');

% and then create a model of a cube, centred at the origin with sides of
% dimension 0.2.  We create an edge model which returns a MATLAB mesh
% representation expressed by three matrices X, Y, Z
[X,Y,Z] = mkcube(0.2, 'edge');
about X

% First create a camera to show the camera moving in the 3D world
figure
% and render the cube
mesh(X, Y, Z);
% and then show the camera icon
hold on; cam.plot_camera();
% and set the dimensions of the axes
axis([-1 1 -1 1 -1 1]*2);
% now lock the figure so it cant be overwritten
protectfig

% The animation is then a simple loop 
for theta=0:0.05:6*pi
  % update the pose of the camera which is moving in an outward spiral
  %  first we rotate the camera about the vertical world z-axis, then
  %  rotate the z-axis into the horizontal plane, the camera's view direction,
  %  then move in the negative camera z-direction, out from the world z-axis.
  cam.T = trotz(theta) * trotx(-pi/2) * transl(0,0,-(0.5+theta/6));
  % clear the camera's view
  cam.clf; 
  % render the projection of the cube
  cam.mesh(X,Y,Z);
  % then pause a bit
  pause(0.05);
end
