function ColorTest
  initTestSuite;
end

function colorname_test
    rgb = colorname('skyblue');
    assertAlmostEqual(rgb, [0 0.541176470588235 1], 'absolute', 1e-6);
    xy = colorname('skyblue', 'xy');
    assertAlmostEqual(xy, [0.184454842683699 0.184037626225452], 'absolute', 1e-6);

    s = colorname([.2 .3 .4]);
    assertEqual(s, 'darkslateblue');

    s = colorname([.2 .3]);
    assertEqual(s, 'cerulean');
end

function xycolor_test
    xycolorspace
    rg_addticks

    xy = colorname('skyblue', 'xy');
    xycolorspace(xy);
end

function loadspec_test
    lam = [400:10:700]*1e-9;

    brick = loadspectrum(lam, 'redbrick.dat');
    assertEqual(numrows(brick), length(lam));
    assertEqual(numcols(brick), 1);

    [brick,lam2] = loadspectrum(lam, 'redbrick.dat');
    assertEqual(lam, lam2);

    cones = loadspectrum(lam, 'cones.dat');
    assertEqual(numrows(brick), length(lam));
    assertEqual(numcols(brick), 3);
end

function specfuncs_test
    r = rluminos(555e-9);
    lam = [400:10:700]*1e-9;
    r = rluminos(lam);
    assertAlmostEqual(max(r), 1, 'absolute', 1e-6);
    assertAlmostEqual(min(r), 0, 'absolute', 1e-6);

    r = rluminos(555e-9);
    r = rluminos(lam);
 end

 function chrom_test
    rgb = lambda2rg(555e-9);
    xy = lambda2xy(555e-9);
 end

 function cmf_test
 end
