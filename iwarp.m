%IWARP Generalized warp
%
% OUT = IWARP(IM, U, V) returns a warped image OUT (WxH) whose
% output pixels are given by the correspding coordinates of
% U and V (both WxH).  That is, the value of OUT(I,J) is given
% by IM(X,Y) where X=U(I,J) and Y=V(I,J).  In general X and Y are
% not integers and the value is found by interpolation.
%
% See also HOMWARP, INTERP2

function out = iwarp(im, U, V)

    [Ui,Vi] = imeshgrid(im);

    out = interp2(Ui, Vi, im, U, V);
