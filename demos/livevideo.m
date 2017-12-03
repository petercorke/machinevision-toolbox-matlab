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

% We will show how to grab live video from an attached camera to a 
% MATLAB figure.

% Create an object which represents a video camera connected to your computer
% If you have a laptop you should see the video recording light come on
camera = VideoCamera(0);

% Now create a loop to grab frames from the camera and display them
%  first we create an object to test for a button click in the figure
%  which is a signal to exit
cb = checkbuttonpress();
while true
    % grab the next frame from the attached camera
    im = camera.grab();
    % and display it
    idisp(im, 'nogui');
    % test whether to quit (mouse clicked in figure)
    if cb.press break; end;
end

% stop the camera
clear camera
