%IINT Convert image to integer class
%
% OUT = IINT(IM) is an image with 8-bit unsigned integer elements in 
% the range 0 to 255.  The floating point pixels values in IM are assumed 
% to span the range 0 to 1.
%
% See also IDOUBLE.


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

% OUT = IINT(IM, CLASS) returns an image with integer elements of the specified
% class in the range 0 INTMAX.  CLASS is a string representing any of the 
% standard Matlab integer classes, eg. 'int16'.  The floating point pixels are 
% assumed to span the range 0 to 1.
%
% Examples::
%
%    im = iint(dim, 'int16');
%
% See also IDOUBLE, CLASS, INTMAX.

function im = iint(in, cls)

    if nargin < 2
        cls = 'uint8';
    end

    if isfloat(in)
        % rescale to integer
        im = cast(round( in * double(intmax(cls))), cls);
    else
        im = cast(in, cls);
    end
