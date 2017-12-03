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

% We will show how to do chromakeying or "green screening" to superimpose
% a studio subject into another image.  We use files distributed in the
% images directory of the Toolbox.

% Load an image of the subject
subject = iread('greenscreen.jpg', 'gamma', 'sRGB', 'double');
% and display it, have a look at the pixel values in the background
idisp(subject, 'figure', 1, 'title', 'subject image');

% We create a linear RGB image, removing the effect of gamma correction
linear = igamm(subject, 'sRGB');
% now convert to red, green chromaticity values
[r,g] = tristim2cc(linear);
% we display a histogram of green chromaticity and quite clearly see the 
% population of pixels that belong to the green screen
figure(2); ihist(g)

% Now we can create a mask, a logical image, that is true for subject (non-green)
% pixels
mask = g < 0.45;
% and we display the mask
idisp(mask, 'figure', 2, 'title', 'mask image')

% now we replicate the mask across three color planes
mask3 = icolor( idouble(mask) );
% and can show the subject color image separated from its background
idisp(mask3 .* subject, 'title', 'subject only');

% Now we load an arbitrary image into which to insert the subject
bg = iread('road.png', 'double');
% and display it
idisp(bg, 'title', 'background')
% Automatically trim the image so that it's the same size as the original image
bg = isamesize(bg, subject);
idisp(bg, 'title', 'background resized')

% Now we make a "hole" in the background image where we will insert the subject
idisp(bg .* (1-mask3), 'title', 'background - subject')
% and finally paste the subject image into the hole
idisp( subject.*mask3  + bg.*(1-mask3), 'new', 'title', 'background + subject');
