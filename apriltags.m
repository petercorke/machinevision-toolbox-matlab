%APRILTAGS Read April tags from image
%
% tags = APRILTAGS(im) is a vector of structures that describe each of the
% April tags found within the image IM.
%
% Elements of the structure are:
%   .id         decoded id of the tag in the range 1-255
%   .hamming    number of corrected id bits, 0 is best
%   .goodness   tag constrast quality
%   .margin     decision margin, high is better
%   .H          homography matrix (3x3) describing the projection from an
%               "ideal" tag (with corners at (-1,-1), (1,-1), (1,1), and (-1,1)) to
%               pixels in the image
%   .centre     centre of the tag in the image (2x1) 
%   .corners    corners of the tag in the image (2x4)
%
% Notes::
% - implementation is a mex file
% - the options refine_decode and refine_pose are both enabled.
% - the image must be uint8 or double (grey level range 0 to 1).
% - only tag family tag36h11 is supported.
%
% Author::
%
% - AprilTags is open-source software from University of Michigan
% - details at https://april.eecs.umich.edu/software/apriltag.html
% - This wrapper by Peter Corke

% Copyright (C) 1993-2011, by Peter I. Corke
%
% This file is part of The Machine Vision Toolbox for Matlab (MVTB).
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
% - is a MEX file.

if ~exist('apriltags', 'file')
    error('you need to build the MEX version of apriltags, see vision/mex/README');
end
