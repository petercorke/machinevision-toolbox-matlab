function tests = MorphTest(testCase)
    tests = functiontests(localfunctions);
end

function imorph1_test(testCase)
    in = [1 2; 3 4];
    se = 1;
    verifyEqual(testCase,  imorph(in, se, 'min'), in);
    verifyEqual(testCase,  imorph(in, se, 'max'), in);
    verifyEqual(testCase,  imorph(in, se, 'min', 'replicate'), in);
    verifyEqual(testCase,  imorph(in, se, 'min', 'valid'), in);
    verifyEqual(testCase,  imorph(in, se, 'min', 'valid'), in);
    
    % test different input formats
    verifyEqual(testCase,  imorph(cast(in, 'uint8'), se, 'min'), in);
    verifyEqual(testCase,  imorph(cast(in, 'uint16'), se, 'min'), in);    
    verifyEqual(testCase,  imorph(cast(in, 'single'), se, 'min'), in);
    in2 = [1 0 1; 0 1 0; 1 1 0];
    verifyEqual(testCase,  imorph(logical(in2), se, 'min'), in2);    

    % test a SE that falls over the boundary  
    se = [0 0 0; 0 1 0; 0 0 0];
    verifyEqual(testCase,  imorph(in, se, 'min', 'replicate'), in);
    
    in = [
        1 2 3
        4 5 6
        7 8 9
        ];
    verifyEqual(testCase,  imorph(in, se, 'min', 'valid'), in(2,2));

    % border none trim wrap
end

