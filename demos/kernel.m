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
show simple 1x3 kernel then Sobel
show blurring, box and Gaussian
im = iread('lena.pgm', 'double');
figure(1); idisp(im);
im_h = iconv(im, [-1 0 1]);
figure(2); idisp(im_h, 'signed');
im_v = iconv(im, [-1 0 1]');
figure(1); idisp(im_v, 'signed');
im = iread('castle_sign.jpg', 'double', 'grey');
kdgauss(1)
ksobel
figure(1); idisp(im);
im_h = iconv(im, kdgauss(1));
figure(2); idisp(im_h, 'signed');
im_h = iconv(im, kdgauss(2));
figure(1); idisp(im_h, 'signed');
im_v = iconv(im, kdgauss(2)');
figure(2); idisp(im_v, 'signed');

m = sqrt( im_h.^2 + im_v.^2 );
figure(1); idisp(m);
th = atan2( im_v, im_h);
figure(2); quiver(1:20:numcols(th), 1:20:numrows(th), im_h(1:20:end,1:20:end), im_v(1:20:end,1:20:end))

edge = icanny(im);
idisp(edge);
