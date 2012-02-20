%OTSU  Threshold selection
%
% T = OTSU(IM) is an optimal threshold for binarizing an image with a bimodal
% intensity histogram.  T is a scalar threshold that maximizes the variance 
% between the classes of pixels below and above the thresold T.
%
% Example::
%     t = otsu(im);
%     idisp(im >= t);
%
% Notes::
% - Performance for images with non-bimodal histograms can be quite poor.
%
% Reference::
%  A Threshold Selection Method from Gray-Level Histograms,
%  N. Otsu
%  IEEE Trans. Systems, Man and Cybernetics
%  Vol SMC-9(1), Jan 1979, pp 62-66
%
% See also NIBLACK, ITHRESH.


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

function t = otsu(im, N)

    if nargin < 2
        N = 255;
    end
    n = prod(size(im));
    nb = 0;
    no = n;
    ub = 0;

    % convert image to discrete values [0,N]
    if isfloat(im)
        im2 = round(im*N);
    else
        im2 = im;
    end

    h = histc(im2(:), 0:N);
    uo = sum(im2(:))/n;

    % the between class variance
    s2b = zeros(N,1);
    for T=1:N

        nt = h(T);
        nb_new = nb + nt;
        no_new = no - nt;

        if (nb_new == 0) || (no_new == 0)
            continue;
        end

        ub = (ub*nb + nt*(T-1)) / nb_new;
        uo = (uo*no - nt*(T-1)) / no_new;

        s2b(T) = nb*no*(ub - uo)^2;

        %fprintf('%d %d %f %f %f\n', nb, no, ub, uo, s2b(T));
        nb = nb_new;
        no = no_new;

    end

    [z,t] = max(s2b);

    if isfloat(im)
        t = t / N;
    end
