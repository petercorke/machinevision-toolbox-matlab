function tests = ColorTest(testCase)
    tests = functiontests(localfunctions);
    clc
end

function teardownOnce(testCase)
    close all
end

function colorname_test(testCase)
    rgb = colorname('skyblue');
    verifyEqual(testCase, rgb, [0 0.541176470588235 1], 'AbsTol', 1e-6);
    
    xy = colorname('skyblue', 'xy');
    verifyEqual(testCase, xy, [0.180179904027058 0.168619966433637], 'AbsTol', 1e-6);

    s = colorname([.2 .3 .4]);
    verifyEqual(testCase, s, 'darkslateblue');

    s = colorname([.2 .3], 'xy');
    verifyEqual(testCase, s, 'cerulean');
end

function showcolorspace_test(testCase)
    clf
    showcolorspace('xy')
    clf
    showcolorspace('xy', [.2 .3; .3 4]')
    
    clf
    showcolorspace('Lab')
    clf
    showcolorspace('xy', [.2 .3; .3 4]')


end

function loadspec_test(testCase)
    lam = [400:10:700]*1e-9;

    brick = loadspectrum(lam, 'redbrick.dat');
    verifyEqual(testCase, numrows(brick), length(lam));
    verifyEqual(testCase, numcols(brick), 1);

    [brick,lam2] = loadspectrum(lam, 'redbrick.dat');
    verifyEqual(testCase, lam, lam2');

    cones = loadspectrum(lam, 'cones.dat');
    verifyEqual(testCase, numrows(cones), length(lam));
    verifyEqual(testCase, numcols(cones), 3);
end

function specfuncs_test(testCase)
    r = rluminos(555e-9);
    lam = [400:5:700]*1e-9;
    r = rluminos(lam);
    verifyEqual(testCase, max(r), 1, 'AbsTol', 1e-3);
    verifyEqual(testCase, min(r), 0, 'AbsTol', 1e-3);

    r = rluminos(555e-9);
    r = rluminos(lam);
 end

 function chrom_test(testCase)
    rgb = lambda2rg(555e-9);
    xy = lambda2xy(555e-9);
 end

 function cmf_test(testCase)
 end
