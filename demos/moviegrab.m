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

% We will show how to acquire images from movie files.

% First we create an object to connect us to the image source which in 
% this example is a movie file, a standard MPG format movie file
camera = Movie('traffic_sequence.mpg');
about camera
% and we see that the result is a Movie object

% The displayed value of this object
camera
% shows the frame dimension, frame rate, number of frames etc.

% To grab a frame from the movie
im = camera.grab();
% and then display it
idisp(im)

% We can display subsequent frames from the movie (note the traffic moving)
camera.grab();
camera.grab();
camera.grab();
camera.grab();
% Note that if we call the grab() method without a return argument the image
% is automatically displayed.

% Finally we destroy the camera object which deallocates resources
clear camera
