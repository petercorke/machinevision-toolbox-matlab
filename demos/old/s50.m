im = iread('yellowtargets.png', 'gamma', 'sRGB', 'double');
figure(1); idisp(im)

randinit
[cls, cxy,resid] = colorkmeans(im, 4);
figure(2); idisp(cls)
cxy
xycolorspace(cxy);
colorname(cxy(:,3)', 'xy')
cls3 = (cls == 3);
figure(2); idisp(cls3)
im_binary = iopen(cls3, kcircle(2));
figure(1); idisp(im_binary)