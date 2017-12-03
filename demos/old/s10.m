im = iread('lena.pgm');
whos im
about im
figure(1); idisp(im)
im(100,120)
im(100:104,120:124)
figure(2); plot(im(200,:))
eye = iroi(im);

im = iread('lena.pgm', 'double');
about im
idisp(im)

[im,tags]=iread('/Users/corkep/proj/Oxford/2012/images/lumix/P1000545.JPG');
idisp(im)
tags
tags.DigitalCamera

