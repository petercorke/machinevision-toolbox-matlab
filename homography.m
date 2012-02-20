%HOMOGRAPHY Estimate homography
%
% H = HOMOGRAPHY(P1, P2) is the homography (3x3) that relates two
% sets of corresponding points P1 (2xN) and P2 (2xN) from two different
% camera views of a planar object.
%
% Notes::
% - The points must be corresponding, no outlier rejection is performed.
% - The points must be projections of points lying on a world plane
% - Contains a RANSAC driver, which means it can be passed to ransac().
%
% Author::
% Based on homography code by
% Peter Kovesi,
% School of Computer Science & Software Engineering,
% The University of Western Australia,
% http://www.csse.uwa.edu.au/,
%
% See also RANSAC, INVHOMOG, FMATRIX.

function [H,resid] = homography(X, p2, Ht)

    % RANSAC integration
    if isstruct(X)
        H = ransac_driver(X);
        return;
    end

    if numrows(X) == 6
        p1 = X(1:3,:);
        p2 = X(4:6,:);
    else
        if nargin < 2,
            error('must pass uv1 and uv2');
        end
        p1 = X;
        if numcols(p1) ~= numcols(p2),
            error('must have same number of points in each set');
        end
        if numrows(p1) ~= numrows(p2),
            error('p1 and p2 must have same number of rows')
        end
    end

    % linear estimation step
    H = vgg_H_from_x_lin(p1, p2);

    % non-linear refinement
    if numrows(X) ~= 6 && numcols(p1) >= 8
        % dont do it if invoked with 1 argument (from RANSAC)
        H = vgg_H_from_x_nonlin(H, e2h(p1), e2h(p2));
    end

    if numrows(p1) == 3
        d = h2e(H*p1) - h2e(p2);
    else
        d = homtrans(H,p1) - p2;
    end
    resid = max(colnorm(d));
    if nargout < 2,
        fprintf('maximum residual %.4g\n', resid);
    end
end

%----------------------------------------------------------------------------------
%   out = homography(ransac)
%
%   ransac.cmd      string      what operation to perform
%       'size'
%       'condition'
%       'decondition'
%       'valid'
%       'estimate'
%       'error'
%   ransac.debug    logical     display what's going on
%   ransac.X        6xN         data to work on
%   ransac.t        1x1         threshold
%   ransac.theta    3x3         estimated quantity to test
%   ransac.misc     cell        private data for deconditioning
%
%   out.s           1x1         sample size
%   out.X           6xN         conditioned data
%   out.misc        cell        private data for conditioning
%   out.inlier      1xM         list of inliers
%   out.valid       logical     if data is valid for estimation
%   out.theta       3x3         estimated quantity
%----------------------------------------------------------------------------------

function out = ransac_driver(ransac)
    cmd = ransac.cmd;
    if ransac.debug
        fprintf('RANSAC command <%s>\n', cmd);
    end
    switch cmd
    case 'size'
        % return sample size
        out.s = 4;
    case 'condition'
        p1 = ransac.X(1:2,:);
        p2 = ransac.X(3:4,:);
        p1 = e2h(p1);
        p2 = e2h(p2);
        out.X = [p1; p2];
        out.misc = {};
    case 'decondition'
        out.theta = ransac.theta;
    case 'valid'
        out.valid = ~isdegenerate(ransac.X);
    case 'error'
        [out.inliers, out.theta] = homogdist2d(ransac.theta, ransac.X, ransac.t);
    case 'estimate'
        [out.theta, out.resid] = homography(ransac.X);
    otherwise
        error('bad RANSAC command')
    end
end


% Copyright (c) 2004-2005 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% February 2004 - original version
% July     2004 - error in denormalising corrected (thanks to Andrew Stein)
% August   2005 - homogdist2d modified to fit new ransac specification.


%----------------------------------------------------------------------
% Function to evaluate the symmetric transfer error of a homography with
% respect to a set of matched points as needed by RANSAC.

function [inliers, H] = homogdist2d(H, x, t);
    
    x1 = x(1:3,:);   % Extract x1 and x2 from x
    x2 = x(4:6,:);    
    
    % Calculate, in both directions, the transfered points    
    Hx1    = H*x1;
    invHx2 = H\x2;
    
    % Normalise so that the homogeneous scale parameter for all coordinates
    % is 1.
    
    x1     = hnormalise(x1);
    x2     = hnormalise(x2);     
    Hx1    = hnormalise(Hx1);
    invHx2 = hnormalise(invHx2); 
    
    d2 = sum((x1-invHx2).^2)  + sum((x2-Hx1).^2);
    inliers = find(abs(d2) < t);    
 end   
    
%----------------------------------------------------------------------
% Function to determine if a set of 4 pairs of matched  points give rise
% to a degeneracy in the calculation of a homography as needed by RANSAC.
% This involves testing whether any 3 of the 4 points in each set is
% colinear. 
     
function r = isdegenerate(x)

    x1 = x(1:3,:);    % Extract x1 and x2 from x
    x2 = x(4:6,:);    
    
    r = ...
    iscolinear(x1(:,1),x1(:,2),x1(:,3)) | ...
    iscolinear(x1(:,1),x1(:,2),x1(:,4)) | ...
    iscolinear(x1(:,1),x1(:,3),x1(:,4)) | ...
    iscolinear(x1(:,2),x1(:,3),x1(:,4)) | ...
    iscolinear(x2(:,1),x2(:,2),x2(:,3)) | ...
    iscolinear(x2(:,1),x2(:,2),x2(:,4)) | ...
    iscolinear(x2(:,1),x2(:,3),x2(:,4)) | ...
    iscolinear(x2(:,2),x2(:,3),x2(:,4));
 end   
