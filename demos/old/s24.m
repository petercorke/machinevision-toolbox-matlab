figure(1); idisp(im_binary)
label = ilabel(im_binary);
figure(2); idisp(label, 'colormap', 'jet');
f = iblobs(im_binary)
f(5).children
f(1).parent
f(5).touch
f(1).touch
f(1).area
f(1).p
f(1).plot('wx')

f = iblobs(im_binary, 'touch', 0, 'area', [100 Inf])
figure(1); idisp(im)
f.plot_box('w')
f.plot_ellipse('b')
f.plot('kx'); f.plot('ko');
