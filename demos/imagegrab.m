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

% We will show how to acquire images from files, movies, the web and attached
% video cameras.

% We start by opening a movie file, a standard MPG format movie file
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

% We can display subsequent frames from the movie
idisp( camera.grab() );
idisp( camera.grab() );
idisp( camera.grab() );
idisp( camera.grab() );

% Finally we destroy the camera object which deallocates resources
clear camera

% We can grab an image from an internet webcam if we know its URL
camera = AxisWebCamera('http://wc2.dartmouth.edu')
about camera
% and we see that the result is an AxisWebCamera  object

% We can display a frame from that image source
idisp( camera.grab() );
clear camera

% We can grab an image from Google Maps
ev = EarthView();
% which does require you to have a Google key (available for free) and given
% in the environment GOOGLE_KEY
idisp( ev.grab(-27.475722,153.0285, 17) )
% Alternatively we can a geographic lookup service to find a place by name
% rather than latitude/longitude
idisp( ev.grab('brisbane', 14) )

% Finally, if you have a camera in, or attached to, your computer you can grab
% a live image frame.
% First create a VideoCamera object
camera = VideoCamera();
idisp( camera.grab() )
% and close the camera
clear camera
