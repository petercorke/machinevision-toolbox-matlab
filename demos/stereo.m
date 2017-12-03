
    L = iread('rocks2-l.png', 'reduce', 2);
R = iread('rocks2-r.png', 'reduce', 2);
stdisp(L, R)
d = istereo(L, R, [40, 90], 3, 'interp');
idisp(d, 'bar');
Z = 3740*0.160 ./ d;

clf; 
surf(Z)
shading interp; view(-150, 75)
set(gca, 'ZDir', 'reverse'); set(gca, 'XDir', 'reverse');
colormap(flipud(hot))

anaglyph(L,R)
