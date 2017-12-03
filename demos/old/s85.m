im = iread('bridge-l/*.png', 'roi', [20 750; 20 480]);                    
about im
c = icorner(im, 'nfeat', 200, 'patch', 7);
about c
ianimate(im, c, 'fps', 10)

