im = iread('building2-1.png', 'grey');
idisp(im)
C = isift(im, 'nfeat', 200);

about C
C(1)
C(1).p


C(1).plot('y', 'scale', 16, 'clock')
idisp(im, 'dark')
C.plot('w', 'scale', 4, 'clock');

d = C(1).descriptor;
about d