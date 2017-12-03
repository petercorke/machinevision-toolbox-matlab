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

% RANSAC is a technique for finding a subset of data that provides support
% for a model, despite the presence of significant error points.

% Consider a set of data points that define a line
x = [0:0.5:5];
y = 0.6 * x - 1.5;

% and we will add a small amount of noise to the y-coordinates
y = y + 0.02*randn(size(x));

plot(x, y, '*');

% We can solve for the line equation using a simple regression
theta = [x' ones(size(x'))] \ y'
% where we see the parameters are the slope and intercept of our line which
% we can superimpose
hold on; plot(x, x*theta(1)+theta(2), 'r'); hold off

% Now let's add a couple of erroneous points
x = [x 1.1 1.3]; y = [y 0.95 0.9];
% which we can see clearly
plot(x, y, '*');

% and we will repeat the regression
theta = [x' ones(size(x'))] \ y'
hold on; plot(x, x*theta(1)+theta(2), 'r'); hold off
% we observe that the estimated line has been significantly influenced by these
% two bad points

% To solve a problem like this we use RANSAC.  RANSAC for this line fitting 
% problem works as follows:
%  - randomly choose 2 points, the minimum neccessary to estimate a line
%  - test how well all the points conform to this model (threshold test)
%  - repeat the process and select the model for which the most number of 
%    points conform (we call those points the inliers)

% We pass a function for line estimation to the ransac driver function, along
% with the data and a threshold to use in step 2 above
theta = ransac(@linefit, [x; y], 0.1)
% and we see a good estimate of the parameters of the line, which we will overlay
% in blue
hold on; plot(x, x*theta(1)+theta(2), 'b'); hold off

% Because ransac employs random sampling the results will vary from run to
% run and it may even fail.  If it fails run this demo again.

% The linefit function contains two parts:
%  - Code to estimate the line parameters as we did above
%  - Ransac driver, which performs line fitting specific functions to RANSAC
%
% You can see the linefit function
type linefit

% RANSAC is used to estimate fundamental matrix and homographies
