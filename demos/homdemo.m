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

% We will discuss how to estimate an homography and use it to change the
% apparant viewpoint of a planar surface.

% We first load an image of a building which has a planar front surface
im = iread('notre-dame.jpg', 'double');
% and display it
idisp(im);

% Then we pick four points in the image that belong to a single plane.
% You could pick them yourself
%p1 = ginput(4)';
% but here are the values that I picked
p1 = [44.1 94.0 537.9 611.8; 377.1 152.8 163.4 366.4];
% and we can overlay them on the image
plot_poly(p1, 'wo', 'fill', 'b', 'alpha', 0.2);

% Now we know that the polygon should really be a rectangle, that's just a 
% trick of perspective
mn = min(p1'); mx = max(p1');
p2 = [mn(1) mx(2); mn(1) mn(2); mx(1) mn(2); mx(1) mx(2)]';
% which we overlay in red
plot_poly(p2, 'k', 'fill', 'r', 'alpha', 0.2);

% Given two sets of corresponding points, the vertices of the two polygons
% we can estimate an homography that maps blue to red
H = homography(p1, p2)

% and we can use the homography to warp the original image into one where
% the blue polygon above is a rectangle
figure(2); homwarp(H, im, 'full');

cam = CentralCamera('image', im, 'focal', 7.4e-3, 'sensor', [7.18e-3 5.32e-3]);
pose = cam.invH(H)
figure(1); trplot( oa2tr([0 0 -1], [0 1 0]), 'color', 'r')
hold on
trplot(pose(2).T, 'color', 'b')
