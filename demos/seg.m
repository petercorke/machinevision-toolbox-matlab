im = iread('yellowtargets.png');

figure(1); idisp(im);
lab = igraphseg(im, 1500, 100, 0.5);
figure(2); idisp(lab);

f = iblobs(lab, 'area', [2000 20000])
figure(1); 
f.plot_box('w'); f.plot_ellipse('b');

im = iread('58060.jpg');
figure(1); idisp(im);
lab = igraphseg(im, 1500, 100, 0.5);
figure(2); idisp(lab);