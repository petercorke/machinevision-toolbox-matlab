%IGRAPHSEG Graph-based segmentation
%
% L = IGRAPHSEG(IM, K, MIN) is a graph-based segmentation of the greyscale 
% or color image IM.  L is an image of the same size as IM where each 
% element is the label assigned to the corresponding pixel in IM.  K is
% the scale parameter, and a larger value indicates a preference for
% larger regions, MIN is the minimum region size (pixels).
%
% L = IGRAPHSEG(IM, K, MIN, SIGMA) as above and SIGMA is the width of 
% a Gaussian which is used to initially smooth the image (default 0.5).
%
% [L,M] = IGRAPHSEG(IM, K, MIN, SIGMA) as above but M is the number of regions
% found.
%
% Example::
%
%     im = iread('58060.jpg');
%     [l,m] = igraphseg(im, 1500, 100, 0.5);
%     idisp(im)
%
% Reference::
%  "Efficient graph-based image segmentation",
%  P. Felzenszwalb and D. Huttenlocher, 
%  Int. Journal on Computer Vision,
%  vol. 59, pp. 167–181, Sept. 2004.
%
% Notes::
% - Is a MEX file
%
% Author::
%  Pedro Felzenszwalb, 2006.
%
% See also ITHRESH, IMSER.

function [L,M] = igraphseg(varargin)
    if nargout == 1
        L = graphseg(varargin{:});
    elseif nargout == 2
        [L,M] = graphseg(varargin{:});
    end
