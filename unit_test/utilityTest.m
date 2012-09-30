function utilityTest
  initTestSuite;
end

function idouble_test
    % test for uint8
    assertEqual( idouble( cast(0, 'uint8')), 0);
    assertEqual( idouble( cast(128, 'uint8')), 128/255);
    assertEqual( idouble( cast(255, 'uint8')), 1);

    % test for uint16
    assertEqual( idouble( cast(0, 'uint16')), 0);
    assertEqual( idouble( cast(128, 'uint16')), 128/65535);
    assertEqual( idouble( cast(65535, 'uint16')), 1);

    i = cast(randi(100, [5 5]), 'uint8');
    a = idouble(i);
    assertEqual(size(a), size(i));
    assertEqual(a, double(i)/255);

    i = cast(randi(100, [5 5]), 'uint16');
    a = idouble(i);
    assertEqual(a, double(i)/65535);

end

function iint_test
    % test for uint8
    assertEqual( iint(0),  cast(0, 'uint8'));
    assertEqual( iint(1),  cast(255, 'uint8'));

    % test for uint16
    assertEqual( iint(0, 'uint16'),  cast(0, 'uint16'));
    assertEqual( iint(1, 'uint16'),  cast(65535, 'uint16'));

    a = rand([5 5]);
    i = iint(a);
    assertEqual(size(a), size(i));

    a = rand([5 5 3]);
    i = iint(a);
    assertEqual(size(a), size(i));

end

function igamma_test
    a = 0.4;
    g = igamma(a, 0.5);
    assertEqual( g*g, a);

    a = 64;
    g = igamma(a, 0.5);
    assertEqual( g*g, a);

    igamma(a, 'sRGB');  % test this option parses

    a = rand(5,5);
    g = igamma(a, 0.5);
    assertEqual(size(a), size(g));
    assertAlmostEqual( igamma(g, 2), a, 'absolute', 1e-4);

    a = rand(5,5, 3);
    g = igamma(a, 0.5);
    assertEqual(size(a), size(g));
end

