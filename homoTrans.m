% HOMOTRANS - homogeneous transformation of points
%
% Function to perform a transformation on homogeneous points/lines
% The resulting points are normalised to have a homogeneous scale of 1
%
% Usage:
%           t = homoTrans(P,v);
%
% Arguments:
%           P  - 3 x 3 or 4 x 4 transformation matrix
%           v  - 3 x n or 4 x n matrix of points/lines


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

%  Peter Kovesi
%  School of Computer Science & Software Engineering
%  The University of Western Australia
%  pk @ csse uwa edu au
%  http://www.csse.uwa.edu.au/~pk
%
%  April 2000
%  September 2007

function t = homotrans(P,v);
    
    [dim,npts] = size(v);
    
    if ~all(size(P)==dim)
	error('Transformation matrix and point dimensions do not match');
    end

    t = P*v;  % Transform

    for r = 1:dim-1     %  Now normalise    
	t(r,:) = t(r,:)./t(end,:);
    end
    
    t(end,:) = ones(1,npts);
    
    
