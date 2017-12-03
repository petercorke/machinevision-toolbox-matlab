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

% We demonstrate computing Harris corner features on an image and an
% image sequence.

% We load an image
im = iread('eiffel2-1.jpg', 'grey');
% and display it
idisp(im)

% Now we compute the coordinates of the 200 strongest Harris corner features
h = icorner(im, 'nfeat', 200);
about h
% we see that the result is a vector of PointFeature objects, which have values
h(1)
% We overlay the features on the image
h.plot();
% We note that the features are located where there is very high image contrast
% such as the edges of trees and the tower

% We load an image sequence
im = iread('~/rvc/bridge-l/*.png', 'roi', [20 750; 20 480]);
% Note that We have used the 'roi' option to chop off the ragged edges 
% of these image

% The size of the resulting image is
about im
% which is slightly unusual in that the pixels are uint16 types.  The image
% has three dimensions, the third dimension is the number in the sequence.

% Once again we compute the coordinates of the features
h = icorner(im, 'nfeat', 200);
about h
% and because the input was an image sequence the features are computed for
% every image in the sequence.  The result is a cell array, one cell per image
% in the sequence which contains a vector of corner feature objects
about(h{1})

% We can animate the image sequence and the features
ianimate(im, h, 'fps', 10)
% Note that frame to frame the Harris features tend to stick the same point
% in the world such as cars, trees, road markings.

% Finally we can compute Harris featurse on live video.  You will find the features
% tend to stick to corners of pictures, books, shelves and not so much to smoother
% objects likes hands and faces.

% Create an object which represents a video camera connected to your computer
% If you have a laptop you should see the video recording light come on
camera = VideoCamera(0, 'grey');
% Now create a loop to grab frames from the camera and display them
while true
    % grab the next frame from the attached camera
    im = camera.grab();
    % and display it
    idisp(im);
    % compute Harris corners
    h = icorner(im, 'nfeat', 100);
    % and overlay them
    h.plot();
    drawnow

    % test whether to quit, hit 'q'
    if get(gcf,'CurrentCharacter') == 'q' break; end;
end
clear camera

% See also demo/tracking.
