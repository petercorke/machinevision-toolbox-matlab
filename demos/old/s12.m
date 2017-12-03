im = iread('castle_sign.jpg', 'grey', 'double');
figure(1); idisp(im)
figure(2)
plot(im(350,:))
xaxis(560, 610)
surfl(im)
axis([550 650 300 400])
view(161,44)
