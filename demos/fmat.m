im1 = iread('eiffel2-1.jpg', 'mono', 'double');
im2 = iread('eiffel2-2.jpg', 'mono', 'double');
figure(1); idisp({im1, im2})

s1 = isurf(im1)
about s1
s2 = isurf(im2)

[m,corresp] = s1.match(s2)
about m
m(1:5)
m.subset(200).plot('w');
corresp(:,1:5)

F = m.ransac(@fmatrix, 1e-4, 'verbose')
m.show
m(1:5)

figure(2); idisp({im1, im2})
m.inlier.subset(100).plot('g')
m.outlier.subset(20).plot('r')

figure(1)
cam = CentralCamera('image', im1);
cam.plot_epiline(F', m.inlier.subset(20).p2, 'g')
clear cam
