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

% We will examine simple grey scale images which we import from files.

% We load a standard image that is distributed with the Toolbox
im = iread('lena.pgm');
% we can use the standard MATLAB function whos to examine the result
whos im
% which we see is a 512x512 matrix with elements that are of the uint8 type, that
% is unsigned 8 bit integers, rather than the standard MATLAB double type.  These
% integers span the range 0 to 255 which by convention represent shades of
% grey from black (0) to white (255).  Each element of the matrix is referred
% to as a picture element (pixel).

% We can get the same information more succinctly with the Toolbox function
about im

% So the image is simply a matrix in the workspace, albeit a big one.
% We can display the matrix as an image
idisp(im)
% where idisp is the Toolbox's swiss army knife utility for displaying images,
% it has lots of options.  When used in an undocked figure idisp allows
% you to click points in the image and see the pixel values.

% We can also display the value of an individual pixel, for example
im(100,120)
% at row 100 and column 120, or pixel coordinate (120,100).
%
% Note this reversal, the pixel coordinate is written with the horizontal
% coordinate first, just as we do for a 2-dimensional graph.

% We can also display the pixel values from a small region of the image
im(100:104,120:124)

% We can also interactively select a region of interest (ROI).
% Click your mouse at the top left corner, hold and drag to the bottom
% right corner and then release (try to highlight Lena's eye)
eye = iroi(im);
% and the area you selected is
idisp(eye);

% Images come in many different formats each with a different extension.  A very
% common format is JPEG, which also allows for metadata to be stored along with
% the image pixel values.  For example
[im,tags]=iread('church.jpg');
% in addition to returning the image, it has also returned the image's metadata
tags
% which tells a lot about when the picture was taken, the camera etc.
% Even more information is available in one element of this structure which is
% itself a structure
tags.DigitalCamera
% which describes the focal length, aperture, shutter speed, flash etc.

% Now we will load another JPEG image
im = iread('castle_sign.jpg', 'grey', 'double');
% where we have specified that it be converted from color to greyscale, and 
% that the pixel values are converted from uint8 (0 to 255) to double (0 to 1.0)

% which we can display
idisp(im, 'figure', 1)
% We could plot the value of all pixels along row 350 of the image
figure(2); plot(im(350,:))
% which gives an intensity profile.  We can see the dark background of the sign
% and the white parts of the painted text

% We can zoom in on the stem of the T
xaxis(560, 610)

% Another way to think of an image is as a function I(u,v) which we can 
% represent as a surface whose height is equal to intensity.  The region around
% the T in the sign is
surfl(im); axis([550 650 300 400]); view(161,44); shading interp
