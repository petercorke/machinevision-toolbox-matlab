subject = iread('greenscreen.jpg', 'gamma', 'sRGB', 'double');
linear = igamma(subject, 'sRGB');
[r,g] = tristim2cc(linear);
ihist(g)
mask = g < 0.45;
idisp(mask)
mask3 = icolor( idouble(mask) );
idisp(mask3 .* subject);
bg = iread('road.png', 'double');
bg = isamesize(bg, subject);
idisp(bg .* (1-mask3))
idisp( subject.*mask3  + bg.*(1-mask3) );
