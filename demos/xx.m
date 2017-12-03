-- color
im = iread('flowers8.png');
about im
idisp(im);
im = iread('flowers8.png');

figure(1); idisp(im);
figure(2); idisp(im(:,:,1));
idisp(im(:,:,2));
idisp(im(:,:,3));

im(100,200,1)
im(100,200,:)
squeeze( im(100,200,:) )

colorname('maroon')
colorname([1 0.41 0.71])
im = iread('castle_sign.jpg', 'grey', 'double');
figure(1); idisp(im)
figure(2)
ihist(im)
ithresh(im);

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
figure(1); idisp(im_binary)im = iread('tomato_124.jpg', 'gamma', 'sRGB', 'double');
figure(1); idisp(im)
randinit
[cls, cxy] = colorkmeans(im, 4);
figure(2); idisp(cls)
cxy

cls2 = (cls == 2);
figure(1); idisp(cls2);
binary_im = iclose(cls2, kcircle(15));
figure(2); idisp(binary_im)

f = iblobs(binary_im, 'boundary', 'class', 1)

idisp(im)
f.plot_boundary('r.')
f.plot_box('g')

-- points, harris, sift, surf
-- point correspondence
im = iread('building2-1.png', 'grey');
idisp(im)
C = icorner(im, 'nfeat', 200);
about C
C(1)
C.plot('ws');
idisp(im, 'dark')
C.plot('ws');
hist(C.strength, 50)
im = iread('building2-1.png', 'grey');
idisp(im)
C = isurf(im, 'nfeat', 200);
about C
C(1)
C(1).p
d = C(1).descriptor;
about d
d
C(1).plot('y', 'scale', 16, 'clock')
idisp(im, 'dark')
C.plot('w', 'scale', 4, 'clock');
im = iread('bridge-l/*.png', 'roi', [20 750; 20 480]);                    
about im
c = icorner(im, 'nfeat', 200, 'patch', 7);
about c
ianimate(im, c, 'fps', 10)

- color seg
practice with flowers
im = iread('yellowtargets.png');

figure(1); idisp(im);
lab = igraphseg(im, 1500, 100, 0.5);
figure(2); idisp(lab);

f = iblobs(lab, 'area', [2000 20000])
figure(1); 
f.plot_box('w'); f.plot_ellipse('b');

-- seg
im = iread('58060.jpg');
figure(1); idisp(im);
lab = igraphseg(im, 1500, 100, 0.5);
figure(2); idisp(lab);

