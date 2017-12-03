% Copyright (C) 1993-2013, by Peter I. Corke
%
% This file is part of The Machine Vision Toolbox for MATLAB (MVTB).
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
%
% http://www.petercorke.com

%%begin

% This demo simulates an IBVS controller.

cam = CentralCamera('default');
P = mkgrid(2, 0.5, 'T', transl(0,0,3));
pStar = bsxfun(@plus, 200*[-1 -1 1 1; -1 1 1 -1], cam.pp')

Tc0 = transl(1,1,-3)*trotz(0.6);
ibvs= IBVS(cam, 'T0', Tc0, 'pstar', pStar)
ibvs.run()
ibvs.plot_p()
ibvs.plot_vel()
ibvs.plot_camera()
ibvs.plot_jcond()
clf

ibvs = IBVS_l(cam, 'example');
ibvs.run()

