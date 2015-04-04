function FeatureTest(testCase)
    tests = functiontests(localfunctions);
end

function thresh_test(testCase)
    castle = iread('castle_sign.jpg', 'double', 'grey');

    ithresh(castle);
    t = otsu(castle);
    t = niblack(castle, -0.2, 35);
    verifyEqual(testCase, size(t), size(castle));

    castle = iread('castle_sign.jpg', 'grey');
    ithresh(castle);
    t = otsu(castle);
    t = niblack(castle, -0.2, 35);
    verifyEqual(testCase, size(t), size(castle));
end

function color_seg(testCase)

    im = iread('yellowtargets.png', 'gamma', 'sRGB', 'double');
    % kmeans clustering
    [cls, cxy,resid] = colorkmeans(im, 4);
    verifyEqual(testCase, size(cls), size(im));
    verifySize(testCase, cxy, [2 4]);

    % assign to clusters
    cls = colorkmeans(im, cxy);
end

function ilabel_test(testCase)
    im = ilabeltest;
    [label, m] = ilabel(im);
    verifyEqual(testCase, m, 5);
    reg3 = (label==3);
    verifyEqual(testCase, sum(reg3(:)), 24);

    [label, m, parents, cls] = ilabel(im);
    verifyEqual(testCase, parents(4), uint32(3));
    verifyEqual(testCase, cls, [1 0 1 0 1]');
end

function iblobs_test(testCase)
    im = ilabeltest;
    f = iblobs(im);
    s = char(f(1));
    verifyEqual(testCase, length(f), 5);
    f(1:4).uc;
    f(1:4).vc;
    verifyEqual(testCase, f(3).class, 1);
    verifyEqual(testCase, f(3).label, 3);
    verifyEqual(testCase, f(3).touch, logical(false));
    verifyEqual(testCase, f(3).parent, 2);
    verifyEqual(testCase, f(3).area, 24);
    verifyEqual(testCase, f(3).umin, 4);
    verifyEqual(testCase, f(3).vmin, 1);
    verifyEqual(testCase, f(3).umax, 5);
    verifyEqual(testCase, f(3).vmax, 2);

    assertAlmostEqual(f(1).uc, 6.1667, 'absTol', 1e-4);
    assertAlmostEqual(f(1).vc, 4.7917, 'absTol', 1e-4);
    assertAlmostEqual(f(1).shape, 0.6897, 'absTol', 1e-4);
    assertAlmostEqual(f(1).theta, -3.0832, 'absTol', 1e-4);

    f.plot_box();

    % test filters
    f = iblobs(im, 'class', 1);
    verifyEqual(testCase, length(f), 3);
    verifyEqual(testCase, f.class, [1 1 1]);
    f = iblobs(im, 'class', 0);
    verifyEqual(testCase, f.class, [0 0]);

    f = iblobs(im, 'touch', 0)
    verifyEqual(testCase, f.touch, [0 0 0]);

    f = iblobs(im, 'touch', 1)
    verifyEqual(testCase, f.touch, [1 1]);

    f = iblobs(im, 'area', [20 Inf]);
    verifyEqual(testCase, f.area, [48 24]);

    f = iblobs(im, 'area', [0 20]);
    verifyEqual(testCase, f.area, [4 2 2]);


    % test boundary stuff
    f = iblobs(im, 'boundary');
    s = char(f);
    assertAlmostEqual(f(1).circularity, 0.3029, 'absTol', 1e-4);
    assertAlmostEqual(f(1).perimeter, 31.5563, 'absTol', 1e-4);
end

function MSER_test(testCase)
    castle = iread('castle_sign2.png', 'double', 'grey');
    [mser,nsets] = imser(castle, 'light');
    verifyEqual(testCase, nsets, 40);
    verifyEqual(testCase, size(castle), size(mser));
end

function graphseg_test(testCase)
    im = iread('58060.jpg');
    [label, m] = igraphseg(im, 1500, 100, 0.5);
    verifyEqual(testCase, m, 28);
    verifyEqual(testCase, size(im), size(label));
end

function Hough_test(testCase)

    im = testpattern('squares', 256, 256, 128);
    im = irotate(im, -0.3);
    edges = icanny(im);
    h = Hough(edges);
    s = char(h);
    lines = h.lines();
    h = Hough(edges, 'suppress', 5)
    lines = h.lines();
    verifyEqual(testCase, length(lines), 4)
    idisp(im);
    h.plot('g')

    lines = lines.seglength(edges);
end
