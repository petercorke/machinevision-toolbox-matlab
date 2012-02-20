

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
function imr = rectify(F, imL, imR)

    % set the center of the transform
    x0 = [numcols(imL) numrows(imL)] / 2;
    T = [1 0 -x0(1); 0 1 -x0(2); 0 0 1]
    T

    disp('original epipole');
    eh = null(F');
    e = h2e(eh)

    disp('translated epipole');
    eth = T*eh;
    e = h2e(eth)

    tt = -(e(2)) / (e(1));
    ct = cos(atan(tt));
    R = [1 -tt 0 ; tt 1 0; 0 0 1/ct];
    R

    disp('translated rotated epipole')
    erth = R*eth;
    e = h2e(erth)

    f = e(1)
    G = [1 0 0; 0 1 0; -1/f 0 1];

    H = G * R * T;
    G
    R
    T
    H
    
    %rectif = imTrans(imL, H);
    rectif = imTrans(imR, H);

    rectif = rectif(1:numrows(imL),:);

    %stview(rectif, imR);
    stview(imL, rectif);

    disp('final epipole');
    eph = null(F')
end
