im = iread('castle_sign.jpg', 'grey', 'double');
idisp(im)
f = iblobs(im > 0.7, 'area', [10 2000], 'class', 1)
f.plot_box('b');
f.plot_ellipse('g');
