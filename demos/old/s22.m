im = testpattern('dots', 500, 200, 100);
idisp(im);
f = iblobs(im)
about f
f(1).children
f(2).parent
f(1).touch
f(2).touch
f(2).area
f(2).p
f(2).plot('x')
f(2).plot_box('r');
f(2:5).plot_box('b');
