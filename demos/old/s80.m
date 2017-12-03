im = iread('building2-1.png', 'grey');
idisp(im)
C = icorner(im, 'nfeat', 200);

% discuss C in workspace

C(1)
C.plot('ws');
idisp(im, 'dark')
C.plot('ws');
hist(C.strength, 50)
