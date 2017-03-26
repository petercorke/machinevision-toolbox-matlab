%CMFRGB RGB color matching function
%
% The color matching function is the RGB tristimulus required to match a 
% particular spectral excitation.
%
% RGB = CMFRGB(LAMBDA) is the CIE color matching function (Nx3) for illumination
% at wavelength LAMBDA (Nx1) [m].  If LAMBDA is a vector then each row of RGB
% is the color matching function of the corresponding element of LAMBDA. 
%
% RGB = CMFRGB(LAMBDA, E) is the CIE color matching (1x3) function for an 
% illumination spectrum E (Nx1) defined at corresponding wavelengths
% LAMBDA (Nx1).
%
% Notes::
% - Data from http://cvrl.ioo.ucl.ac.uk
% - From Table I(5.5.3) of Wyszecki & Stiles (1982). (Table 1(5.5.3)
%   of Wyszecki & Stiles (1982) gives the Stiles & Burch functions in
%   250 cm-1 steps, while Table I(5.5.3) of Wyszecki & Stiles (1982)
%   gives them in interpolated 1 nm steps.)
% - The Stiles & Burch 2-deg CMFs are based on measurements made on
%   10 observers. The data are referred to as pilot data, but probably
%   represent the best estimate of the 2 deg CMFs, since, unlike the CIE
%   2 deg functions (which were reconstructed from chromaticity data),
%   they were measured directly.
% - These CMFs differ slightly from those of Stiles & Burch (1955). As
%   noted in footnote a on p. 335 of Table 1(5.5.3) of Wyszecki &
%   Stiles (1982), the CMFs have been "corrected in accordance with
%   instructions given by Stiles & Burch (1959)" and renormalized to
%   primaries at 15500 (645.16), 19000 (526.32), and 22500 (444.44) cm-1
%
% References::
%  - Robotics, Vision & Control, Section 10.2,
%    P. Corke, Springer 2011.
%
% See also CMFXYZ, CCXYZ.



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


function rgb = cmfrgb(lambda, spect)
    rgb = loadspectrum(lambda, 'cmfrgb.dat');
    
    if nargin == 2
        % approximate rectangular integration
        dlambda = lambda(2) - lambda(1);
        rgb = spect(:)' * rgb / numrows(rgb) * dlambda;
    end
