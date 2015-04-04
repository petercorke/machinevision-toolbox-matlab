function PointFeatureTest(testCase)
    tests = functiontests(localfunctions);
end


function Corner_test(testCase)

    b1 = iread('building2-1.png', 'grey', 'double');
    C = icorner(b1, 'nfeat', 200);
    verifyEqual(testCase, length(C), 200);
    ss = char(C);
    C(1:5).u;
    C(1:5).v;
    C(1:5).strength;
    d = C(1:5).descriptor
    verifySize(testCase, d, [3 5]);


    C = icorner(b1, 'nfeat', 200, 'suppress', 10);

    C = icorner(b1, 'nfeat', 200, 'suppress', 10, 'detector', 'noble');
    C = icorner(b1, 'nfeat', 200, 'suppress', 10, 'detector', 'klt');

    C = icorner(b1, 'nfeat', 200, 'sigma', 3);
    C = icorner(b1, 'nfeat', 200, 'k', 0.06);
    C = icorner(b1, 'nfeat', 200, 'patch',3);
    d = C(1:5).descriptor
    verifySize(testCase, d, [9 5]);

    idisp(b1);
    C.plot();
end

function ScaleSpace_test(testCase)
    im = iread('scale-space.png', 'double');

    [G,L,s] = iscalespace(im, 60, 2);
    verifySize(testCase, G, [200 200 60]);
    verifySize(testCase, L, [200 200 59]);
    verifySize(testCase, s, [60 1]);
    f = iscalemax(L, s)
    verifyEqual(testCase, length(f), 6);
    ss = char(f);
    f(1:5).u;
    f(1:5).v;
    f(1:5).strength;
    f(1:5).sigma;

    idisp(im);
    f.plot('r')
    f.plot_scale('r')
end

function SIFT_test(testCase)
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
    verifyEqual(testCase, length(s), 50);
    verifySize(testCase, s, [128 50]);

    s = isift(b1, 'suppress', 5)
end

function SURF_test(testCase)
    b1 = iread('building2-1.png', 'grey', 'double');
    s = isurf(b1)
    ss = char(s);
    s(1:5).u;
    s(1:5).v;
    s(1:5).strength;
    s(1:5).sigma;
    s(1:5).theta;

    s = isurf(b1, 'nfeat', 50)
    verifyEqual(testCase, length(s), 50);
    verifySize(testCase, s, [128 50]);

    s = isurf(b1, 'suppress', 5)
end
