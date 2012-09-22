%IWARP Generalized warp
%
% OUT = IWARP(IM, U, V) is a warped image (WxH) corresponding to
% IM (WxH).  The output pixels are taken from IM at the coordinates given
% by U and V (both WxH).  That is, the value of OUT(I,J) is given by the
% value of IM(X,Y) where X=U(I,J) and Y=V(I,J).  In general X and Y are
% not integers and the value is found by interpolation.
%
% OUT = IWARP(IM, U, V, OPTIONS) as above but OPTIONS are passed to
% the MATLAB function INTERP2 to select interpolation mode or to set
% the value of unmapped pixels.
%
% See also HOMWARP, INTERP2

function out_ = iwarp(im, U, V, varargin)

    [Ui,Vi] = imeshgrid(im);

    out = interp2(Ui, Vi, im, U, V, varargin{:});
