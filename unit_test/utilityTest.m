function utilityTest(testCase)
    tests = functiontests(localfunctions);
end

function idouble_test(testCase)
    % test for uint8
    verifyEqual(testCase,  idouble( cast(0, 'uint8')), 0);
    verifyEqual(testCase,  idouble( cast(128, 'uint8')), 128/255);
    verifyEqual(testCase,  idouble( cast(255, 'uint8')), 1);

    % test for uint16
    verifyEqual(testCase,  idouble( cast(0, 'uint16')), 0);
    verifyEqual(testCase,  idouble( cast(128, 'uint16')), 128/65535);
    verifyEqual(testCase,  idouble( cast(65535, 'uint16')), 1);

    i = cast(randi(100, [5 5]), 'uint8');
    a = idouble(i);
    verifyEqual(testCase, size(a), size(i));
    verifyEqual(testCase, a, double(i)/255);

    i = cast(randi(100, [5 5]), 'uint16');
    a = idouble(i);
    verifyEqual(testCase, a, double(i)/65535);
end

function iint_test(testCase)
    % test for uint8
    verifyEqual(testCase,  iint(0),  cast(0, 'uint8'));
    verifyEqual(testCase,  iint(1),  cast(255, 'uint8'));

    % test for uint16
    verifyEqual(testCase,  iint(0, 'uint16'),  cast(0, 'uint16'));
    verifyEqual(testCase,  iint(1, 'uint16'),  cast(65535, 'uint16'));

    a = rand([5 5]);
    i = iint(a);
    verifyEqual(testCase, size(a), size(i));

    a = rand([5 5 3]);
    i = iint(a);
    verifyEqual(testCase, size(a), size(i));
end

function igamma_test(testCase)
    a = 0.4;
    g = igamm(a, 0.5);
    verifyEqual(testCase,  g*g, a);

    a = 64;
    g = igamm(a, 0.5);
    verifyEqual(testCase,  g*g, a);

    igamm(a, 'sRGB');  % test this option parses

    a = rand(5,5);
    g = igamm(a, 0.5);
    verifyEqual(testCase, size(a), size(g));
    assertAlmostEqual( igamm(g, 2), a, 'absTol', 1e-4);

    a = rand(5,5, 3);
    g = igamm(a, 0.5);
    verifyEqual(testCase, size(a), size(g));
end

