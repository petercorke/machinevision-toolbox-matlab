%STARTUP_MVTB Initialize MATLAB paths for Machine Vision Toolbox
%
% Adds demos, data, contributed code and examples to the MATLAB path.
%
% Notes::
% - This sets the paths for the current session only.
% - To make the settings persistent across sessions you can:
%   - Add this script to your MATLAB startup.m script.
%   - After running this script run PATHTOOL and save the path.
%
% See also PATH, ADDPATH, PATHTOOL, JAVAADDPATH.


% Copyright (C) 1993-2017, by Peter I. Corke
%
% This file is part of The Machine Toolbox for MATLAB (MVTB).
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
% along with RTB.  If not, see <http://www.gnu.org/licenses/>.
%
% http://www.petercorke.com

function startup_mvtb(tbpath)
    
    release = load('RELEASE');
    fprintf('- Machine Vision Toolbox for MATLAB (release %.1f)\n', release);
    
    if nargin == 0
        tbpath = fileparts( mfilename('fullpath') );
    end
    addpath( fullfile(tbpath, 'examples') );
    addpath( fullfile(tbpath, 'images') );
    addpath( fullfile(tbpath, 'mex') );
    addpath( fullfile(tbpath, 'data') );
    p = fullfile(tbpath, 'simulink');
    if exist(p, 'dir')
        addpath( p );
    end
    % add the contrib code to the path
    rvcpath = fileparts(tbpath);  % strip one folder off path
    addpath( fullfile(rvcpath, 'contrib') );

    p = fullfile(rvcpath, 'contrib/vgg');
    if exist(p)
        addpath( p );
        disp([' - VGG contributed code (' p ')']);
    end
    p = fullfile(rvcpath, 'contrib/EPnP');
    if exist(p)
        addpath( p );
        disp([' - EPnP contributed code (' p ')']);
    end
    p = fullfile(rvcpath, ['contrib/vlfeat-0.9.20/toolbox/mex/' mexext]);
    if exist(p)
        addpath( p );
        disp([' - VLFeat contributed code (' p ')']);

        p = fullfile(rvcpath, 'contrib/sift');
        if exist(p)
            addpath( p );
            disp([' - VLFeat SIFT wrapper (' p ')']);
        end
    end

    p = fullfile(rvcpath, 'contrib/surf');
    if exist(p)
        addpath( p );
        disp([' - OpenSURF contributed code + wrapper (' p ')']);
    end
    p = fullfile(rvcpath, 'contrib/graphseg');
    if exist(p)
        addpath( p );
        disp([' - graphseg contributed code (' p ')']);
    end
end
