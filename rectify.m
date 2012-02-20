

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
function imr = rectify(F, J, Jp, mxy)
    % using H&Z notation, p suffix means prime, Jp = J'

    %% first we need to find the transform Hp that sends the 
    %% epipole of Jp to infinity.

    % use method of 11.12.1
    
    % set the center of the transform
    x0 = [numcols(J) numrows(J)] / 2;
    T = [1 0 -x0(1); 0 1 -x0(2); 0 0 1]

    % display the original epipole
    ep = null(F');
    fprintf('original epipole: %g %g\n', h2e(ep));

    % change origin to centre of the image
    ep_t = T*ep;
    fprintf('translated epipole: %g %g\n', h2e(ep_t));
    e = h2e(ep_t);

    tt = -(e(2)) / (e(1));
    ct = cos(atan(tt));
    R = [1 -tt 0 ; tt 1 0; 0 0 1/ct];
    R

    ep_tr = R*ep_t;
    fprintf('translated rotated epipole: %g %g\n', h2e(ep_tr));

    % now translate the epipole to infinity
    e = h2e(ep_tr);
    f = e(1);
    G = [1 0 0; 0 1 0; -1/f 0 1];

    % complete transform for image Jp
    Hp = G * R * T;
    G
    R
    T
    Hp

    % now find the transform H that minimizes distance using
    % method of 11.12.2

    % from the errata to H&Z book
    [U,D,V] = svd(F);
    W = [0 1 0; -1 0 0; 0 0 0]; Z= [0 -1 0; 1 0 0; 0 0 1];
    S = U*W*U';
    M = U*Z*D'*V';

    % cross check
    %S*M - F
    % it's good

    H0 = Hp*M;
    xy_hat = homtrans(H0, mxy(:,1:2)');
    xyp_hat = homtrans(Hp, mxy(:,3:4)');

    A = [xy_hat(1,:)' xy_hat(2,:)' ones(numcols(xy_hat),1)];
    B = xyp_hat(1,:)';
    abc = pinv(A)*B
    whos
    rank(A)
    head(A)
    max(abs(A*abc-B))
    head([A*abc B])
    HA = [abc'; 0 1 0; 0 0 1];
    HA = [1 0 abc(3); 0 1 0; 0 0 1];
    mean(xy_hat(1,:)-xyp_hat(1,:))

    Jp_rect = imTrans(Jp, Hp);
    f1
    idisp(Jp_rect);
    f2
    idisp(Jp);
    f3
    J_rect = imTrans(J, HA);
    idisp(J_rect);


    eph = null(F');


end
