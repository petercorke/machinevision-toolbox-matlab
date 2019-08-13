function tests = RegionFeatureTest
    tests = functiontests(localfunctions);
    clc
end

function teardownOnce(tc)
    close all
end

function thresh_test(tc)
    castle = iread('castle.png', 'double', 'grey');

    ithresh(castle);
    t = otsu(castle);
    t = niblack(castle, -0.2, 35);
    tc.verifyEqual(size(t), size(castle));

    castle = iread('castle.png', 'grey');
    ithresh(castle);
    t = otsu(castle);
    tc.verifyTrue( t > 0 && t < 255);
    t = niblack(castle, -0.2, 35);
    tc.verifyEqual(size(t), size(castle));
end

function colorseg_test(tc)

    im = iread('yellowtargets.png', 'gamma', 'sRGB', 'double');
    % kmeans clustering
    K = 4;
    [cls, cxy,resid] = colorkmeans(im, K);
    
    tc.verifyEqual(size(cls), size(im(:,:,1)));
    tc.verifySize(cxy, [2 K]);
    tc.verifyClass(resid, 'double');

    % assign to clusters
    cls = colorkmeans(im, cxy);
    tc.verifyEqual(size(cls), size(im(:,:,1)));
    tc.verifyEqual( min(cls(:)), 1);
    tc.verifyEqual( max(cls(:)), K);  
end


