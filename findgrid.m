im = testpattern('dots', 256, 50, 25);
im = ipad(im, 'lrtb', 50);
im = irotate(im, 30*pi/180);
m = iblobs(im, 'class', 1);
p = m.p;
% findgrid
x = p(1,:); y = p(2,:);
tri = delaunay(x, y);
clf
g = PGraph(2);
g.add_node(p);  % add all points to a graph

for t=tri'  % for each triangle
    n1 = p(:,t(1));
    n2 = p(:,t(2));
    n3 = p(:,t(3));
    v = [n1 n2 n3];
    if polyarea(v(1,:)', v(2,:)') < 100
        continue;
    end
    l = [colnorm(n1-n2) colnorm(n1-n3) colnorm(n2-n3)];
    [z,k] = max(l);
    i1 = [1 1 2]; i2 = [2 3 3];
    i1(k) = []; i2(k) = [];
    
    g.add_edge(t(i1(1)), t(i2(1)));
    g.add_edge(t(i1(2)), t(i2(2)));
end
g.plot('labels')

dir = [];
for i=1:g.n   % for all nodes
    c1 = g.coord(i);     % get its coordinate
    for n=g.neighbours(i);
        c2 = g.coord(n);
        dir = [dir atan2(c2(2)-c1(2), c2(1)-c1(1))];
    end
end

k = dir<0;
dir(k) = dir(k)+pi;
[n,x] = hist(dir, 50);
m = max(n);

k = find(n > m/2);
x(k)*180/pi

v1 = [cos(x(1)) sin(x(1))];
v2 = [cos(x(2)) sin(x(2))];


for i=1:g.n
    % look for a corner node, only 2 corners
    if length(g.neighbours(i)) == 2
        break;
    end
end
i

% compute canonic directions
n = g.neighbours(i);
xdir = unit( g.coord(i) - g.coord(n(1)) );
ydir = unit( g.coord(i) - g.coord(n(2)) );
top = i;

row = 0;
while 1
    col = 0
    node = top(1);
    while 1
        n = g.neighbours(node)
        dir = [];
        for i=n
            dir = [dir dot( unit(g.coord(node)-g.coord(i)), xdir)];
        end
        dir
        [md,k] = max(dir)
        fprintf(' %d', n(k));
        col = col + 1;
        pause
        if md < 0.6
            break;
        end
        node = n(k);
    end
    row = row+1
    n = g.neighbours(top)
    dir = [];
    for i=n
        dir = [dir dot( unit(g.coord(top)-g.coord(i)), ydir)];
    end
    dir
    [md,k] = max(dir);
    fprintf('row  %d', n(k));
    top = n(k);
end

