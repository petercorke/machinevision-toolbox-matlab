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