function iblobs_test(tc)
    im = zeros(20, 20);
    im(4:16,1:6) = 1;
    im(8:12, 12:18) = 1;
    
    A2 = (16-4+1)*(6-1+1);
    A3 = (12-8+1)*(18-12+1);
    A1 = 20*20-A2-A3;
    
    f = iblobs(im);
    
    %tc.verifyClass(f, 'RegionFeature');
    tc.verifySize(f, [1 3]);
    
    s = char(f);
    tc.verifyEqual(size(s,1), 3);
    
    tc.verifyEqual(f(1).area, A1);
    tc.verifyEqual(f(1).umin, 1);
    tc.verifyEqual(f(1).vmin, 1);
    tc.verifyEqual(f(1).umax, 20);
    tc.verifyEqual(f(1).vmax, 20);
    tc.verifyEqual(f(1).class, 0);
    tc.verifyEqual(f(1).label, 1);
    tc.verifyEqual(f(1).touch, true);
    tc.verifyEqual(f(1).parent, uint32(0));
    
    % im(4:16,1:6) = 1;
    tc.verifyEqual(f(2).area, A2);
    tc.verifyEqual(f(2).umin, 1);
    tc.verifyEqual(f(2).vmin, 4);
    tc.verifyEqual(f(2).umax, 6);
    tc.verifyEqual(f(2).vmax, 16);
    tc.verifyEqual(f(2).class, 1);
    tc.verifyEqual(f(2).touch, true);
    tc.verifyEqual(f(2).parent, uint32(0));
    tc.assertEqual(f(2).uc, 3.5, 'absTol', 1e-3);
    tc.assertEqual(f(2).vc, 10, 'absTol', 1e-3);
    tc.assertEqual(f(2).aspect, 0.456, 'absTol', 1e-3);
    tc.assertEqual(f(2).theta, pi/2, 'absTol', 1e-3);
    
    % im(8:12, 12:18) = 1;
    tc.verifyEqual(f(3).area, A3);
    tc.verifyEqual(f(3).umin, 12);
    tc.verifyEqual(f(3).vmin, 8);
    tc.verifyEqual(f(3).umax, 18);
    tc.verifyEqual(f(3).vmax, 12);
    tc.verifyEqual(f(3).class, 1);
    tc.verifyEqual(f(3).label, 3);
    tc.verifyEqual(f(3).touch, false);
    tc.verifyEqual(f(3).parent, uint32(1));
    tc.assertEqual(f(3).uc, 15, 'absTol', 1e-3);
    tc.assertEqual(f(3).vc, 10, 'absTol', 1e-3);
    
    tc.assertEqual(f(3).aspect, 1/sqrt(2), 'absTol', 1e-3);
    tc.assertEqual(f(3).theta, 0, 'absTol', 1e-3);
    
    f.plot_box();
    
    % test filters
    f = iblobs(im, 'class', 1);
    tc.verifyEqual(length(f), 2);
    tc.verifyEqual(f.class, [1 1]);
    f = iblobs(im, 'class', 0);
    tc.verifyEqual(f.class, [0]);
    
    f = iblobs(im, 'touch', 0);
    tc.verifyEqual(f.touch, [false]);
    
    f = iblobs(im, 'touch', 1)
    tc.verifyEqual(f.touch, [true true]);
    
    f = iblobs(im, 'area', [1 Inf]);
    tc.verifyEqual(length(f), 3);
    
    f = iblobs(im, 'area', [30 40]);
    tc.verifyEqual(length(f), 1);
    tc.verifyEqual(f.area, [A3]);
    
    f = iblobs(im, 'area', [50 100]);
    tc.verifyEqual(length(f), 1);
    tc.verifyEqual(f.area, [A2]);
    
    f = iblobs(im, 'area', [20 100], 'class', 1);
    tc.verifyEqual(length(f), 2);
    tc.verifyTrue(all(f.area >= 20) && all(f.area <=100));
    tc.verifyEqual(f.class, [1 1]);
    
    f = iblobs(im, 'area', [20 100], 'class', 1, 'touch', 1);
    tc.verifyEqual(length(f), 1);
    tc.verifyTrue(f.area >= 20 && f.area <=100);
    tc.verifyEqual(f.class, 1);
    tc.verifyEqual(f.touch, true);

    % test boundary stuff
    f = iblobs(im, 'boundary');
    s = char(f);
    tc.verifyEqual(size(s,1), 3);
    
    tc.assertEqual(f(2).perimeter, 34.0, 'absTol', 1e-4);
    tc.assertEqual(f(3).perimeter, 20.0, 'absTol', 1e-4);
    
    % test circularity on a big circle for accuracy
    im = kcircle(100); n = size(im,1);
    im = [ zeros(10,n+20); zeros(n,10) im zeros(n,10); zeros(10,n+20)];
    f = iblobs(im, 'boundary');
    tc.assertEqual(length(f), 2);
    tc.assertEqual(f(2).circularity, 1, 'absTol', 5e-3);
    
    f = iblobs(im, 'boundary');
    tc.assertEqual(length(f), 2);
    tc.assertEqual(f(2).circularity, 1, 'absTol', 5e-3);
    tc.assertEqual(f(2).aspect, 1, 1e-3);
    tc.assertEqual(f.class, [0 1]);
    
    % test a circularity filter, now that we have a circle
    f = iblobs(im, 'boundary', 'circularity', [0.9 2]);
    tc.assertEqual(length(f), 1);
    tc.assertEqual(f.circularity, 1, 'absTol', 5e-3);
    tc.assertEqual(f.aspect, 1, 'absTol', 5e-3);
    tc.assertEqual(f.class, 1);
    
end

function MSER_test(tc)
    tc.assumeTrue(exist('vl_mser') > 0)
    castle = iread('castle2.png', 'double', 'grey');
    [mser,nsets] = imser(castle, 'area', [100 20000]);
    tc.verifyEqual(nsets, 71);
    tc.verifyEqual(size(castle), size(mser));
    tc.verifyEqual( min(mser(:)), 0);
    tc.verifyEqual( max(mser(:)), nsets-1);
end

function graphseg_test(tc)
    tc.assumeTrue(exist('graphseg') > 0)
    im = iread('58060.jpg');
    [label, m] = igraphseg(im, 1500, 100, 0.5);
    tc.verifyEqual(m, 28);
    tc.verifyEqual(size(im(:,:,1)), size(label));
    tc.verifyEqual( min(label(:)), 1);
    tc.verifyEqual( max(label(:)), m);
end

