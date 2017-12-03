im = iread('tomato_124.jpg', 'gamma', 'sRGB', 'double');
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

