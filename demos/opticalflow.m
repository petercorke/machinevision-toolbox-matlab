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

% We illustrate the way points appear to move in an image as the camera moves.

% First we create a central-projection camera object with default parameters
camera = CentralCamera('default')

% and create a point in the world at (0,0,5), which is 5m away from the camera
% which has its viewing axis aligned with its z-axis
P = [0 0 5]';

% The projection of that point on the image plane of the camera is simply
cam.project(P)

% and if we move the camera sideways the projection moves to
cam.project(P, 'Tcam', transl(0.1, 0, 0) )
% that is, the projection moves horizontally also

% but if the point is further away
Pfar = [0 0 10]';
cam.project(Pfar, 'Tcam', transl(0.1, 0, 0) )
% the projection moves less far.  This is a demonstration of parallax.

% In fact for any camera translation or rotation the projection of the world
% point will appear to move on the image plane.  How much it moves depends
% on the magnitude of the camera motion, the distance of the point and the type
% of motion.

% We can illustate this by considering unit motion of the camera in the
% x-direction
cam.flowfield( [1 0 0  0 0 0] );
% which shows how points on the image plane would move (assuming they were
% all at the same distance from the camera).

% Unit motion in the y-direction causes the image plane points to move like
cam.flowfield( [0 1 0  0 0 0] );
% which is orthogonal to x-axis motion as expected.

% Unit motion in the z-direction causes the image plane points to move radially
% from the centre, an expansion effect
cam.flowfield( [0 0 1  0 0 0] );

% z-axis rotation has a very different pattern, as points orbit the principal
% point
cam.flowfield( [0 0 0  0 0 1] );

% Unit rotation about the x-axis causes the image plane points to move vertically,
cam.flowfield( [0 0 0  1 0 0] );

% and similarly for y-axis rotation
cam.flowfield( [0 0 0  0 1 0] );
% this is a bit like the x-axis translation case except for some curvature
% evident for points far from the principal point.  This curvature is a
% function of the focal length of the lens.

% If we make the camera have a short focal length (wider angle) we see
% the flow field has significant curvature
cam.f = 4e-3;
cam.flowfield( [0 0 0  0 1 0] );

% and if we increase the focal length (telephoto) we see the flow
% field lines are quite straight, almost the same as for the x-axis
% translation case.  That is the effect of translational and rotational
% motion can appear very similar.
cam.f = 20e-3;
cam.flowfield( [0 0 0  0 1 0] );