function im2col_test
    a = rand(5,5,3);

    c = im2col(a);

    assertEqual(c(1,:), squeeze(a(1,1,:))');
    assertEqual(c(25,:), squeeze(a(5,5,:))');

    assertEqual( col2im(c, a), a);
    assertEqual( col2im(c, size(a)), a);

    mask = zeros(5,5);
    mask(2,3) = 1;
    c = im2col(a, mask);
    assertEqual( c, a(2,3,:) );
    c = im2col(a, mask(:));
    assertEqual( c, a(2,3,:) );

    i = find(mask > 1);
    c = im2col(a, i);
    assertEqual( c, a(2,3,:) );

end

function iisum_test
    a = [
        1 2 3 4
        4 5 6 7
        3 2 1 4
        ];
    out = intgimage(a);

    % test the integral image
    assertEqual( out(1,1), 1);
    assertEqual( out(1,2), 1+2);
    assertEqual( out(2,1), 4+1);
    assertEqual( out(2,2), 1+2+4+5);

    assertEqual( iisum(out, 2, 2, 2, 2), 5);    % single
    assertEqual(iisum(out, 2, 2, 2, 3), 11);    % row
    assertEqual(iisum(out, 2, 3, 2, 2), 7);     % col
    assertEqual(iisum(out, 1, 2, 1, 2), 1+2+4+5); % block at origin
    assertEqual(iisum(out, 2, 3, 2, 3), 5+6+2+1);     % col

end

function line_test

    a = zeros(3,3);
    out = iline(a, [1 1], [3 1]);
    assertEqual(out, [1 1 1; 0 0 0; 0 0 0]);
    out = iline(a, [1 1], [3 1], 5);
    assertEqual(out, [5 5 5; 0 0 0; 0 0 0]);

    a = zeros(3,3);
    out = iline(a, [2 1], [2 3]);
    assertEqual(out, [0 1 0; 0 1 0; 0 1 0]);

    a = zeros(3,3);
    out = iline(a, [1 1], [3 3]);
    assertEqual(out, [1 0 0; 0 1 0; 0 0 1]);

    assertEqual(iprofile(out, [1 1], [3 3]), [1 1 1]');

    % test for color image
    out = cat(3, out, 2*out, 3*out);
    assertEqual(squeeze(iprofile(out, [1 1], [3 3])), [1 2 3; 1 2 3; 1 2 3]);
end

function mesh_test
    im = rand(3,3);
    [u,v] = imeshgrid(im);
    assertEqual(u, [1 2 3; 1 2 3; 1 2 3]);
    assertEqual(v, [1 1 1; 2 2 2; 3 3 3]);

    [u,v] = imeshgrid(3, 3);
    assertEqual(u, [1 2 3; 1 2 3; 1 2 3]);
    assertEqual(v, [1 1 1; 2 2 2; 3 3 3]);

    [u,v] = imeshgrid(3);
    assertEqual(u, [1 2 3; 1 2 3; 1 2 3]);
    assertEqual(v, [1 1 1; 2 2 2; 3 3 3]);

    [u,v] = imeshgrid([3 3]);
    assertEqual(u, [1 2 3; 1 2 3; 1 2 3]);
    assertEqual(v, [1 1 1; 2 2 2; 3 3 3]);
end

function mono_test

    im = rand(3,3,3);
    m = imono(im);
    assertEqual(size(m), [3 3]);
    assertTrue( min(m(:)) >= 0);
    assertTrue( max(m(:)) <= 1);

    m2 = imono(m);
    assertEqual(size(m), size(m2));

    im = randi(3,3,3, 'uint8');
    m = imono(im);
    assertEqual(size(m), [3 3]);
    assertTrue( min(m(:)) >= 0);
    assertTrue( max(m(:)) <= 255);
end

function icolor_test
    im = rand(3,3);

    out = cat(3, im, im, im);
    assertEqual(icolor(im), out); 

    out = cat(3, im, 0*im, im);
    assertEqual(icolor(im, [1 0 1]), out); 
end

function colorize_test
    im = [
        1 2 3
        1 2 3
        1 3 3
        ]/10;

    out = colorize(im, im>0.2, [0 0 1]);
    assertEqual(out(1,1,:), [1 1 1]/10);
    assertEqual(out(1,3,:), [0 0 1]);

    out = colorize(im, @(x) x>0.2, [0 0 1]);
    assertEqual(out(1,1,:), [1 1 1]/10);
    assertEqual(out(1,3,:), [0 0 1]);
end

function pad_test
    im = [1 2; 3 4];

    assertEqual(ipad(im, 't', 2), [0 0; 0 0; 1 2; 3 4]);
    assertEqual(ipad(im, 'b', 2), [1 2; 3 4; 0 0; 0 0]);
    assertEqual(ipad(im, 'l', 2), [0 0 1 2; 0 0 3 4]);
    assertEqual(ipad(im, 'r', 2), [1 2 0 0; 3 4 0 0]);
    assertEqual(ipad(im, 'bl', 2), [ 0 0 1 2; 0 0 3 4; 0 0 0 0; 0 0 0 0]);

    assertEqual(ipad(im, 'bl', 2, 9), [ 9 9 1 2; 9 9 3 4; 9 9 9 9; 9 9 9 9]);
end

function paste_test
    im = [1 2 3; 4 5 6; 7 8 9];

    canvas = zeros(5,5);

    out = [
        0 0 0 0 0
        0 0 1 2 3
        0 0 4 5 6
        0 0 7 8 9
        0 0 0 0 0
        ];
     assertEqual( ipaste(canvas, im, [3 2]), out);
     assertEqual( ipaste(canvas, im, [4 3], 'centre'), out);
     assertEqual( ipaste(canvas, im, [2 1], 'zero'), out);
     assertEqual( ipaste(canvas, im, [3 2], 'set'), out);
     assertEqual( ipaste(canvas, im, [3 2], 'mean'), out/2);
     canvas = ipaste(canvas, im, [3 2], 'add');
     canvas = ipaste(canvas, im, [3 2], 'add');
     assertEqual(canvas, 2*out);
end

function pixswitch_test
    a = [1 2; 3 4];
    b = [5 6; 7 8];

    assertEqual(ipixswitch(logical(zeros(2,2)), a, b), b);
    assertEqual(ipixswitch(logical(ones(2,2)), a, b), a);
    assertEqual(ipixswitch(logical([0 1; 1 0]), a, b), [5 2; 3 8] );

    a = rand(2,2,3);
    b = rand(2,2,3);
    out = ipixswitch(logical([0 1; 0 0]), a, b);
    assertEqual(out(1,1,:), b(1,1,:));
    assertEqual(out(1,2,:), a(1,1,:));
end

function decimate_test
    a = [1 2; 3 4];

    b = ireplicate(a);
    assertEqual(a, b);

    b = ireplicate(a, 2);
    assertEqual(b, [1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4]);

    assertEqual( idecimate(b, []), a);
end

function roi_test
    a = [
        1  2  3  4
        5  6  7  8
        9 10 11 12
        ];

    out = iroi(a, [2 4; 2 3]);
    assertEqual( out, [6 7 8; 10 11 12]);
    [out,r] = iroi(a, [2 4; 2 3]);
    asertEqual(r, [2 4; 2 3]);
end

function iscolor_test
    assertFalse( iscolor(rand(3,3)) );
    assertTrue( iscolor(rand(3,3,3)) );
    assertTrue( iscolor(rand(3,3,3,4)) );
end

function isize_test
    im = rand(5,6,3,4);
    assertEqual(isize(im,1), 5);
    assertEqual(isize(im,2), 6);
    assertEqual(isize(im,3), 3);
    assertEqual(isize(im,4), 4);
    [w,h] = isize(im);
    assertEqual(w, 6);
    assertEqual(h, 5);
    [w,h,p] = isize(im);
    assertEqual(w, 6);
    assertEqual(h, 5);
    assertEqual(p, 3);
end

function istretch_test
    im = [0.1 0.35; 0.35 0.6];
    assertAlmostEqual(istretch(im), [0 2; 2 4]/4, 'absolute', 1e-6);

    assertAlmostEqual(istretch(im, 4), [0 2; 2 4], 'absolute', 1e-6);
end

function kernel_test
    out = [
     0     1     0
     1     1     1
     0     1     0
    ];
    assertEqual( kcircle(1), out);

    out = [
     0     0     1     0     0
     0     1     1     1     0
     1     1     1     1     1
     0     1     1     1     0
     0     0     1     0     0
    ];
    assertEqual( kcircle(2), out);

    out = [
     0     1     0
     0     1     0
     1     1     1
    ];
    assertEqual( ktriangle(3), out);

    out = [
     0     0     1     0     0
     0     0     1     0     0
     0     1     1     1     0
     0     1     1     1     0
     1     1     1     1     1
    ];
    assertEqual( ktriangle(4), out);

    out = [
    -1     0     1
    -2     0     2
    -1     0     1
    ];
    assertEqual( ksobel, out);

    out = [
    0 1 0
    1 -4 1
    0 1 0
    ];
    assertEqual( klaplace, out);

    g = kgauss(2);
    assertEqual(size(g), [13 13]);
    assertTrue(g(7,7) >= max(g(:)));

    g = kgauss(2, 11);
    assertEqual(size(g), [23 23]);
    assertAlmostEqual(sum(g(:)), 1, 'absolute', 1e-6);

    % test they run
    k = klog(1);
    k = kdgauss(1);
    k = kdog(1);
    k = kdog(2,1);
end

function kmeans_test
    x = [];
    for i=1:5
        x = [x bsxfun(@plus, randn(3,10), randi(50, [3 1]))];
    end

    [L,C] = kmeans(x, 5);
    assertEqual( numcols(L), numcols(x));
    assertEqual( numcols(C), 5);
    assertEqual( numrows(C), numrows(x));
    [L,C] = kmeans(x, 5, 'spread');
    [L,C] = kmeans(x, 5, 'random');

    L = kmeans(x, C);
end

function mkgrid_test
    out = [
   -1.5000   -1.5000    1.5000    1.5000
   -1.5000    1.5000    1.5000   -1.5000
         0         0         0         0
    ];
    assertAlmostEqual(mkgrid(2, 3), out, 'absolute', 1e-6);
    out = [
   -1.5000   -1.5000    1.5000    1.5000
   -1.5000    1.5000    1.5000   -1.5000
         5         5         5         5
    ];
    assertAlmostEqual(mkgrid(2, 3, 'T', transl(0,0,5)), out, 'absolute', 1e-6);
end

function mkcube_test
    out = [
    -1    -1     1     1    -1    -1     1     1
    -1     1     1    -1    -1     1     1    -1
    -1    -1    -1    -1     1     1     1     1
    ];
    assertEqual(mkcube(2), out);
 out = [
-1 -1 1 1 -1 -1 1 1 1 -1 0 0 0 0
 -1 1 1 -1 -1 1 1 -1 0 0 1 -1 0 0
 -1 -1 -1 -1 1 1 1 1 0 0 0 0 1 -1
];
    assertEqual(mkcube(2, 'facepoint'), out);

out = [
     0     0     2     2     0     0     2     2
     1     3     3     1     1     3     3     1
     2     2     2     2     4     4     4     4
];
    assertEqual(mkcube(2, 'centre', [1 2 3]), out);
    assertEqual(mkcube(2, 'T', transl([1 2 3])), out);

x = [
    -1    -1     1     1    -1
    -1    -1     1     1    -1 ];
y = [
    -1     1     1    -1    -1
    -1     1     1    -1    -1 ];
z = [
    -1    -1    -1    -1    -1
     1     1     1     1     1 ];

    [xx,yy,zz] = mkcube(2, 'edge');
    assertEqual(x, xx);
    assertEqual(y, yy);
    assertEqual(z, zz);
end

function moment_test
    im = [
        0 0 0 0
        0 0 0 0
        0 1 1 0
        0 1 1 0
        0 1 1 0
        0 0 0 0
    ];
    assertEqual(mpq(im, 0, 0), 6);
    assertEqual(mpq(im, 1, 0), 15);
    assertEqual(mpq(im, 0, 1), 24);
    assertEqual(mpq(im, 1, 1), 60);
    assertEqual(mpq(im, 2, 0), 39);
    assertEqual(mpq(im, 0, 2), 100);

    assertEqual(upq(im, 0, 0), 6);
    assertEqual(upq(im, 1, 0), 0);
    assertEqual(upq(im, 0, 1), 0);
    assertEqual(upq(im, 1, 1), 0);
    assertEqual(upq(im, 2, 0), 1.5);
    assertEqual(upq(im, 0, 2), 4);

    assertEqual(npq(im, 2, 0), 1/24);
    assertEqual(npq(im, 0, 2), 1/9);

    p = [
        2 4 4 2
        3 3 6 6
        ];
    assertEqual(mpq_poly(p, 0, 0), 6);
    assertEqual(mpq_poly(p, 1, 0), 18);
    assertEqual(mpq_poly(p, 0, 1), 27);
    assertEqual(mpq_poly(p, 1, 1), 81);
    assertEqual(mpq_poly(p, 2, 0), 56);
    assertEqual(mpq_poly(p, 0, 2), 126);

    assertEqual(upq_poly(p, 0, 0), 6);
    assertEqual(upq_poly(p, 1, 0), 0);
    assertEqual(upq_poly(p, 0, 1), 0);
    assertEqual(upq_poly(p, 1, 1), 0);
    assertEqual(upq_poly(p, 2, 0), 2);
    assertEqual(upq_poly(p, 0, 2), 4.5);

    assertEqual(npq_poly(p, 2, 0), 1/18);
    assertEqual(npq_poly(p, 0, 2), 1/8);
end

function testpattern_test
    im = testpattern('rampx', 10, 2);
    assertEqual(size(im), [10 10]);
    im = testpattern('rampx', [20 10], 2);
    assertEqual(size(im), [10 20]);

    assertEqual(im(6,:), [linspace(0, 1, 6) linspace(0, 1, 6)]);
    assertEqual(im(:,2), ones(12,1)*0.2 );

    im = testpattern('rampy', 10, 2)';
    assertEqual(im(6,:), [linspace(0, 1, 6) linspace(0, 1, 6)]);
    assertEqual(im(:,2), ones(12,1)*0.2 );

    im = testpattern('sinx', 12, 1);
    assertAlmostEqual(sum(im), 0, 'absolute', 1e-6);
    assertAlmostEqual(diff(im(:,3)), zeros(12,1), 'absolute', 1e-6);
    im = testpattern('siny', 12, 1)';
    assertAlmostEqual(sum(im), 0, 'absolute', 1e-6);
    assertAlmostEqual(diff(im(:,3)), zeros(12,1), 'absolute', 1e-6);

    im = testpattern('dots', 100, 20, 10);
    [l,ml,p,c] = ilabel(im);
    assertEqual(sum(c), 25);

    im = testpattern('squares', 100, 20, 10);
    [l,ml,p,c] = ilabel(im);
    assertEqual(sum(c), 25);

    im = testpattern('line', 20, pi/6, 10);
    assertEqual(im(11,2), 1);
    assertEqual(im(29,17), 1);
    assertEqual(sum(im(:)), 18);
end

function similarity_test
    a = rand(3,3);

    assertTrue( abs( sad(a,a) ) < eps);
    assertFalse( abs( sad(a,a+0.1) ) < eps);

    assertTrue( abs( zsad(a,a) ) < eps);
    assertTrue( abs( zsad(a,a+0.1) ) < eps);

    assertTrue( abs( ssd(a,a) ) < eps);
    assertFalse( abs( ssd(a,a+0.1) ) < eps);

    assertTrue( abs( zssd(a,a) ) < eps);
    assertTrue( abs( zssd(a,a+0.1) ) < eps);

    assertTrue( abs( 1-ncc(a,a) ) < eps);
    assertTrue( abs( 1-ncc(a,a*2) ) < eps);

    assertTrue( abs( 1-zncc(a,a) ) < eps);
    assertTrue( abs( 1-zncc(a,a+0.1) ) < eps);
    assertTrue( abs( 1-zncc(a,a*2) ) < eps);

    im = [
          5    10     7     7     7    12    12    11   7
           5     4     7    12     2     7     5    11  7
         3     1     8    10     3     7     8    10   3
         2    11     3     7     4     2     7     9   1
        10     9    12     3     2     1    12     8  2
         1     9     7     4     5     6     7     9  12
         4    10    10     8     9     7    11     4  1
        11     4     3    12    10     7     1     6  6
         6     3     4     5     2     9     1    11   3
         11     8     1     2     7     1    11     4  12
          6     4     6     4    10     7     5     8  4
    ];
    % true match is at x=5, y=6
    template = [
        3 2 1
        4 5 6
        8 9 7
    ];
    xm = imatch(im, im, 4, 4, 1, 2);
    assertEqual(xm, [0 0 1]);
    [xm,s] = imatch(im, im, 5, 4, 1, 2);
    assertEqual(size(s), [5 5]);
    %% BUG ?? assertEqual(s(

    s = isimilarity(template, im);
    assertEqual(size(s), size(im));
    assertEqual(s(4,5), 1);
end


function zcross_test
    a = [
        3  2  1 -1 -2
        3  2  1 -1 -2
        2  1  1 -2 -3
        1  1 -1 -3 -4
       -1 -1 -2 -3 -4
       ];
    out = [
        0     0     0     0     0
        0     0     1     0     0
        0     0     1     0     0
        0     1     1     0     0
        0     0     0     0     0
    ];
    assertEqual(zcross(a), out);
end

function hu_test
    im = [
        0 0 0 0 0 0 0
        0 1 1 1 0 0 0
        0 0 1 1 0 0 0
        0 1 1 1 1 1 0
        0 1 1 1 1 1 0
        0 0 0 1 1 0 0
        0 0 0 0 0 0 0
        ];

    out = [
        0.184815794830043
        0.004035534812971
        0.000533013844814
        0.000035606641461
        0.000000003474073
        0.000000189873096
        -0.000000003463063
        ];
    assertAlmostEqual(im, out, 'absolute', 1e-8);
    
end

function ilut_test
    im = cast([1 3; 2 4], 'uint8');
    lut = [10 11 12 13 14]';

    assertEqual(ilut(im, lut), [11 13; 12 14]);

    lut = [
        10 11
        12 13
        14 15
        16 17
        18 19];
    out = cat(3, [12 16;14 18], [13 17; 15 19]);

    assertEqual(ilut(im, lut), out);
end
