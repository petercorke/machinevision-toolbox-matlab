

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
function epishow(L, R, F)

    image([L R] * 255.0);
    w = numcols(L);
    colormap(gray(256))

    h = line(0, 0);

    while 1
        [x,y] = ginput(1);
        if isempty(x)
            break;
        end
        x
        y

        if x <= w
            disp('left image');
        else
            disp('right image')
        end

        p = [x y 1]';
        l = F * p;

        x1 = 1;
        x2 = w;

        y1 = (-l(1)*x1 - l(3)) / l(2);
        y2 = (-l(1)*x2 - l(3)) / l(2);

        set(h, 'Xdata', [x1+w x2+w], 'Ydata', [y1 y2]);
    end

