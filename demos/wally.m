
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

% We will use machine vision techniques to solve a puzzle from the popular 
% children's book "Where's Wally" or "Where's Waldo"

% First we load an image which is the crowd scene where Wally is hiding
crowd = iread('wheres-wally.png', 'double');
figure(1); idisp(crowd)

% Then we load a template, an example of what Wally looks like
T = iread('wally.png', 'double');
figure(2); idisp(T)
% note that this is a very low resolution image, and is just one example
% of Wally.  In reality we don't know which way he is facing or which side
% his hat has flopped, but it's the best we have.

% We search for this template at every pixel position in the crowd scene (slow)
S = isimilarity(T, crowd, @zncc);

% The result is an image where every pixel has a value from -1 (antisimilar) 
% to +1 (similar) which gives us a clue as to where Wally is.
%
% We display this with a colormap to make it easier to see variation
idisp(S, 'colormap', 'jet', 'bar')

% Now we search this image to find the five highest pixel locations, Wally's
% possible locations
[mx,p] = peak2(S, 1, 'npeaks', 5)

% Finally we display the crowd scene
idisp(crowd)
% and overlay blue discs on each of the possible locations
plot_circle(p, 30, 'fillcolor', 'b', 'alpha', 0.3, 'edgecolor', 'none');
% and overlay numbers to indicate the 1st, 2nd, etc confidence
plot_point(p, 'sequence', 'bold', 'textsize', 24, 'textcolor', 'k');
% and we can see Wally is the number one pick

% However there's not much margin in this decision, if we look at the similarity
% scores
mx
% we see that the top match is not that confident, and the second match is not far
% behind the first.
