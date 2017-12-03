im = iread('lena.pgm');
figure(1); idisp(im);
figure(2); idisp( irotate(im, 30*pi/180) );
figure(2); idisp( iscale(im, 0.3) );
figure(2); idisp( iscale(im, 2) );
