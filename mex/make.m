% Copyright (C) 1995-2009, by Peter I. Corke
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

fprintf('** building MEX files for MVTB\n');
pth = which('imorph.m');
pth = fileparts(pth);
cd( fullfile(pth, 'mex') );

mexfiles = {
    'closest.c',
    'fhist.c',
    'hist2d.c',
    'ilabel.c',
    'imatch.c',
    'imorph.c',
    'irank.c',
    'ivar.c',
    'iwindow.c',
    'stereo_match.c'
    };

for file = mexfiles'
    fprintf('\n* Compiling: %s\n', file{1});
    mex('CFLAGS=-std=c99',  file{1})
end

% MATLAB script to build apriltags.mex
%
% you must have first installed the standalone C version of AprilTags
% obtained from https://april.eecs.umich.edu/wiki/index.php/AprilTags.
% and named it apriltags
%
% then built the library, run make in the apriltags folder.

fprintf('\n* Compiling: apriltags.c\n');

% test for apriltag folder
if ~exist('apriltag', 'file')
    error('no apriltag folder found in current directory, download it from https://april.eecs.umich.edu/wiki/index.php/AprilTags');
end

p = which('apriltag.h');
p = fileparts(p);

% test for a build library
if ~exist(fullfile(p, 'libapriltag.a'), 'file')
    error('you need to first build the apriltag library: libapriltag.a');
end

eval( sprintf('mex apriltags.c -I%s -I%s/common -L%s -lapriltag', p, p, p) )