function imorph2_test(testCase)
    % test wrap case
    in = [
        1 2 3
        4 5 6
        7 8 9
        ];
    verifyEqual(testCase,  imorph(in, [0 0 1], 'min', 'wrap'),  circshift(in, [ 0 -1]));
    verifyEqual(testCase,  imorph(in, [1 0 0], 'min', 'wrap'),  circshift(in, [ 0  1]));
    verifyEqual(testCase,  imorph(in, [0 0 1]', 'min', 'wrap'), circshift(in, [-1  0]));
    verifyEqual(testCase,  imorph(in, [1 0 0]', 'min', 'wrap'), circshift(in, [ 1  0]));

end

function imorph3_test(testCase)
    % test simple erosion (double)
    in = [
        1 2 3
        4 5 6
        7 8 9
        ];

    verifyEqual(testCase, imorph(in, ones(3,3), 'max', 'valid'), 9);

    out = [
        9 9 9
        9 9 9
        9 9 9
        ];
    verifyEqual(testCase, imorph(in, ones(3,3), 'max', 'wrap'), out);

    out = [
        1 1 1
        1 1 1
        1 1 1
        ];
    verifyEqual(testCase, imorph(in, ones(3,3), 'min', 'wrap'), out);

    out = [
        1 1 2
        1 1 2
        4 4 5
        ];
    verifyEqual(testCase, imorph(in, ones(3,3), 'min', 'replicate'), out);

    out = [
        5 6 6
        8 9 9
        8 9 9
        ];
    verifyEqual(testCase, imorph(in, ones(3,3), 'max', 'none'), out);


    % test simple erosion (int)
    in = cast([
        1 1 0
        1 1 0
        0 0 0
        ], 'uint8');

    out = [
        1 0 0
        0 0 0
        0 0 0
        ];

    verifyEqual(testCase, imorph(in, ones(3,3), 'min'), out);
end

function ierode_test(testCase)
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

    verifyEqual(testCase, ierode(in, ones(3,3)), out);

    out = [
        0 0 0 0 0 0
        0 0 0 0 0 0
        0 0 0 0 0 0
        0 0 0 0 0 0
        0 0 0 0 0 0
        ];
    verifyEqual(testCase, ierode(in, ones(3,3), 2), out);

    out = [
        0 0 0 0
        0 0 1 0
        0 0 0 0
        ];
    verifyEqual(testCase, ierode(in, ones(3,3), 'valid'), out);

    in = [
        1 1 1 0
        1 1 1 0
        0 0 0 0
        ];
    out = [
        1 1 0 0
        0 0 0 0
        0 0 0 0
        ];
    verifyEqual(testCase, ierode(in, ones(3,3), 'replicate'), out);

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
        0 0 0 0
        ];
    verifyEqual(testCase, ierode(in, ones(3,3), 'wrap'), out);
end

function idilate_test(testCase)
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

    verifyEqual(testCase, idilate(in, ones(3,3)), out);

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

    verifyEqual(testCase, idilate(in, ones(3,3), 2), out);
end

function iwindow_test(testCase)
    in = [
        3     5     8    10     9
        7    10     3     6     3
        7     4     6     2     9
        2     6     7     2     3
        2     3     9     3    10
    ];
    se = 1;
    % test different input formats
    verifyEqual(testCase,  iwindow(in, se, 'sum'), in);
    verifyEqual(testCase,  iwindow(cast(in, 'uint8'), se, 'sum'), in);
    verifyEqual(testCase,  iwindow(cast(in, 'uint16'), se, 'sum'), in);

    se = [1 1 1; 1 0 1; 1 1 1];
    out = iwindow(in, se, 'sum');
    out2 = [
        43    47    57    56    59
        46    43    51    50    57
        45    48    40    39    31
        33    40    35    49    48
        22    40    36    53    44
    ];

    verifyEqual(testCase, out, out2);

    %out = iwindow(im, se, 
    % se = ones(3,3), compare to conv2
    % 1 1 1; 1 0 1; 1 1 1  conv2() - original

end

function ivar_test(testCase)
    in = [
        0.7577    0.7060    0.8235    0.4387    0.4898
        0.7431    0.0318    0.6948    0.3816    0.4456
        0.3922    0.2769    0.3171    0.7655    0.6463
        0.6555    0.0462    0.9502    0.7952    0.7094
        0.1712    0.0971    0.0344    0.1869    0.7547
    ];
    out = [
        0.0564    0.0598    0.0675    0.0301    0.0014
        0.0720    0.0773    0.0719    0.0326    0.0163
        0.0787    0.1034    0.1143    0.0441    0.0233
        0.0508    0.0931    0.1261    0.0988    0.0345
        0.0552    0.1060    0.1216    0.1365    0.0618
    ];

    verifyEqual(testCase,  ivar(in, ones(3,3), 'var'), out, 'AbsTol', 1e-4);
    verifyEqual(testCase,  iwindow(in, ones(3,3), 'std').^2, out, 'AbsTol', 1e-4);
end

function irank_test(testCase)
    in = [
        1 2 3
        4 5 6
        7 8 9];

    se = 1;
    % test different input formats
    verifyEqual(testCase,  iwindow(in, se, 'sum'), in);
    verifyEqual(testCase,  iwindow(cast(in, 'uint8'), se, 'sum'), in);
    verifyEqual(testCase,  iwindow(cast(in, 'uint16'), se, 'sum'), in);
end

function thin_test(testCase)
    in = [
        0 0 0 0 0 1 1 1
        0 0 0 0 1 1 1 0
        1 1 1 1 1 1 0 0
        1 1 1 1 1 0 0 0
        1 1 1 1 0 1 0 0
        0 0 0 0 0 0 1 0
    ];
    out = [
        0 0 0 0 0 1 0 0
        0 0 0 0 0 1 0 0
        0 0 0 0 1 0 0 0
        1 1 1 1 1 0 0 0
        0 0 0 0 0 1 0 0
        0 0 0 0 0 0 1 0
    ];
    verifyEqual(testCase,  ithin(in), out);
end

function triplepoint_test(testCase)
    in = [
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
    verifyEqual(testCase,  itriplepoint(in), logical(out));
end

function endpoint_test(testCase)
    in = [
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        1 1 1 1 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
    ];
    out = [
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 1 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
    ];
    verifyEqual(testCase,  iendpoint(in), logical(out));
end
