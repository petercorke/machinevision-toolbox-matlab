%MKLINE Draw a line in a matrix
%
%   m = MKLINE(n, theta, c)
%   m = MKLINE(n, theta, c, val)
%
%   m = MKLINE(im, theta, c)
%   m = MKLINE(im, theta, c, val)
%
%   First form creates an NxN matrix of zeros and draws a line 
%   with vertical intercept C and angle THETA.  With the Xaxis to the left
%   and Yaxis downward, the Zaxis is into the screen.
%   Each pixel on the line is set to VAL (default 1).
%
%   The second form draws the line into an already existing matrix IM.
%
% SEE ALSO: ihough, xyhough
%



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

function im = mkline(n, theta, c, val)

    if ismatrix(n),
        im = n;
        [nr,nc] = size(im);
    else
        im = zeros(n, n);
        nr = n;
        nc = n;
    end

    if nargin < 4,
        val = 1;
    end

    x = 1:nc;
    y = round(x*tan(theta) + c);
    
    s = find((y >= 1) & (y <= nr));

    for k=s,    
        im(y(k),x(k)) = val;
    end
