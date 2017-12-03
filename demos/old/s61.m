im = iread('church.png', 'grey', 'double');
idisp(im)
edges = icanny(im);
idisp(edges)
h = Hough(edges, 'suppress', 5)
h.show()
h.lines()
lines = h.lines()
idisp(im)
lines(1:10).plot();
