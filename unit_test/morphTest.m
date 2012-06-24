function MorphTest
  initTestSuite;
end

function imorph_test
    % test simple erosion (double)
    in = [
        1 2 3
        4 5 6
        7 8 9
        ];

    assertEqual(imorph(in, ones(3,3), 'max', 'valid'), 9);
    assertEqual(imorph(in, ones(3,3), 'max', 'same'), 9);

    out = [
        9 9 9
        9 9 9
        9 9 9
        ];
    assertEqual(imorph(in, ones(3,3), 'max', 'wrap'), out);

    out = [
        1 1 2
        1 1 2
        4 4 5
        ];
    assertEqual(imorph(in, ones(3,3), 'min', 'replicate'), out);

    assertEqual(imorph(in, ones(3,3), 'max', 'none'), out);
    assertEqual(imorph(in, ones(3,3), 'max', 'pad0'), out);
    assertEqual(imorph(in, ones(3,3), 'max', 'pad1'), out);


    % test simple erosion (int)
    in = cast([
        1 1 0
        1 1 0
        0 0 0
        ], 'uint8');

    out = cast([
        1 0 0
        0 0 0
        0 0 0
        ], 'uint8');

    assertEqual(imorph(in, ones(3,3)), out);
    assertEqual(imorph(in, ones(3,3), 'same'), out);
    assertEqual(imorph(in, ones(3,3), 'wrap'), out);
    assertEqual(imorph(in, ones(3,3), 'replicate'), out);
    assertEqual(imorph(in, ones(3,3), 'none'), out);
    assertEqual(imorph(in, ones(3,3), 'pad0'), out);
    assertEqual(imorph(in, ones(3,3), 'pad1'), out);
end

function ierode_test
    in = [
        1 0 0 0 0 0
        0 0 1 1 1 0
        0 0 1 1 1 0
        0 0 1 1 1 0
        0 0 0 0 0 0
        ];
    out = [
        0 0 0 0 0 0
        0 0 0 0 0 0
        0 0 0 1 0 0
        0 0 0 0 0 0
        0 0 0 0 0 0
        ];

    assertEqual(ierode(in, ones(3,3)), out);
    assertEqual(ierode(in, ones(3,3), 'same'), out);
    assertEqual(ierode(in, ones(3,3), 'wrap'), out);
    assertEqual(ierode(in, ones(3,3), 'replicate'), out);
    assertEqual(ierode(in, ones(3,3), 'none'), out);
    assertEqual(ierode(in, ones(3,3), 'pad0'), out);
    assertEqual(ierode(in, ones(3,3), 'pad1'), out);

    out = [
        0 0 0 0 0 0
        0 0 0 0 0 0
        0 0 0 0 0 0
        0 0 0 0 0 0
        0 0 0 0 0 0
        ];
    assertEqual(ierode(in, ones(3,3), 2), out);
    assertEqual(ierode(in, ones(3,3), 2, 'same'), out);
    assertEqual(ierode(in, ones(3,3), 2, 'wrap'), out);
    assertEqual(ierode(in, ones(3,3), 2, 'replicate'), out);
    assertEqual(ierode(in, ones(3,3), 2, 'none'), out);
    assertEqual(ierode(in, ones(3,3), 2, 'pad0'), out);
    assertEqual(ierode(in, ones(3,3), 2, 'pad1'), out);
    out = [
        0 0 0 0
        0 0 1 0
        0 0 0 0
        ];
    assertEqual(ierode(in, ones(3,3), 'valid'), out);
    in = [
        1 1 1 0
        1 1 1 0
        0 0 0 0
        ];
    out = [
        0 1 0 0
        0 0 0 0
        0 0 0 0
        ];
    assertEqual(ierode(in, ones(3,3), 'replicate'), out);
    assertEqual(ierode(in, ones(3,3), 'pad1'), out);
    in = [
        1 1 0 1
        1 1 0 1
        0 0 0 0
        1 1 0 1
        ];
    out = [
        1 0 0 0
        0 0 0 0
        0 0 0 0
        ];
    assertEqual(ierode(in, ones(3,3), 'wrap'), out);
end

function idilate_test
    in = [
        0 0 0 0 0 0 0
        0 0 0 0 0 0 0
        0 0 0 0 0 0 0
        0 0 0 1 0 0 0
        0 0 0 0 0 0 0
        0 0 0 0 0 0 0
        0 0 0 0 0 0 0
        0 0 0 0 0 0 0
        ];
    out = [
        0 0 0 0 0 0 0
        0 0 0 0 0 0 0
        0 0 1 1 1 0 0
        0 0 1 1 1 0 0
        0 0 1 1 1 0 0
        0 0 0 0 0 0 0
        0 0 0 0 0 0 0
        0 0 0 0 0 0 0
        ];

    assertEqual(idilate(in, ones(3,3)), out);
    assertEqual(idilate(in, ones(3,3), 'same'), out);
    assertEqual(idilate(in, ones(3,3), 'wrap'), out);
    assertEqual(idilate(in, ones(3,3), 'replicate'), out);
    assertEqual(idilate(in, ones(3,3), 'none'), out);
    assertEqual(idilate(in, ones(3,3), 'pad0'), out);
    assertEqual(idilate(in, ones(3,3), 'pad1'), out);
    out = [
        0 0 0 0 0 0 0
        0 1 1 1 1 1 0
        0 1 1 1 1 1 0
        0 1 1 1 1 1 0
        0 1 1 1 1 1 0
        0 1 1 1 1 1 0
        0 0 0 0 0 0 0
        0 0 0 0 0 0 0
        ];

    assertEqual(idilate(in, ones(3,3), 2), out);
    assertEqual(idilate(in, ones(3,3), 2, 'same'), out);
    assertEqual(idilate(in, ones(3,3), 2, 'wrap'), out);
    assertEqual(idilate(in, ones(3,3), 2, 'replicate'), out);
    assertEqual(idilate(in, ones(3,3), 2, 'none'), out);
    assertEqual(idilate(in, ones(3,3), 2, 'pad0'), out);
    assertEqual(idilate(in, ones(3,3), 2, 'pad1'), out);
end

function thin_test
    im = [
        0 0 0 0 0 1 1 1
        0 0 0 0 1 1 1 0
        1 1 1 1 1 1 0 0
        1 1 1 1 1 0 0 0
        1 1 1 1 0 1 0 0
        0 0 0 0 0 0 1 0
    ];
    out = [
        0 0 0 0 0 1 0 0
        0 0 0 0 1 0 0 0
        0 0 0 1 0 0 0 0
        1 1 1 1 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
    ];
    assertEqual( ithin(im), out);
end

function triplepoint_test
    im = [
        0 0 0 0 0 1 0 0
        0 0 0 0 1 0 0 0
        1 1 1 1 0 0 0 0
        0 0 0 0 1 0 0 0
        0 0 0 0 0 1 0 0
        0 0 0 0 0 0 1 0
    ];
    out = [
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 1 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
    ];
    assertEqual( itriplepoint(im), out);
end
