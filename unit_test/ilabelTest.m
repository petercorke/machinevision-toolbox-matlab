function tests = iLabelTest
    tests = functiontests(localfunctions);
    
    clc
end

function pattern1_test(tc)
    
    p = [
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 1 1 1 0 0 0 0
        0 0 0 1 1 1 0 0 0 0
        0 0 0 1 1 1 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        ];
    
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 2, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 1], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end


function pattern2_test(tc)
    % 2 blobs: 1 solid, 1 with hole
    p = [
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 1 1 1 0 0 1 1 1 0
        0 1 0 1 0 0 1 1 1 0
        0 1 1 1 0 0 1 1 1 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        ];
    
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 4, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 1 1 2], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end

function pattern3_test(tc)
    p = [
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 1 1 1 0 0 1 1 1 0
        0 1 1 1 0 0 1 0 1 0
        0 1 1 1 0 0 1 1 1 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        ];
    
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 4, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 1 1 3], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end



function pattern4_test(tc)
    p = [
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 1 1 1 0 0 1 1 1 0
        0 1 1 1 0 0 1 1 1 0
        0 1 1 1 0 0 1 1 1 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        ];
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 3, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 1 1], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end

function pattern5_test(tc)
    
    % 1 blob: U-shaped
    p = [
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 1 0 0 0 1 0 0 0
        0 0 1 0 0 0 1 0 0 0
        0 0 1 0 0 0 1 0 0 0
        0 0 1 1 1 1 1 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        ];
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 2, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 1], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end

function pattern6_test(tc)
    % 1 blob: sky hooks
    p = [
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 1 1 1 1 1 1 1 0
        0 0 0 1 0 0 0 1 0 0
        0 0 0 1 0 0 0 1 0 0
        0 1 0 1 0 1 0 1 0 0
        0 1 0 1 0 1 0 1 0 0
        0 1 1 1 0 1 1 1 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        ];
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 2, 'number of blobs');
    
    LL = p;
    LL(LL==0) = 2;
    tc.verifyEqual(L, LL);
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [2 0], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end

function pattern7_test(tc)
    
    
    % 1 blob: X-shaped, 8-way connected
    p = [
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 1 0 0 0 0 1 0 0 0
        0 0 1 0 0 1 0 0 0 0
        0 0 0 1 1 0 0 0 0 0
        0 0 0 1 1 0 0 0 0 0
        0 0 1 0 0 1 0 0 0 0
        0 1 0 0 0 0 1 0 0 0
        0 0 0 0 0 0 0 1 0 0
        0 0 0 0 0 0 0 0 0 0
        ];
    [L,M,P,C,E] = ilabel(p, 8);
    
    tc.verifyEqual(M, 2, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 1], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end

function pattern8_test(tc)
    
    % 5 blobs: 4 touch the edge
    p = [
        0 0 0 1 1 1 0 0 0 0
        0 0 0 1 1 1 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        1 1 0 1 1 1 0 0 1 1
        1 1 0 1 1 1 0 0 1 1
        1 1 0 1 1 1 0 0 1 1
        0 0 0 0 0 0 0 0 0 0
        0 0 0 1 1 1 0 0 0 0
        0 0 0 1 1 1 0 0 0 0
        ];
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 6, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 0 0 3 0 0], 'blob parent'); % label.m
    %tc.verifyEqual(double(P(:))', [0 0 0 2 0 0], 'blob parent'); % ilabel.mex
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end

function pattern9_test(tc)
    
    p = [
        1 1 1 0 0 0 0 0 0 0
        1 1 1 0 0 0 0 0 0 0
        1 1 1 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        ];
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 2, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 0], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end

function pattern10_test(tc)
    
    p = [
        1 1 1 1 1 1 1 1 1 1
        1 0 0 0 0 0 0 0 0 1
        1 0 0 0 0 0 0 0 0 1
        1 0 0 0 0 0 0 0 0 1
        1 0 0 0 0 0 0 0 0 1
        1 0 0 0 0 0 0 0 0 1
        1 1 1 1 1 1 1 1 1 1
        ];
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 2, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 1], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end

function pattern11_test(tc)
    
    p = [
        1 1 1 1 1 1 1 1 1 1
        1 0 0 0 0 0 0 0 0 1
        1 0 0 1 1 1 0 0 0 1
        1 0 0 1 1 1 0 0 0 1
        1 0 0 1 1 1 0 0 0 1
        1 0 0 0 0 0 0 0 0 1
        1 1 1 1 1 1 1 1 1 1
        ];
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 3, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 1 2], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end

function pattern12_test(tc)
    
    p = [
        1 1 1 1 1 1 1 1 1 1
        1 0 0 0 0 0 0 0 0 1
        1 0 1 1 0 0 1 1 0 1
        1 0 1 1 0 0 1 1 0 1
        1 0 1 1 0 0 1 1 0 1
        1 0 0 0 0 0 0 0 0 1
        1 1 1 1 1 1 1 1 1 1
        ];
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 4, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 1 2 2], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end

function pattern13_test(tc)
    
    p = [
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        1 1 1 1 1 1 1 1 1 1
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0
        ];
    [L,M,P,C,E] = ilabel(p);
    
    tc.verifyEqual(M, 3, 'number of blobs');
    
    for i=1:M
        tc.verifyTrue(all(p(L==i)==C(i)), 'blob pixel class');
    end
    
    tc.verifyEqual(double(P(:))', [0 0 0], 'blob parent');
    k = find(E > 0);
    tc.verifyEqual(p(E(k)), double(C(k)), 'blob edge pixel coordinate');
end

