%ISTRETCH Image normalization
%
% OUT = ISTRETCH(IM) is a normalized image in which all pixel values lie in 
% the range 0 to 1.  That is, a linear mapping where the minimum value of 
% IM is mapped to 0 and the maximum value of IM is mapped to 1.
%
% OUT = ISTRETCH(IM,MAX) as above but pixel values lie in the range 0 to MAX.
%
% See also INORMHIST.


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


function zs = istretch(z, newmax)

    if nargin == 1
        newmax = 1;
    end

    mn = min(z(:));
    mx = max(z(:));

    zs = (z-mn)/(mx-mn)*newmax;
