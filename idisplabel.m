%IDISPLABEL  Display an image with mask
%
% IDISPLABEL(IM, LABELIMAGE, LABELS) displays only those image pixels which 
% belong to a specific class.  IM is a greyscale NxM or color NxMx3 image, and
% LABELIMAGE is an NxM image containing integer pixel class labels for the
% corresponding pixels in IM.  The pixel classes to be displayed are given by
% the elements of LABELS which is a scalar a vector of class labels.  
% Non-selected pixels are displayed as white.
%
% IDISPLABEL(IM, LABELIMAGE, LABELS, BG) as above but the grey level of the 
% non-selected pixels is specified by BG in the range 0 to 1.
%
% See also IBLOBS, ICOLORIZE, COLORSEG.

function idisplabel(im, label, select, bg)

    if isscalar(select)
        mask = label == select;
    else
        mask = zeros(size(label));
        for s=select(:)',
            mask = mask | (label == s);
        end
    end
    
    if nargin < 4
        bg = 1;
    end
    
    if ndims(im) == 3
        mask = cat(3, mask, mask, mask);
    end
    
    im(~mask) = bg;
    idisp(im, 'nogui');
    shg
