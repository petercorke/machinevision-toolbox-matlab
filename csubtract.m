%CSUBTRACT Subtract two angles on a circle
%
%  d = csubtract(th1, th2)
%
% Subtract two angles and return a result that is always in the range
% [-pi pi).



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

function dth = csubtract(th1, th2)

        dth = th1 - th2;
        while dth >= pi,
            dth = dth - 2*pi;
        end
        while dth < -pi,
            dth = dth + 2*pi;
        end
