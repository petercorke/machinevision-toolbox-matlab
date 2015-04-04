function tests = LineFeatureTest
    tests = functiontests(localfunctions)
end

function ihough_test(testCase)

    im = testpattern('squares', 256, 256, 128); 
    im = irotate(im, -0.3);
    edges = icanny(im);
    h = Hough(edges)

    s = h.char();
    h.display;
    h.show()
    h.plot();
    h.plot('b');

    im = [0 0 0; 0 1 0; 0 0 0];
    h = Hough(im, 'nbins', [6 5]);
    verifyEqual(testCase,  size(h.A), [5 6]);
    h = Hough(im, 'nbins', 4);
    verifyEqual(testCase,  size(h.A), [5 4]);

    edge = [
        0 0 0
        0 1 1
        0 0 0];
    out = [
        0     0     0     0
        2     0     0     0
        0     2     0     0
        0     0     2     1
        0     0     0     1
     ];
     verifyEqual(testCase,  h.A, out);

     % test vote weighting
     h = Hough(im*2, 'nbins', 4);
     verifyEqual(testCase,  h.A, out*2);
     h = Hough(im*2, 'nbins', 4, 'equal');
     verifyEqual(testCase,  h.A, out);
     h = Hough([2 2], 'nbins', 4, 'equal');
     verifyEqual(testCase,  h.A, out);

     % test point, rather than image, mode
%      h=Hough([2 3; 2 2], 'points', 'nbins', 4)
%      verifyEqual(testCase,  h.A, out);
end

function line_test(testCase)
    im = testpattern('squares', 256, 256, 128); 
    im = irotate(im, -0.3);
    edges = icanny(im);
    h = Hough(edges, 'suppress', 5)

    lines = h.lines();
    lines = lines.seglength(edges);

    verifyEqual(testCase,  numel(lines), 4);
    verifyEqual(testCase,  length(lines.theta), 4);
    verifyEqual(testCase,  length(lines.rho), 4);
    verifyEqual(testCase,  length(lines.length), 4);
    verifyEqual(testCase,  length(lines.strength), 4);
end
