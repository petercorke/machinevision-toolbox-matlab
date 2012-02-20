% [R,Q] = vgg_rq(S)  Just like qr but the other way around.
%
% If [R,Q] = vgg_rq(X), then R is upper-triangular, Q is orthogonal, and X==R*Q.
% Moreover, if S is a real matrix, then det(Q)>0.


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

% By awf

function [U,Q] = rq(S)

S = S';
[Q,U] = qr(S(end:-1:1,end:-1:1));
Q = Q';
Q = Q(end:-1:1,end:-1:1);
U = U';
U = U(end:-1:1,end:-1:1);

if det(Q)<0
  U(:,1) = -U(:,1);
  Q(1,:) = -Q(1,:);
end

return
