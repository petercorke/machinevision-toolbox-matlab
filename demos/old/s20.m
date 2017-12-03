im = iread('castle_sign.jpg', 'grey', 'double');
figure(1); idisp(im)
figure(2)
ihist(im)
ithresh(im);
