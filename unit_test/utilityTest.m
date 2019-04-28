function tests = utilityTest(tc)
    tests = functiontests(localfunctions);
    clc
end

function idouble_test(tc)
    % test for uint8
    tc.verifyEqual( idouble( cast(0, 'uint8')), 0);
    tc.verifyEqual( idouble( cast(128, 'uint8')), 128/255);
    tc.verifyEqual( idouble( cast(255, 'uint8')), 1);

    % test for uint16
    tc.verifyEqual( idouble( cast(0, 'uint16')), 0);
    tc.verifyEqual( idouble( cast(128, 'uint16')), 128/65535);
    tc.verifyEqual( idouble( cast(65535, 'uint16')), 1);

    i = cast(randi(100, [5 5]), 'uint8');
    a = idouble(i);
    tc.verifyEqual(size(a), size(i));
    tc.verifyEqual(a, double(i)/255);

    i = cast(randi(100, [5 5]), 'uint16');
    a = idouble(i);
    tc.verifyEqual(a, double(i)/65535);
end

function iint_test(tc)
    % test for uint8
    tc.verifyEqual( iint(0),  cast(0, 'uint8'));
    tc.verifyEqual( iint(1),  cast(255, 'uint8'));

    % test for uint16
    tc.verifyEqual( iint(0, 'uint16'),  cast(0, 'uint16'));
    tc.verifyEqual( iint(1, 'uint16'),  cast(65535, 'uint16'));

    a = rand([5 5]);
    i = iint(a);
    tc.verifyEqual(size(a), size(i));

    a = rand([5 5 3]);
    i = iint(a);
    tc.verifyEqual(size(a), size(i));
end

function igamma_test(tc)
    a = 0.4;
    g = igamm(a, 0.5);
    tc.verifyEqual( g*g, a);

    a = 64;
    g = igamm(a, 0.5);
    tc.verifyEqual( g*g, a);

    igamm(a, 'sRGB');  % test this option parses

    a = rand(5,5);
    g = igamm(a, 0.5);
    tc.verifyEqual(size(a), size(g));
    tc.verifyEqual( igamm(g, 2), a, 'absTol', 1e-4);

    a = rand(5,5, 3);
    g = igamm(a, 0.5);
    tc.verifyEqual(size(a), size(g));
end

