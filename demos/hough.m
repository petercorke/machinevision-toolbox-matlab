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

% Create a white square
im = testpattern('squares', 256, 256, 128);
% and rotate it
im = irotate(im, -0.3);
idisp(im)

% find the edges
edges = icanny(im);
idisp(edges)

% compute the Hough transform of the edge image
h = Hough(edges)
about h
% where we have a Hough object

% We can view the Hough accumulator array 
figure(2); h.show()
% where each point represents a line and the bright spots represent
% dominant lines in the scene

% We can find those dominant lines
lines = h.lines();
about lines
% which is an array of LineFeature objects

% Each LineFeature object has a number of properties
lines(1)
% which we can access individually by
lines(1).theta
lines(1).rho

% If we display these
lines
% we see that 

axis([-1.4 -1.1 -190 -110])

% We can avoid this problem by using non-local minima suppression
h = Hough(edges, 'suppress', 5)
% in this case with a radius of 5 Hough cells

% Repeating the process above we see fewer lines
lines = h.lines()

figure(1); idisp(im)
h.plot('b')
im = iread('church.png', 'grey', 'double');
idisp(im)
edges = icanny(im);
idisp(edges)
h = Hough(edges, 'suppress', 5)
h.show()
h.lines()
lines = h.lines()
idisp(im)
lines(1:10).plot();
