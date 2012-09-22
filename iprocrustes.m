%IPROCRUSTES Point cloud alignment
%
% T = IPROCRUSTES(P1, P2) is the transform that best transforms point set
% P1 (3xN) to P2 (3xN).  Point correspondence is assumed to be known, that is,
% the Ith column of P1 corresponds to the Ith column of P2.
%
% [T,S] = IPROCRUSTES(P1, P2) as above but also returns the overall scale
% change from P1 to P2.
%
% Example::
%  Create a random point cloud and transform it
%         p1 = rand(3,10);
%         T = transl(1,2,3) * eul2tr(0.1, 0.2, 0.3);
%         p2 = homtrans(T, p1);
%         iprocrustes(p1, p2);
%
% See also ICP.

function T = iprocrustes(p1, p2)

    % corresponding point sets p1, p2

    % find the mean of the two point sets
    p1m = mean(p1');
    p2m = mean(p2');

    % subtract the mean, the points sets are now centred at the origin
    p1 = bsxfun(@minus, p1, p1m');
    p2 = bsxfun(@minus, p2, p2m');

    % find the mean distance from the origin
    s1 = mean(colnorm(p1));
    s2 = mean(colnorm(p2));

    % the overall scale is the ratio of the mean distances
    scale = s2/s1

    % normalize the scale, each set has unit mean distance
    p1 = p1/s1;
    p2 = p2/s2;

    % compute the moment matrix
    M = zeros(2,2);
    for i=1:numcols(p1)
        M = M + p1(:,i)*p2(:,i)';
    end

    % use SVD to determine rotation
    % from Kanatani p.109
    [U,S,V] = svd(M);
    R = V*diag([1 det(V*U')])*U';

    % build the homogeneous transform in SE(2)
    p2m-p1m
    det(R)
    (R) *(p2m-p1m)'
    T = [R R*(p2m-p1m)'; 0 0 1];
