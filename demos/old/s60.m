im = testpattern('squares', 256, 256, 128);
im = irotate(im, -0.3);
idisp(im)
edges = icanny(im);
idisp(edges)
h = Hough(edges)
about h
figure(2); h.show()
h.lines()
lines = h.lines()
about lines
axis([-1.4 -1.1 -190 -110])

h = Hough(edges, 'suppress', 5)
h.show()
h.lines()
lines = h.lines()
lines(1)
lines(1).theta
lines(1).rho
figure(1); idisp(im)
h.plot('b')
