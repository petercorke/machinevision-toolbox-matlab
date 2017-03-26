%IDOUBLE Convert integer image to double
%
% IMD = IDOUBLE(IM, OPTIONS) is an image with double precision elements in the
% range 0 to 1 corresponding to the elements of IM. The integer pixels IM
% are assumed to span the range 0 to the maximum value of their integer class.
%
% Options::
%  'single'    Return an array of single precision floats instead of doubles.
%  'float'     As above.
%
% Notes::
% - Works for an image with arbitrary number of dimensions, eg. a color
%   image or image sequence.
% - There is a linear mapping (scaling) of the values of IMD to IM.
%
% See also IINT, CAST.


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

function out = idouble(im, varargin)
    
    opt.single = false;
    opt.float = false;
    
    opt = tb_optparse(opt, varargin);

    if opt.single || opt.float
        % convert to float pixel values
        if isinteger(im)
            out = single(im) / single(intmax(class(im)));
        else
            out = single(im);
        end
    else
        % convert to double pixel values (default)
        if isinteger(im)
            out = double(im) / double(intmax(class(im)));
        else
            out = double(im);
        end
    end
    

