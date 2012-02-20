%IMATCH Template matching
%
% XM = IMATCH(IM1, IM2, X, Y, H, S) is the matching subimage of IM1 (template)
% within the image IM2.  The template in IM1 is centred at (X,Y) and its 
% half-width is H.  
%
% The template is searched for within IM2 inside a rectangular region, centred 
% at (X,Y) and of size S.  If S is a scalar the search region is [-S, S, -S, S] % relative to (X,Y).  More generally S is a 4-vector S=[xmin, xmax, ymin, ymax]
% relative to (X,Y).
%
% The return value is XM=[DX,DY,CC] where (DX,DY) are the x- and y-offsets 
% relative to (X,Y) and CC is the similarity score (zero-mean normalized cross
% correlation) for the best match in the search region.
%
% [XM,SCORE] = IMATCH(IM1, IM2, X, Y, W2, S) works as above but also
% returns a matrix of matching score values for each template position tested.
% The rows correspond to horizontal positions of the template, and columns the
% vertical position.
%
% Notes::
% - Useful for tracking a template in an image sequence.
% - Is a MEX file.
% - IM1 and IM2 must be the same size.
% - ZNCC matching is used, a perfect match score is 1.0
%
% See also ISIMILARITY.



% Copyright (C) 1993-2011, by Peter I. Corke
%
% This file is part of The Machine Vision Toolbox for Matlab (MVTB).
% 
% MVTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% MVTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with MVTB.  If not, see <http://www.gnu.org/licenses/>.

if ~exist('imatch', 3)
    error('you need to build the MEX version of imatch, see vision/mex/README');
end
