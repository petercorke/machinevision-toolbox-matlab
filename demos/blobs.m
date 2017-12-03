
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
im = testpattern('dots', 500, 200, 100);
idisp(im);
f = iblobs(im)
about f
f(1).children
f(2).parent
f(1).touch
f(2).touch
f(2).area
f(2).p
f(2).plot('x')
f(2).plot_box('r');
f(2:5).plot_box('b');
im = iread('castle_sign.jpg', 'grey', 'double');
idisp(im)
f = iblobs(im > 0.7, 'area', [10 2000], 'class', 1)
f.plot_box('b');
f.plot_ellipse('g');
figure(1); idisp(im_binary)
label = ilabel(im_binary);
figure(2); idisp(label, 'colormap', 'jet');
f = iblobs(im_binary)
f(5).children
f(1).parent
f(5).touch
f(1).touch
f(1).area
f(1).p
f(1).plot('wx')

f = iblobs(im_binary, 'touch', 0, 'area', [100 Inf])
figure(1); idisp(im)
f.plot_box('w')
f.plot_ellipse('b')
f.plot('kx'); f.plot('ko');
