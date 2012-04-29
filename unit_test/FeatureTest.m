function FeatureTest
  initTestSuite;


function thresh_test
    castle = iread('castle_sign.jpg', 'double', 'grey');

    ithresh(castle);
    t = otsu(castle);
    t = niblack(castle, -0.2, 35);
    assertEqual(size(t), size(castle));

    castle = iread('castle_sign.jpg', 'grey');
    ithresh(castle);
    t = otsu(castle);
    t = niblack(castle, -0.2, 35);
    assertEqual(size(t), size(castle));


function color_seg

    im = iread('yellowtargets.png', 'gamma', 'sRGB', 'double');
    % kmeans clustering
    [cls, cxy,resid] = colorkmeans(im, 4);
    assertEqual(size(cls), size(im));
    assertIsSize(cxy, [2 4]);

    % assign to clusters
    cls = colorkmeans(im, cxy);

function ilabel_test
    im = ilabeltest;
    [label, m] = ilabel(im);
    assertEqual(m, 5);
    reg3 = (label==3);
    assertEqual(sum(reg3(:)), 24);

    [label, m, parents, cls] = ilabel(im);
    assertEqual(parents(4), uint32(3));
    assertEqual(cls, [1 0 1 0 1]');

function iblobs_test
    im = ilabeltest;
    f = iblobs(im);
    s = char(f(1));
    assertEqual(length(f), 5);
    f(1:4).uc;
    f(1:4).vc;
    assertEqual(f(3).class, 1);
    assertEqual(f(3).label, 3);
    assertEqual(f(3).touch, logical(false));
    assertEqual(f(3).parent, 2);
    assertEqual(f(3).area, 24);
    assertEqual(f(3).umin, 4);
    assertEqual(f(3).vmin, 1);
    assertEqual(f(3).umax, 5);
    assertEqual(f(3).vmax, 2);

    assertAlmostEqual(f(1).uc, 6.1667, 'absolute', 1e-4);
    assertAlmostEqual(f(1).vc, 4.7917, 'absolute', 1e-4);
    assertAlmostEqual(f(1).shape, 0.6897, 'absolute', 1e-4);
    assertAlmostEqual(f(1).theta, -3.0832, 'absolute', 1e-4);

    f.plot_box();

    % test filters
    f = iblobs(im, 'class', 1);
    assertEqual(length(f), 3);
    assertEqual(f.class, [1 1 1]);
    f = iblobs(im, 'class', 0);
    assertEqual(f.class, [0 0]);

    f = iblobs(im, 'touch', 0)
    assertEqual(f.touch, [0 0 0]);

    f = iblobs(im, 'touch', 1)
    assertEqual(f.touch, [1 1]);

    f = iblobs(im, 'area', [20 Inf]);
    assertEqual(f.area, [48 24]);

    f = iblobs(im, 'area', [0 20]);
    assertEqual(f.area, [4 2 2]);


    % test boundary stuff
    f = iblobs(im, 'boundary');
    s = char(f);
    assertAlmostEqual(f(1).circularity, 0.3029, 'absolute', 1e-4);
    assertAlmostEqual(f(1).perimeter, 31.5563, 'absolute', 1e-4);

function MSER_test
    castle = iread('castle_sign2.png', 'double', 'grey');
    [mser,nsets] = imser(castle, 'light');
    assertEqual(nsets, 40);
    assertEqual(size(castle), size(mser));

function graphseg_test
    im = iread('58060.jpg');
    [label, m] = igraphseg(im, 1500, 100, 0.5);
    assertEqual(m, 28);
    assertEqual(size(im), size(label));

function Hough_test

    im = testpattern('squares', 256, 256, 128);
    im = irotate(im, -0.3);
    edges = icanny(im);
    h = Hough(edges);
    s = char(h);
    lines = h.lines();
    h = Hough(edges, 'suppress', 5)
    lines = h.lines();
    assertEqual(length(lines), 4)
    idisp(im);
    h.plot('g')

    lines = lines.seglength(edges);

function Corner_test

    b1 = iread('building2-1.png', 'grey', 'double');
    C = icorner(b1, 'nfeat', 200);
    assertEqual(length(C), 200);
    ss = char(C);
    C(1:5).u;
    C(1:5).v;
    C(1:5).strength;
    d = C(1:5).descriptor
    assertIsSize(d, [3 5]);


    C = icorner(b1, 'nfeat', 200, 'suppress', 10);

    C = icorner(b1, 'nfeat', 200, 'suppress', 10, 'detector', 'noble');
    C = icorner(b1, 'nfeat', 200, 'suppress', 10, 'detector', 'klt');

    C = icorner(b1, 'nfeat', 200, 'sigma', 3);
    C = icorner(b1, 'nfeat', 200, 'k', 0.06);
    C = icorner(b1, 'nfeat', 200, 'patch',3);
    d = C(1:5).descriptor
    assertIsSize(d, [9 5]);

    idisp(b1);
    C.plot();

function ScaleSpace_test
    im = iread('scale-space.png', 'double');

    [G,L,s] = iscalespace(im, 60, 2);
    assertIsSize(G, [200 200 60]);
    assertIsSize(L, [200 200 59]);
    assertIsSize(s, [60 1]);
    f = iscalemax(L, s)
    assertEqual(length(f), 6);
    ss = char(f);
    f(1:5).u;
    f(1:5).v;
    f(1:5).strength;
    f(1:5).sigma;

    idisp(im);
    f.plot('r')
    f.plot_scale('r')


function SIFT_test
    b1 = iread('building2-1.png', 'grey', 'double');
    s = isift(b1)
    ss = char(s);
    s(1:5).u;
    s(1:5).v;
    s(1:5).strength;
    s(1:5).sigma;
    s(1:5).theta;

    idisp(b1);
    s.plot();
    s.plot('g');
    s.plot_scale()
    s.plot_scale('r')

    s = isift(b1, 'nfeat', 50)
    assertEqual(length(s), 50);
    assertIsSize(s, [128 50]);

    s = isift(b1, 'suppress', 5)

function SURF_test
    b1 = iread('building2-1.png', 'grey', 'double');
    s = isurf(b1)
    ss = char(s);
    s(1:5).u;
    s(1:5).v;
    s(1:5).strength;
    s(1:5).sigma;
    s(1:5).theta;

    s = isurf(b1, 'nfeat', 50)
    assertEqual(length(s), 50);
    assertIsSize(s, [128 50]);

    s = isurf(b1, 'suppress', 5)

