function ioTest
  initTestSuite;
end

function fileio_test
    % iread
    z = iread('lena.png');
    assertTrue(iscolor(z));
    assertTrue( isa(z, 'uint8'));

    z = iread('lena.pnm', 'double');
    assertFalse(iscolor(z));
    assertTrue( isa(z, 'double'));

    z = iread('lena.png', 'mono', 'double');
    assertFalse(iscolor(z));
    z = iread('lena.png', 'grey');
    assertFalse(iscolor(z));
    z = iread('lena.png', 'grey_709');
    assertFalse(iscolor(z));
    z = iread('lena.png', 'grey');
    assertFalse(iscolor(z));

    sz = size(z);
    z = iread('lena.png', 'reduce', 2);
    assertEqual( size(z)*2, sz);

    z = iread('lena.png', 'roi', [100 200; 200 350]);
    assertEqual(size(z), [150 100]);

    % pnmfilt
    z2 = pnmfilt(z, 'pnmrotate 30');
    assertEqual(size(z2), size(z));
end


function idisp_test
    z = iread('lena.png');
    zm = imono(z);

    idisp(z);
    idisp(zm);

    clf
    subplot(211)
    idisp(z, 'axis', gca);

    clf
    idisp(z, 'nogui');

    clf
    idisp(z, 'noaxes');

    clf
    idisp(z, 'plain');

    clf
    idisp(z, 'title', 'test title');

    clf
    idisp(z, 'clickfunc', @(x,y) fprintf('hello %d %d\n', x,y));

    clf
    idisp(zm, 'histeq');

    clf
    idisp(zm, 'bar');

    clf
    idisp(z, 'print', 'test.eps');
    assertTrue( exist('test.eps', 'file') > 0 );
    system('rm -f test.eps');

    clf
    idisp(z, 'square');

    clf
    idisp(z, 'wide');
    close all

    clf
    idisp(z, 'flatten');
    close all

    clf
    idisp(z, 'ynormal');

    clf
    idisp(zm, 'cscale', [0.2 0.8]);

    clf
    idisp(z, 'xydata', linspace(0,5, 10), linspace(0,5,10));

    clf
    idisp(z, 'grey');

    clf
    idisp(z, 'invert');

    clf
    idisp(z, 'signed');

    clf
    idisp(z, 'invsigned');

    clf
    idisp(z, 'random');

    clf
    idisp(z, 'dark');

    clf
    idisp(z, 'colormap', jet);

    clf
    idisp(z, 'invsigned');

    clf
    idisp(zm, 'ncolors', 32);

    clf
    stdisp(zm, zm);
end

