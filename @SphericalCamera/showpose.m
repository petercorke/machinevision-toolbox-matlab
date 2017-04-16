

% Copyright (C) 1993-2017, by Peter I. Corke
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
%
% http://www.petercorke.com
function showcam(c, T, P)
    
    if nargin < 2
        T = c.T;
    end
    
    T = SE3(T);
    
    clf
    axis([-3, 3, -3, 3, -3 3])
    daspect([1 1 1])
    hold on
    grid
    [x,y,z] = sphere(20);
    
    
    hg = hgtransform;
    surf(x,y,z, 'FaceColor', [0.8 0.8 1], 'EdgeColor', 0.5*[0.8 0.8 1], ...
        'EdgeLighting', 'gouraud', 'Parent', hg)
    light
    lighting gouraud
    set(hg, 'Matrix', T.T);
    
    trplot(T, 'length', 1.6, 'arrow')
    
    axis
    limits = reshape(axis, 2, []);
    maxdim = max(diff(limits));
    
    o = T.t;
    
    if nargin > 2
        for i=1:numcols(P)
            plot3([o(1) P(1,i)], [o(2) P(2,i)], [o(3) P(3,i)], 'r');
            plot_sphere(P(:,i), maxdim*0.02, 'r');
        end
    end
    hold off
    xlabel('x'); ylabel('y'); zlabel('z');
