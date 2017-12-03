crowd = iread('wheres-wally.png', 'double');
figure(1); idisp(crowd)
T = iread('wally.png', 'double');
figure(2); idisp(T)
S = isimilarity(T, crowd, @zncc);
idisp(S, 'colormap', 'jet', 'bar')
[mx,p] = peak2(S, 1, 'npeaks', 5)
idisp(crowd)
plot_circle(p, 30, 'fillcolor', 'b', 'alpha', 0.3, 'edgecolor', 'none');
plot_point(p, 'sequence', 'bold', 'textsize', 24, 'textcolor', 'k');
