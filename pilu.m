%JUNK


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
function pilu(p1, p2, sigma)

    r = [];
    for i=1:numcols(p1)
        for j=1:numcols(p2)
            r(i,j) = norm(p1(:,i)-p2(:,j));
        end
    end
        
    G = exp(-r.^2/2/sigma^2);

    [T,D,Ut] = svd(G);

    E = D;
    for i=1:min(size(D))
        E(i,i) = 1;
    end
    P = T*E*Ut;

    f1
    idisp(P)
    f2
    clf
    plot2(p1', 'o');
    hold on
    plot2(p2', '+');

    for row=1:numrows(P)
        [z,col] = max(P(row,:));       % find maximum in this row
        [z,row2] = max(P(:,col));       % find maximum in this column
        if row2 == row
            fprintf('%d -> %d\n', row, row2);
            plot([p1(1,row) p2(1,col)], [p1(2,row) p2(2,col)]);
        end
    end
        
