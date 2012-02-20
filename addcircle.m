%ADDCIRCLE  Add a circle to the current plot
%
%   addcircle(center, radius)
%   addcircle(center, radius, linestyle)
%
%  Returns the graphics handle for the circle.


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

function h = addcircle(center, radius, varargin)

	n = 100;

	th = [0:n]'/n*2*pi;
	cth = cos(th);
	sth = sin(th);

    ih = ishold;
    hold on
    handles = [];   % list of handles for circles

    for i=1:numrows(center)
        handles = [handles; patch(radius(i)*cos(th)+center(i,1), radius(i)*sin(th)+center(i,2), varargin{:})];
    end
    if ih == 0,
        hold off
    end

    if nargout > 0,
        h = handles;
    end

