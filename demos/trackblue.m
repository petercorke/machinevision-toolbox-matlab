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

% We will track a blue object held in front of your computer's camera.
% It will work best if the blue object is in front of a white wall, and the
% blue object is well lit.  I use a bright blue squeeze ball...

% Create an object which represents a video camera connected to your computer
% If you have a laptop you should see the video recording light come on
camera = VideoCamera(0, 'double');

% Now create a loop to grab frames from the camera and display them
while true
    % record the time
    tic;
    % grab the next frame
    im0 = camera.grab();
    % and display it
    idisp(im0, 'nogui', 'figure', 1, 'title', 'live video');

    % gamma correct it
    im = igamma(im0, 1/0.45);
    % compute the blue chromaticity coordinate
    b = im(:,:,3) ./ sum(im, 3);
    % threshold that, to find regions that are very blue
    bin = b > 0.9;  % you may need to adjust this
    % cleanup the binary image with a morphological opening operation
    % to remove small blobs
    bin = iopen(bin, eye(5,5));
    % and display it
    idisp(bin, 'nogui', 'figure', 2, 'title', 'binary image');
    
    % look for blobs with between 100 and 50,000 pixels
    f = iblobs(bin, 'class', 1, 'area', [100 50000]);
    % skip if no features
    if length(f) == 0 continue; end;
    % otherwise find the biggest blob
    [~,k] = max(f.area);
    % and draw a green box around it
    f(k).plot_box('g');
    drawnow;
    % display elapsed time since tic
    toc;

    % test whether to quit, hit 'q'
    if get(gcf,'CurrentCharacter') == 'q' break; end;
end
clear camera
