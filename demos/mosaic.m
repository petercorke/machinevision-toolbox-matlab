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

% We will demonstrate how to create a mosaic from two overlapping images.


% We load the two images
im1 = iread('mosaic/aerial2-1.png', 'double', 'grey');
about im1
idisp(im1);
im2 = iread('mosaic/aerial2-2.png', 'double', 'grey');
idisp(im2);

% and create a large empty image in which we will paste the two pieces
composite = zeros(2000,2000);
% The first image is easy and we simply paste it into the top left corner
composite = ipaste(composite, im1, [1 1]);
idisp(composite)

% Now we need to find corresponding points in each image so that we can align them
%
% Step 1: identify common feature points which are known as 
% tie points.  We do this by finding SURF features
surf1 = isurf(im1)
surf2 = isurf(im2)

% Step 2:  look for candidate matches
m = surf1.match(surf2);
% However there will likely be some poor (outlier) matches at this stage.

% Step 3: we use RANSAC to look for the best consensus set.  We assume the features 
% lie on a plane so the relationship between the two sets of points (the model)
% is an homography
[H,in] = m.ransac(@homography, 0.2)

% Step 4: we use the inverse homography to warp the second image to the same
% coordinate frame as the first image
[tile,t] = homwarp(inv(H), im2, 'full', 'extrapval', 0);

% The resulting image is referred to as a tile
idisp(tile, 'figure', 2)

% and the vector t indicates the offset of the tile with respect to the first image
t

% Step 5: we add the tile into the canvas
composite = ipaste(composite, tile, t, 'add');
idisp(composite)
% We can clearly see several images overlaid and with excellent alignment.
% The non-mapped pixels in the warped image are set to zero so adding them causes 
% no change to the existing pixel values in the composite image.
%
% The process can be repeated for all 10 images in the aerial2 sequence.