function im2col_test(testCase)
    a = rand(5,5,3);

    c = im2col(a);

    verifyEqual(testCase, c(1,:), squeeze(a(1,1,:))');
    verifyEqual(testCase, c(25,:), squeeze(a(5,5,:))');

    verifyEqual(testCase,  col2im(c, a), a);
    verifyEqual(testCase,  col2im(c, size(a)), a);

    mask = zeros(5,5);
    mask(2,3) = 1;
    c = im2col(a, mask);
    verifyEqual(testCase,  c, a(2,3,:) );
    c = im2col(a, mask(:));
    verifyEqual(testCase,  c, a(2,3,:) );

    i = find(mask > 1);
    c = im2col(a, i);
    verifyEqual(testCase,  c, a(2,3,:) );

end

function iisum_test(testCase)
    a = [
        1 2 3 4
        4 5 6 7
        3 2 1 4
        ];
    out = intgimage(a);

    % test the integral image
    verifyEqual(testCase,  out(1,1), 1);
    verifyEqual(testCase,  out(1,2), 1+2);
    verifyEqual(testCase,  out(2,1), 4+1);
    verifyEqual(testCase,  out(2,2), 1+2+4+5);

    verifyEqual(testCase,  iisum(out, 2, 2, 2, 2), 5);    % single
    verifyEqual(testCase, iisum(out, 2, 2, 2, 3), 11);    % row
    verifyEqual(testCase, iisum(out, 2, 3, 2, 2), 7);     % col
    verifyEqual(testCase, iisum(out, 1, 2, 1, 2), 1+2+4+5); % block at origin
    verifyEqual(testCase, iisum(out, 2, 3, 2, 3), 5+6+2+1);     % col
end

function line_test(testCase)

    a = zeros(3,3);
    out = iline(a, [1 1], [3 1]);
    verifyEqual(testCase, out, [1 1 1; 0 0 0; 0 0 0]);
    out = iline(a, [1 1], [3 1], 5);
    verifyEqual(testCase, out, [5 5 5; 0 0 0; 0 0 0]);

    a = zeros(3,3);
    out = iline(a, [2 1], [2 3]);
    verifyEqual(testCase, out, [0 1 0; 0 1 0; 0 1 0]);

    a = zeros(3,3);
    out = iline(a, [1 1], [3 3]);
    verifyEqual(testCase, out, [1 0 0; 0 1 0; 0 0 1]);

    verifyEqual(testCase, iprofile(out, [1 1], [3 3]), [1 1 1]');

    % test for color image
    out = cat(3, out, 2*out, 3*out);
    verifyEqual(testCase, squeeze(iprofile(out, [1 1], [3 3])), [1 2 3; 1 2 3; 1 2 3]);
end

function mesh_test(testCase)
    im = rand(4,6);
    [u0,v0] = meshgrid(1:6, 1:4);

    [u,v] = imeshgrid(im);
    verifyEqual(testCase, u, u0);
    verifyEqual(testCase, v, v0);

    [u,v] = imeshgrid(im, 1);
    verifyEqual(testCase, u, u0);
    verifyEqual(testCase, v, v0);

    [u,v] = imeshgrid(im, [1 1]);
    verifyEqual(testCase, u, u0);
    verifyEqual(testCase, v, v0);

    [u,v] = imeshgrid(6, 4);
    verifyEqual(testCase, u, u0);
    verifyEqual(testCase, v, v0);

    [u,v] = imeshgrid(1:6, 1:4);
    verifyEqual(testCase, u, u0);
    verifyEqual(testCase, v, v0);

    [u,v] = imeshgrid(im, 2);
    verifyEqual(testCase, u, u0(1:2:end,1:2:end));
    verifyEqual(testCase, v, v0(1:2:end,1:2:end));

    [u,v] = imeshgrid(im, [1 2]);
    verifyEqual(testCase, u, u0(1:2:end,:));
    verifyEqual(testCase, v, v0(1:2:end,:));

    [u,v] = imeshgrid(im, [2 1]);
    verifyEqual(testCase, u, u0(:,1:2:end));
    verifyEqual(testCase, v, v0(:,1:2:end));

    im = rand(6,6);
    [u0,v0] = meshgrid(1:6, 1:6);

    [u,v] = imeshgrid(6);
    verifyEqual(testCase, u, u0);
    verifyEqual(testCase, v, v0);
end

function mono_test(testCase)

    im = rand(3,3,3);
    m = imono(im);
    verifyEqual(testCase, size(m), [3 3]);
    verifyTrue(testCase,  min(m(:)) >= 0);
    verifyTrue(testCase,  max(m(:)) <= 1);

    m2 = imono(m);
    verifyEqual(testCase, size(m), size(m2));

    im = randi(3,3,3, 'uint8');
    m = imono(im);
    verifyEqual(testCase, size(m), [3 3]);
    verifyTrue(testCase,  min(m(:)) >= 0);
    verifyTrue(testCase,  max(m(:)) <= 255);
end

function icolor_test(testCase)
    im = rand(3,3);

    out = cat(3, im, im, im);
    verifyEqual(testCase, icolor(im), out); 

    out = cat(3, im, 0*im, im);
    verifyEqual(testCase, icolor(im, [1 0 1]), out); 
end

function colorize_test(testCase)
    im = [
        1 2 3
        1 2 3
        1 3 3
        ]/10;

    out = colorize(im, im>0.2, [0 0 1]);
    verifyEqual(testCase, out(1,1,:), [1 1 1]/10);
    verifyEqual(testCase, out(1,3,:), [0 0 1]);

    out = colorize(im, @(x) x>0.2, [0 0 1]);
    verifyEqual(testCase, out(1,1,:), [1 1 1]/10);
    verifyEqual(testCase, out(1,3,:), [0 0 1]);
end

function pad_test(testCase)
    im = [1 2; 3 4];

    verifyEqual(testCase, ipad(im, 't', 2), [0 0; 0 0; 1 2; 3 4]);
    verifyEqual(testCase, ipad(im, 'b', 2), [1 2; 3 4; 0 0; 0 0]);
    verifyEqual(testCase, ipad(im, 'l', 2), [0 0 1 2; 0 0 3 4]);
    verifyEqual(testCase, ipad(im, 'r', 2), [1 2 0 0; 3 4 0 0]);
    verifyEqual(testCase, ipad(im, 'bl', 2), [ 0 0 1 2; 0 0 3 4; 0 0 0 0; 0 0 0 0]);

    verifyEqual(testCase, ipad(im, 'bl', 2, 9), [ 9 9 1 2; 9 9 3 4; 9 9 9 9; 9 9 9 9]);
end

function paste_test(testCase)
    im = [1 2 3; 4 5 6; 7 8 9];

    canvas = zeros(5,5);

    out = [
        0 0 0 0 0
        0 0 1 2 3
        0 0 4 5 6
        0 0 7 8 9
        0 0 0 0 0
        ];
     verifyEqual(testCase,  ipaste(canvas, im, [3 2]), out);
     verifyEqual(testCase,  ipaste(canvas, im, [4 3], 'centre'), out);
     verifyEqual(testCase,  ipaste(canvas, im, [2 1], 'zero'), out);
     verifyEqual(testCase,  ipaste(canvas, im, [3 2], 'set'), out);
     verifyEqual(testCase,  ipaste(canvas, im, [3 2], 'mean'), out/2);
     canvas = ipaste(canvas, im, [3 2], 'add');
     canvas = ipaste(canvas, im, [3 2], 'add');
     verifyEqual(testCase, canvas, 2*out);
end

function pixswitch_test(testCase)
    a = [1 2; 3 4];
    b = [5 6; 7 8];

    verifyEqual(testCase, ipixswitch(logical(zeros(2,2)), a, b), b);
    verifyEqual(testCase, ipixswitch(logical(ones(2,2)), a, b), a);
    verifyEqual(testCase, ipixswitch(logical([0 1; 1 0]), a, b), [5 2; 3 8] );

    a = rand(2,2,3);
    b = rand(2,2,3);
    out = ipixswitch(logical([0 1; 0 0]), a, b);
    verifyEqual(testCase, out(1,1,:), b(1,1,:));
    verifyEqual(testCase, out(1,2,:), a(1,1,:));
end

function decimate_test(testCase)
    a = [1 2; 3 4];

    b = ireplicate(a);
    verifyEqual(testCase, a, b);

    b = ireplicate(a, 2);
    verifyEqual(testCase, b, [1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4]);

    verifyEqual(testCase,  idecimate(b, []), a);
end

function roi_test(testCase)
    a = [
        1  2  3  4
        5  6  7  8
        9 10 11 12
        ];

    out = iroi(a, [2 4; 2 3]);
    verifyEqual(testCase,  out, [6 7 8; 10 11 12]);
    [out,r] = iroi(a, [2 4; 2 3]);
    asertEqual(r, [2 4; 2 3]);
end

function iscolor_test(testCase)
    verifyFalse(testCase,  iscolor(rand(3,3)) );
    verifyTrue(testCase,  iscolor(rand(3,3,3)) );
    verifyTrue(testCase,  iscolor(rand(3,3,3,4)) );
end

function isize_test(testCase)
    im = rand(5,6,3,4);
    verifyEqual(testCase, isize(im,1), 5);
    verifyEqual(testCase, isize(im,2), 6);
    verifyEqual(testCase, isize(im,3), 3);
    verifyEqual(testCase, isize(im,4), 4);
    [w,h] = isize(im);
    verifyEqual(testCase, w, 6);
    verifyEqual(testCase, h, 5);
    [w,h,p] = isize(im);
    verifyEqual(testCase, w, 6);
    verifyEqual(testCase, h, 5);
    verifyEqual(testCase, p, 3);
end

function istretch_test(testCase)
    im = [0.1 0.35; 0.35 0.6];
    assertAlmostEqual(istretch(im), [0 2; 2 4]/4, 'absTol', 1e-6);

    assertAlmostEqual(istretch(im, 4), [0 2; 2 4], 'absTol', 1e-6);
end

function kernel_test(testCase)
    out = [
     0     1     0
     1     1     1
     0     1     0
    ];
    verifyEqual(testCase,  kcircle(1), out);

    out = [
     0     0     1     0     0
     0     1     1     1     0
     1     1     1     1     1
     0     1     1     1     0
     0     0     1     0     0
    ];
    verifyEqual(testCase,  kcircle(2), out);

    out = [
     0     1     0
     0     1     0
     1     1     1
    ];
    verifyEqual(testCase,  ktriangle(3), out);

    out = [
     0     0     1     0     0
     0     0     1     0     0
     0     1     1     1     0
     0     1     1     1     0
     1     1     1     1     1
    ];
    verifyEqual(testCase,  ktriangle(4), out);

    out = [
    -1     0     1
    -2     0     2
    -1     0     1
    ];
    verifyEqual(testCase,  ksobel, out);

    out = [
    0 1 0
    1 -4 1
    0 1 0
    ];
    verifyEqual(testCase,  klaplace, out);

    g = kgauss(2);
    verifyEqual(testCase, size(g), [13 13]);
    verifyTrue(testCase, g(7,7) >= max(g(:)));

    g = kgauss(2, 11);
    verifyEqual(testCase, size(g), [23 23]);
    assertAlmostEqual(sum(g(:)), 1, 'absTol', 1e-6);

    % test they run
    k = klog(1);
    k = kdgauss(1);
    k = kdog(1);
    k = kdog(2,1);
end

function kmeans_test(testCase)
    x = [];
    for i=1:5
        x = [x bsxfun(@plus, randn(3,10), randi(50, [3 1]))];
    end

    [L,C] = kmeans(x, 5);
    verifyEqual(testCase,  numcols(L), numcols(x));
    verifyEqual(testCase,  numcols(C), 5);
    verifyEqual(testCase,  numrows(C), numrows(x));
    [L,C] = kmeans(x, 5, 'spread');
    [L,C] = kmeans(x, 5, 'random');

    L = kmeans(x, C);
end

function mkgrid_test(testCase)
    out = [
   -1.5000   -1.5000    1.5000    1.5000
   -1.5000    1.5000    1.5000   -1.5000
         0         0         0         0
    ];
    assertAlmostEqual(mkgrid(2, 3), out, 'absTol', 1e-6);
    out = [
   -1.5000   -1.5000    1.5000    1.5000
   -1.5000    1.5000    1.5000   -1.5000
         5         5         5         5
    ];
    assertAlmostEqual(mkgrid(2, 3, 'T', transl(0,0,5)), out, 'absTol', 1e-6);
end

function mkcube_test(testCase)
    out = [
    -1    -1     1     1    -1    -1     1     1
    -1     1     1    -1    -1     1     1    -1
    -1    -1    -1    -1     1     1     1     1
    ];
    verifyEqual(testCase, mkcube(2), out);
 out = [
-1 -1 1 1 -1 -1 1 1 1 -1 0 0 0 0
 -1 1 1 -1 -1 1 1 -1 0 0 1 -1 0 0
 -1 -1 -1 -1 1 1 1 1 0 0 0 0 1 -1
];
    verifyEqual(testCase, mkcube(2, 'facepoint'), out);

out = [
     0     0     2     2     0     0     2     2
     1     3     3     1     1     3     3     1
     2     2     2     2     4     4     4     4
];
    verifyEqual(testCase, mkcube(2, 'centre', [1 2 3]), out);
    verifyEqual(testCase, mkcube(2, 'T', transl([1 2 3])), out);

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
    verifyEqual(testCase, x, xx);
    verifyEqual(testCase, y, yy);
    verifyEqual(testCase, z, zz);
end

function moment_test(testCase)
    im = [
        0 0 0 0
        0 0 0 0
        0 1 1 0
        0 1 1 0
        0 1 1 0
        0 0 0 0
    ];
    verifyEqual(testCase, mpq(im, 0, 0), 6);
    verifyEqual(testCase, mpq(im, 1, 0), 15);
    verifyEqual(testCase, mpq(im, 0, 1), 24);
    verifyEqual(testCase, mpq(im, 1, 1), 60);
    verifyEqual(testCase, mpq(im, 2, 0), 39);
    verifyEqual(testCase, mpq(im, 0, 2), 100);

    verifyEqual(testCase, upq(im, 0, 0), 6);
    verifyEqual(testCase, upq(im, 1, 0), 0);
    verifyEqual(testCase, upq(im, 0, 1), 0);
    verifyEqual(testCase, upq(im, 1, 1), 0);
    verifyEqual(testCase, upq(im, 2, 0), 1.5);
    verifyEqual(testCase, upq(im, 0, 2), 4);

    verifyEqual(testCase, npq(im, 2, 0), 1/24);
    verifyEqual(testCase, npq(im, 0, 2), 1/9);

    p = [
        2 4 4 2
        3 3 6 6
        ];
    verifyEqual(testCase, mpq_poly(p, 0, 0), 6);
    verifyEqual(testCase, mpq_poly(p, 1, 0), 18);
    verifyEqual(testCase, mpq_poly(p, 0, 1), 27);
    verifyEqual(testCase, mpq_poly(p, 1, 1), 81);
    verifyEqual(testCase, mpq_poly(p, 2, 0), 56);
    verifyEqual(testCase, mpq_poly(p, 0, 2), 126);

    verifyEqual(testCase, upq_poly(p, 0, 0), 6);
    verifyEqual(testCase, upq_poly(p, 1, 0), 0);
    verifyEqual(testCase, upq_poly(p, 0, 1), 0);
    verifyEqual(testCase, upq_poly(p, 1, 1), 0);
    verifyEqual(testCase, upq_poly(p, 2, 0), 2);
    verifyEqual(testCase, upq_poly(p, 0, 2), 4.5);

    verifyEqual(testCase, npq_poly(p, 2, 0), 1/18);
    verifyEqual(testCase, npq_poly(p, 0, 2), 1/8);
end

function testpattern_test(testCase)
    im = testpattern('rampx', 10, 2);
    verifyEqual(testCase, size(im), [10 10]);
    im = testpattern('rampx', [20 10], 2);
    verifyEqual(testCase, size(im), [10 20]);

    verifyEqual(testCase, im(6,:), [linspace(0, 1, 6) linspace(0, 1, 6)]);
    verifyEqual(testCase, im(:,2), ones(12,1)*0.2 );

    im = testpattern('rampy', 10, 2)';
    verifyEqual(testCase, im(6,:), [linspace(0, 1, 6) linspace(0, 1, 6)]);
    verifyEqual(testCase, im(:,2), ones(12,1)*0.2 );

    im = testpattern('sinx', 12, 1);
    assertAlmostEqual(sum(im), 0, 'absTol', 1e-6);
    assertAlmostEqual(diff(im(:,3)), zeros(12,1), 'absTol', 1e-6);
    im = testpattern('siny', 12, 1)';
    assertAlmostEqual(sum(im), 0, 'absTol', 1e-6);
    assertAlmostEqual(diff(im(:,3)), zeros(12,1), 'absTol', 1e-6);

    im = testpattern('dots', 100, 20, 10);
    [l,ml,p,c] = ilabel(im);
    verifyEqual(testCase, sum(c), 25);

    im = testpattern('squares', 100, 20, 10);
    [l,ml,p,c] = ilabel(im);
    verifyEqual(testCase, sum(c), 25);

    im = testpattern('line', 20, pi/6, 10);
    verifyEqual(testCase, im(11,2), 1);
    verifyEqual(testCase, im(29,17), 1);
    verifyEqual(testCase, sum(im(:)), 18);
end

function similarity_test(testCase)
    a = rand(3,3);

    verifyTrue(testCase,  abs( sad(a,a) ) < eps);
    verifyFalse(testCase,  abs( sad(a,a+0.1) ) < eps);

    verifyTrue(testCase,  abs( zsad(a,a) ) < eps);
    verifyTrue(testCase,  abs( zsad(a,a+0.1) ) < eps);

    verifyTrue(testCase,  abs( ssd(a,a) ) < eps);
    verifyFalse(testCase,  abs( ssd(a,a+0.1) ) < eps);

    verifyTrue(testCase,  abs( zssd(a,a) ) < eps);
    verifyTrue(testCase,  abs( zssd(a,a+0.1) ) < eps);

    verifyTrue(testCase,  abs( 1-ncc(a,a) ) < eps);
    verifyTrue(testCase,  abs( 1-ncc(a,a*2) ) < eps);

    verifyTrue(testCase,  abs( 1-zncc(a,a) ) < eps);
    verifyTrue(testCase,  abs( 1-zncc(a,a+0.1) ) < eps);
    verifyTrue(testCase,  abs( 1-zncc(a,a*2) ) < eps);

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
    verifyEqual(testCase, xm, [0 0 1]);
    [xm,s] = imatch(im, im, 5, 4, 1, 2);
    verifyEqual(testCase, size(s), [5 5]);
    %% BUG ?? verifyEqual(testCase, s(

    s = isimilarity(template, im);
    verifyEqual(testCase, size(s), size(im));
    verifyEqual(testCase, s(4,5), 1);
end


function zcross_test(testCase)
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
    verifyEqual(testCase, zcross(a), out);
end

function hu_test(testCase)
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
    assertAlmostEqual(im, out, 'absTol', 1e-8);
    
end

function ilut_test(testCase)
    im = cast([1 3; 2 4], 'uint8');
    lut = [10 11 12 13 14]';

    verifyEqual(testCase, ilut(im, lut), [11 13; 12 14]);

    lut = [
        10 11
        12 13
        14 15
        16 17
        18 19];
    out = cat(3, [12 16;14 18], [13 17; 15 19]);

    verifyEqual(testCase, ilut(im, lut), out);
end
