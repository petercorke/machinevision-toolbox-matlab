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

% We can grab an image from Google Maps.

% First we create an object to connect us to the image source
ev = EarthView();
% which does require you to have a Google key (available for free) and given
% in the environment GOOGLE_KEY

% Like all image sources in the Toolbox it has a grab method that captures the
% image
im = ev.grab(-27.475722,153.0285, 17);
% the first two arguments are latitude and longitude, the last argument is the
% zoom factor, larger means a greater magnification.

% We can display the image
idisp(im);

% Alternatively we can a geographic lookup service to find a place by name
% rather than latitude/longitude
ev.grab('brisbane', 14)
% Note that if called with no output argument the image is automatically displayed.

% Finally we close the connection to the server
clear ev