function im2col_test(tc)
    a = rand(5,5,3);

    c = im2col(a);

    tc.verifyEqual(c(1,:), squeeze(a(1,1,:))');
    tc.verifyEqual(c(25,:), squeeze(a(5,5,:))');

    tc.verifyEqual( col2im(c, a), a);
    tc.verifyEqual( col2im(c, size(a)), a);

    mask = zeros(5,5);
    mask(2,3) = 1;
    c = im2col(a, mask);
    tc.verifyEqual( c, squeeze(a(2,3,:))' );
    c = im2col(a, find(mask) );
    tc.verifyEqual( c, squeeze(a(2,3,:))' );

    i = find(mask > 0);
    c = im2col(a, i);
    tc.verifyEqual( c, squeeze(a(2,3,:))' );

end

function iisum_test(tc)
    a = [
        1 2 3 4
        4 5 6 7
        3 2 1 4
        ];
    out = intgimage(a);

    % test the integral image    
    tc.verifyEqual( out(1,1), sum(sum(a(1:1,1:1))) );
    tc.verifyEqual( out(1,2), sum(sum(a(1:1,1:2))) );
    tc.verifyEqual( out(2,1), sum(sum(a(1:2,1:1))) );
    tc.verifyEqual( out(2,2), sum(sum(a(1:2,1:2))) );
    tc.verifyEqual( out(3,4), sum(sum(a(1:3,1:4))) );
    
    % S = iisum(II, U1, V1, U2, V2)
    tc.verifyEqual( iisum(out, 2, 2, 2, 2), sum(sum(a(2:2,2:2))) );    % single
    tc.verifyEqual( iisum(out, 2, 2, 2, 3), sum(sum(a(2:3,2:2))) );    % col
    tc.verifyEqual( iisum(out, 2, 2, 3, 2), sum(sum(a(2:2,2:3))) );     % row
    tc.verifyEqual( iisum(out, 1, 1, 2, 3), sum(sum(a(1:3,1:2))) );    % block at origin
    tc.verifyEqual( iisum(out, 2, 3, 2, 3), sum(sum(a(3:3,2:2))) );     % single
end

function line_test(tc)

    a = zeros(3,3);
    out = iline(a, [1 1], [3 1]);
    tc.verifyEqual(out, [1 1 1; 0 0 0; 0 0 0]);
    out = iline(a, [1 1], [3 1], 5);
    tc.verifyEqual(out, [5 5 5; 0 0 0; 0 0 0]);

    a = zeros(3,3);
    out = iline(a, [2 1], [2 3]);
    tc.verifyEqual(out, [0 1 0; 0 1 0; 0 1 0]);

    a = zeros(3,3);
    out = iline(a, [1 1], [3 3]);
    tc.verifyEqual(out, [1 0 0; 0 1 0; 0 0 1]);

    tc.verifyEqual(iprofile(out, [1 1], [3 3]), [1 1 1]');

    % test for color image
    out = cat(3, out, 2*out, 3*out);
    tc.verifyEqual(squeeze(iprofile(out, [1 1], [3 3])), [1 2 3; 1 2 3; 1 2 3]);
end

function mesh_test(tc)
    im = rand(4,6);
    [u0,v0] = meshgrid(1:6, 1:4);

    [u,v] = imeshgrid(im);
    tc.verifyEqual(u, u0);
    tc.verifyEqual(v, v0);

    [u,v] = imeshgrid([1 1]);
    tc.verifyEqual(u, 1);
    tc.verifyEqual(v, 1);


    [u,v] = imeshgrid(2);
    tc.verifyEqual(u, [1 2; 1 2]);
    tc.verifyEqual(v, [1 1; 2 2]);

    [u,v] = imeshgrid([2 3]);
    tc.verifyEqual(u, [1 2; 1 2; 1 2]);
    tc.verifyEqual(v, [1 1; 2 2; 3 3]);

    [u,v] = imeshgrid([3 2]);
    tc.verifyEqual(u, [1 2 3; 1 2 3]);
    tc.verifyEqual(v, [1 1 1; 2 2 2]);

end

function mono_test(tc)

    im = rand(3,3,3);
    m = imono(im);
    tc.verifyEqual(size(m), [3 3]);
    verifyTrue(tc,  min(m(:)) >= 0);
    verifyTrue(tc,  max(m(:)) <= 1);

    m2 = imono(m);
    tc.verifyEqual(size(m), size(m2));

    im = randi(3,3,3, 'uint8');
    m = imono(im);
    tc.verifyEqual(size(m), [3 3]);
    verifyTrue(tc,  min(m(:)) >= 0);
    verifyTrue(tc,  max(m(:)) <= 255);
end

function icolor_test(tc)
    im = rand(3,3);

    out = cat(3, im, im, im);
    tc.verifyEqual(icolor(im), out); 

    out = cat(3, im, 0*im, im);
    tc.verifyEqual(icolor(im, [1 0 1]), out); 
end

function colorize_test(tc)
    im = [
        1 2 3
        1 2 3
        1 3 3
        ]/10;

    out = colorize(im, im>0.2, [0 0 1]);
    tc.verifyEqual( squeeze(out(1,1,:))', [1 1 1]/10);
    tc.verifyEqual( squeeze(out(1,3,:))', [0 0 1]);

    out = colorize(im, @(x) x>0.2, [0 0 1]);
    tc.verifyEqual( squeeze(out(1,1,:))', [1 1 1]/10);
    tc.verifyEqual( squeeze(out(1,3,:))', [0 0 1]);
end

function pad_test(tc)
    im = [1 2; 3 4];

    P = NaN;
    tc.verifyEqual(ipad(im, 't', 2), [P P; P P; 1 2; 3 4]);
    tc.verifyEqual(ipad(im, 'b', 2), [1 2; 3 4; P P; P P]);
    tc.verifyEqual(ipad(im, 'l', 2), [P P 1 2; P P 3 4]);
    tc.verifyEqual(ipad(im, 'r', 2), [1 2 P P; 3 4 P P]);
    tc.verifyEqual(ipad(im, 'bl', 2), [ P P 1 2; P P 3 4; P P P P; P P P P]);

    P = 17;
    tc.verifyEqual(ipad(im, 't', 2, P), [P P; P P; 1 2; 3 4]);
    tc.verifyEqual(ipad(im, 'b', 2, P), [1 2; 3 4; P P; P P]);
    tc.verifyEqual(ipad(im, 'l', 2, P), [P P 1 2; P P 3 4]);
    tc.verifyEqual(ipad(im, 'r', 2, P), [1 2 P P; 3 4 P P]);
    tc.verifyEqual(ipad(im, 'bl', 2, P), [ P P 1 2; P P 3 4; P P P P; P P P P]);
end

function paste_test(tc)
    im = [1 2 3; 4 5 6; 7 8 9];

    canvas = zeros(5,5);

    out = [
        0 0 0 0 0
        0 0 1 2 3
        0 0 4 5 6
        0 0 7 8 9
        0 0 0 0 0
        ];
     tc.verifyEqual( ipaste(canvas, im, [3 2]), out);
     tc.verifyEqual( ipaste(canvas, im, [4 3], 'centre'), out);
     tc.verifyEqual( ipaste(canvas, im, [2 1], 'zero'), out);
     tc.verifyEqual( ipaste(canvas, im, [3 2], 'set'), out);
     tc.verifyEqual( ipaste(canvas, im, [3 2], 'mean'), out/2);
     canvas = ipaste(canvas, im, [3 2], 'add');
     canvas = ipaste(canvas, im, [3 2], 'add');
     tc.verifyEqual(canvas, 2*out);
end

function pixswitch_test(tc)
    a = [1 2; 3 4];
    b = [5 6; 7 8];

    tc.verifyEqual(ipixswitch(logical(zeros(2,2)), a, b), b);
    tc.verifyEqual(ipixswitch(logical(ones(2,2)), a, b), a);
    tc.verifyEqual(ipixswitch(logical([0 1; 1 0]), a, b), [5 2; 3 8] );

    a = rand(2,2,3);
    b = rand(2,2,3);
    out = ipixswitch(logical([0 1; 0 0]), a, b);
    tc.verifyEqual(out(1,1,:), b(1,1,:));
    tc.verifyEqual(out(1,2,:), a(1,2,:));
    tc.verifyEqual(out(2,1,:), b(2,1,:));
    tc.verifyEqual(out(2,2,:), b(2,2,:));
end

function decimate_test(tc)
    a = [1 2; 3 4];

    b = ireplicate(a);
    tc.verifyEqual(a, b);

    b = ireplicate(a, 2);
    tc.verifyEqual(b, [1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4]);

    % decimate with no smoothing
    tc.verifyEqual( idecimate(b, 2, []), a);
end

function roi_test(tc)
    a = [
        1  2  3  4
        5  6  7  8
        9 10 11 12
        ];

    out = iroi(a, [2 4; 2 3]);
    tc.verifyEqual( out, [6 7 8; 10 11 12]);
    [out,r] = iroi(a, [2 4; 2 3]);
    tc.verifyEqual(r, [2 4; 2 3]);
end

function iscolor_test(tc)
    verifyFalse(tc, iscolor(rand(3,3)) );
    verifyTrue(tc,  iscolor(rand(3,3,3)) );
    verifyTrue(tc,  iscolor(rand(3,3,3,4)) );
end

function isize_test(tc)
    im = rand(5,6,3,4);
    tc.verifyEqual(isize(im,1), 5);
    tc.verifyEqual(isize(im,2), 6);
    tc.verifyEqual(isize(im,3), 3);
    tc.verifyEqual(isize(im,4), 4);
    [w,h] = isize(im);
    tc.verifyEqual(w, 6);
    tc.verifyEqual(h, 5);
    [w,h,p] = isize(im);
    tc.verifyEqual(w, 6);
    tc.verifyEqual(h, 5);
    tc.verifyEqual(p, 3);
end

function istretch_test(tc)
    im = [0.1 0.35; 0.35 0.6];
    tc.verifyEqual(istretch(im), [0 2; 2 4]/4, 'absTol', 1e-6);

    tc.verifyEqual(istretch(im, 'max', 4), [0 2; 2 4], 'absTol', 1e-6);
end

function kernel_test(tc)
    out = [
     0     1     0
     1     1     1
     0     1     0
    ];
    tc.verifyEqual( kcircle(1), out);

    out = [
     0     0     1     0     0
     0     1     1     1     0
     1     1     1     1     1
     0     1     1     1     0
     0     0     1     0     0
    ];
    tc.verifyEqual( kcircle(2), out);

    out = [
     0     1     0
     0     1     0
     1     1     1
    ];
    tc.verifyEqual( ktriangle(3), out);

    out = [
     0     0     1     0     0
     0     0     1     0     0
     0     1     1     1     0
     0     1     1     1     0
     1     1     1     1     1
    ];
    tc.verifyEqual( ktriangle(4), out);

    out = [
     1     0    -1
     2     0    -2
     1     0    -1
    ]/8;
    tc.verifyEqual( ksobel, out);

    out = [
    0 1 0
    1 -4 1
    0 1 0
    ];
    tc.verifyEqual( klaplace, out);

    g = kgauss(2);
    tc.verifyEqual(size(g), [13 13]);
    verifyTrue(tc, g(7,7) >= max(g(:)));

    g = kgauss(2, 11);
    tc.verifyEqual(size(g), [23 23]);
    tc.verifyEqual(sum(g(:)), 1, 'absTol', 1e-6);

    % test they run
    k = klog(1);
    k = kdgauss(1);
    k = kdog(1);
    k = kdog(2,1);
end

function kmeans_test(tc)
    x = [];
    for i=1:5
        x = [x bsxfun(@plus, randn(3,10), randi(50, [3 1]))];
    end

    [L,C] = kmeans(x, 5);
    tc.verifyEqual( numcols(L), numcols(x));
    tc.verifyEqual( numcols(C), 5);
    tc.verifyEqual( numrows(C), numrows(x));
    [L,C] = kmeans(x, 5, 'spread');
    [L,C] = kmeans(x, 5, 'random');

    L = kmeans(x, C);
end

function mkgrid_test(tc)
    out = [
   -1.5000   -1.5000    1.5000    1.5000
   -1.5000    1.5000    1.5000   -1.5000
         0         0         0         0
    ];
    tc.verifyEqual(mkgrid(2, 3), out, 'absTol', 1e-6);
    
    out = [
   -1.5000   -1.5000    1.5000    1.5000
   -1.5000    1.5000    1.5000   -1.5000
         5         5         5         5
    ];
    tc.verifyEqual(mkgrid(2, 3, 'pose', transl(0,0,5)), out, 'absTol', 1e-6);
end

function mkcube_test(tc)
    out = [
    -1    -1     1     1    -1    -1     1     1
    -1     1     1    -1    -1     1     1    -1
    -1    -1    -1    -1     1     1     1     1
    ];
    tc.verifyEqual(mkcube(2), out);
 out = [
-1 -1 1 1 -1 -1 1 1 1 -1 0 0 0 0
 -1 1 1 -1 -1 1 1 -1 0 0 1 -1 0 0
 -1 -1 -1 -1 1 1 1 1 0 0 0 0 1 -1
];
    tc.verifyEqual(mkcube(2, 'facepoint'), out);

out = [
     0     0     2     2     0     0     2     2
     1     3     3     1     1     3     3     1
     2     2     2     2     4     4     4     4
];
    tc.verifyEqual(mkcube(2, 'centre', [1 2 3]), out);
    tc.verifyEqual(mkcube(2, 'pose', transl([1 2 3])), out);

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
    tc.verifyEqual(x, xx);
    tc.verifyEqual(y, yy);
    tc.verifyEqual(z, zz);
end

function moment_test(tc)
    im = [
        0 0 0 0
        0 0 0 0
        0 1 1 0
        0 1 1 0
        0 1 1 0
        0 0 0 0
    ];
    tc.verifyEqual(mpq(im, 0, 0), 6);
    tc.verifyEqual(mpq(im, 1, 0), 15);
    tc.verifyEqual(mpq(im, 0, 1), 24);
    tc.verifyEqual(mpq(im, 1, 1), 60);
    tc.verifyEqual(mpq(im, 2, 0), 39);
    tc.verifyEqual(mpq(im, 0, 2), 100);

    tc.verifyEqual(upq(im, 0, 0), 6);
    tc.verifyEqual(upq(im, 1, 0), 0);
    tc.verifyEqual(upq(im, 0, 1), 0);
    tc.verifyEqual(upq(im, 1, 1), 0);
    tc.verifyEqual(upq(im, 2, 0), 1.5);
    tc.verifyEqual(upq(im, 0, 2), 4);

    tc.verifyEqual(npq(im, 2, 0), 1/24);
    tc.verifyEqual(npq(im, 0, 2), 1/9);

    p = [
        2 4 4 2
        3 3 6 6
        ];
    tc.verifyEqual(mpq_poly(p, 0, 0), 6);
    tc.verifyEqual(mpq_poly(p, 1, 0), 18);
    tc.verifyEqual(mpq_poly(p, 0, 1), 27);
    tc.verifyEqual(mpq_poly(p, 1, 1), 81);
    tc.verifyEqual(mpq_poly(p, 2, 0), 56);
    tc.verifyEqual(mpq_poly(p, 0, 2), 126);

    tc.verifyEqual(upq_poly(p, 0, 0), 6);
    tc.verifyEqual(upq_poly(p, 1, 0), 0);
    tc.verifyEqual(upq_poly(p, 0, 1), 0);
    tc.verifyEqual(upq_poly(p, 1, 1), 0);
    tc.verifyEqual(upq_poly(p, 2, 0), 2);
    tc.verifyEqual(upq_poly(p, 0, 2), 4.5);

    tc.verifyEqual(npq_poly(p, 2, 0), 1/18);
    tc.verifyEqual(npq_poly(p, 0, 2), 1/8);
end

function testpattern_test(tc)
    im = testpattern('rampx', 10, 2);
    tc.verifySize(im, [10 10]);
    
    im = testpattern('rampx', [20 10], 2);
    tc.verifySize(im, [10 20]);
    tc.verifyEqual(im(6,:), [linspace(0, 1, 10) linspace(0, 1, 10)]);
    tc.verifyEqual(im(:,10), ones(10,1) );

    im = testpattern('rampy', [10 20], 2);
    tc.verifySize(im, [20 10]);
    tc.verifyEqual(im(:,6), [linspace(0, 1, 10) linspace(0, 1, 10)]');
    tc.verifyEqual(im(10,:), ones(1,10) );

    im = testpattern('sinx', 12, 1);
    tc.verifySize(im, [12 12]);
    tc.verifyEqual(sum(sum(im')), 0, 'absTol', 1e-6);
    tc.verifyEqual(diff(im(:,3)), zeros(11,1), 'absTol', 1e-6);
    
    im = testpattern('siny', 12, 1)';
    tc.verifySize(im, [12 12]);
    tc.verifyEqual(sum(sum(im)), 0, 'absTol', 1e-6);
    tc.verifyEqual(diff(im(:,3)), zeros(11,1), 'absTol', 1e-6);

    im = testpattern('dots', 100, 20, 10);
    tc.verifySize(im, [100 100]);
    [l,ml,p,c] = ilabel(im);
    tc.verifyEqual(sum(c), 25);

    im = testpattern('squares', 100, 20, 10);
    tc.verifySize(im, [100 100]);
    [l,ml,p,c] = ilabel(im);
    tc.verifyEqual(sum(c), 25);

    im = testpattern('line', 20, pi/6, 10);
    tc.verifySize(im, [20 20]);
    tc.verifyEqual(im(11,2), 1);
    tc.verifyEqual(im(17,12), 1);
    tc.verifyEqual(sum(im(:)), 18);
end

function similarity_test(tc)
    a = [
            0.9280    0.3879    0.8679
            0.1695    0.3826    0.7415
            0.8837    0.2715    0.4479 ];

    verifyTrue(tc,  abs( sad(a,a) ) < 100*eps);
    verifyFalse(tc,  abs( sad(a,a+0.1) ) < 100*eps);

    verifyTrue(tc,  abs( zsad(a,a) ) < 100*eps);
    verifyTrue(tc,  abs( zsad(a,a+0.1) ) < 100*eps);

    verifyTrue(tc,  abs( ssd(a,a) ) < 100*eps);
    verifyFalse(tc,  abs( ssd(a,a+0.1) ) < 100*eps);

    verifyTrue(tc,  abs( zssd(a,a) ) < 100*eps);
    verifyTrue(tc,  abs( zssd(a,a+0.1) ) < 100*eps);

    verifyTrue(tc,  abs( 1-ncc(a,a) ) < 100*eps);
    verifyTrue(tc,  abs( 1-ncc(a,a*2) ) < 100*eps);

    verifyTrue(tc,  abs( 1-zncc(a,a) ) < 100*eps);
    verifyTrue(tc,  abs( 1-zncc(a,a+0.1) ) < 100*eps);
    verifyTrue(tc,  abs( 1-zncc(a,a*2) ) < 100*eps);

    im = [
          5    10     7     7     7    12    12    11   7
          5     4     7    12     2     7     5    11   7
          3     1     8    10     3     7     8    10   3
          2    11     3     7     4     2     7     9   1
         10     9    12     3     2     1    12     8   2
          1     9     7     4     5     6     7     9  12
          4    10    10     8     9     7    11     4   1
         11     4     3    12    10     7     1     6   6
          6     3     4     5     2     9     1    11   3
         11     8     1     2     7     1    11     4  12
          6     4     6     4    10     7     5     8   4
    ];
    % true match is at x=5, y=6
    template = [
        3 2 1
        4 5 6
        8 9 7
    ];
    xm = imatch(im, im, 4, 4, 1, 2);
    tc.verifyEqual(xm, [0 0 1], 'absTol', 1e-12);
    
    [xm,s] = imatch(im, im, 5, 4, 1, 2);
    tc.verifyEqual(size(s), [5 5]);
    tc.verifyEqual(s(3,3), 1, 'absTol', 1e-12);

    s = isimilarity(template, im);
    tc.verifyEqual(size(s), size(im));
    tc.verifyEqual(s(6,5), 1, 'absTol', 1e-12);
end

function zcross_test(tc)
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
    tc.verifyEqual(zcross(a), out);
end

function hu_test(tc)
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
        ]';
    tc.assertEqual(humoments(im), out, 'absTol', 1e-8);
    
end

function ilut_test(tc)
    im = cast([1 3; 2 4], 'uint8');
    lut = [10 11 12 13 14]';

    tc.verifyEqual(ilut(im, lut), [11 13; 12 14]);

    lut = [
        10 11
        12 13
        14 15
        16 17
        18 19];
    out = cat(3, [12 16;14 18], [13 17; 15 19]);

    tc.verifyEqual(ilut(im, lut), out);
end
