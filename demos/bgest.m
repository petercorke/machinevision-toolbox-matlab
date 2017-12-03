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

% We will show how to estimate the background of a scene, those pixels that
% are constant from frame to frame, and to estimate those parts of the scene
% that are changing.  We will demonstrate this on a live video feed.

% Create an object which represents a video camera connected to your computer
% If you have a laptop you should see the video recording light come on
%
% Type the q-key to stop this running

camera = VideoCamera('grey', 'double');

% take a frame from the camera as initial estimate of background
bg = camera.grab();

% rate of change threshold
sigma = 5/255.0;

% now we loop over all frames
while true
    % grab the image
    im = camera.grab();
    % compute the difference between the new frame and background estimate
    d = im-bg;
    % clip it to the range -sigma to sigma
    d = max(min(d, sigma), -sigma);
    % update the background, adjust background pixel values towards the new image
    bg = bg + d;
    
    % display live, estimated background and motion pixels
    idisp(im, 'nogui', 'figure', 1, 'title', 'live video');
    idisp(bg, 'nogui', 'figure', 2, 'title', 'background image');
    idisp(abs(im-bg), 'nogui', 'figure', 3, 'title', 'motion image');

    drawnow
    
    % test whether to quit, hit 'q'
    if get(gcf,'CurrentCharacter') == 'q'
        set(gcf,'CurrentCharacter', '-')
        break;
    end;
end
clear camera   % close the video source
