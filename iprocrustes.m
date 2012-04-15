function T = iprocrustes(p1, p2)

    % corresponding point sets p1, p2

    p1m = mean(p1');
    p2m = mean(p2');
    p2m-p1m

    p1 = bsxfun(@minus, p1, p1m');
    p2 = bsxfun(@minus, p2, p2m');

    s1 = mean(colnorm(p1));
    s2 = mean(colnorm(p2));
    s2/s1

    p1 = p1/s1;
    p2 = p2/s2;

    M = zeros(2,2);
    for i=1:numcols(p1)
        M = M + p1(:,i)*p2(:,i)';
    end
    [U,S,V] = svd(M);
    % from Kanatani p.109
    R = V*diag([1 1 det(V*U')])*U';
    R
