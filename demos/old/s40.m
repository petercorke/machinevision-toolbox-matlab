im = iread('lena.pgm', 'double');
figure(1); idisp(im);
im_h = iconv(im, [-1 0 1]);
figure(2); idisp(im_h, 'signed');
im_v = iconv(im, [-1 0 1]');
figure(1); idisp(im_v, 'signed');
