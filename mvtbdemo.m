%MVTBDEMO 	Machine Vision toolbox demonstrations
%
% Displays popup menu of toolbox demonstration scripts that illustrate:
%   - image processing
%   - feature extraction
%   - visual servoing
%
% Notes::
% - The scripts require the user to periodically hit <Enter> in order to move
%   through the explanation.
% - Set PAUSE OFF if you want the scripts to run completely automatically.

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
% along with RTB.  If not, see <http://www.gnu.org/licenses/>.
function mvtbdemo(timeout)
    echo off
    close all
    echo off
    clear all
    delete( get(0, 'Children') );
    
    % find the path to the demos
    if exist('mvtbdemo', 'file') == 2
        tbpath = fileparts(which('mvtbdemo'));
        demopath = fullfile(tbpath, 'demos');
    end
    
    opts = {'begin', 'path', demopath};
    
    % if a timeout interval is given, add this to the options
    if nargin > 0
        opts = {opts, 'delay', timeout};
    end
    
    
    fprintf('------------------------------------------------------------\n');
    fprintf('Many of these demos print tutorial text and MATLAB commmands in the console window.\n');
    fprintf('Read the text and press <enter> to move on to the next command\n');
    fprintf('At the end of the tutorial/demo you can choose the next one from the graphical menu.\n');
    fprintf('------------------------------------------------------------\n');
    
    demos = {
        'Basics', 'files';
        'Image/Movie file', 'moviegrab';
        'Image/Webcam', 'webcam';
        'Image/Google Earth', 'earthgrab';
        'Image/Live video', 'livevideo';
        'Image/Track object', 'trackblue';
        'Application/Mosaicing', 'mosaic';
        'Application/ICP', 'icp';              % broken
        'Application/Line Fit', 'linefit';     % broken
        'Application/Hough transform', 'hough';
        'Application/Chroma key', 'chromakey';
        'Application/RANSAC', 'ransac';         % broken
        'Application/Background estimation', 'bgest';
        'Application/Where''s Wally', 'wally';
        'Multiview/Stereo', 'stereo';
        % blobs
        % camera
        % convdemo
        % fly
        % harris
        % homdemo
        % imagegrab
        % kernel
        % lensanim
        % opticalflow
        % poseest
        % ransacline
        % seg
        % skel
        % track
        % track2
        % vservo_points
        % xx
        'VisualServo/Mosaicing', '';
        'VisualServo/Mosaicing', 'mosaic';
        'VisualServo/Mosaicing', 'mosaic';
        'Exit', '';
        };
    
    while true
        selection = menu('Machine Vision Toolbox demonstrations', demos{:,1});
        if strcmp(demos{selection,1}, 'Exit')
            % quit now
            delete( get(0, 'Children') );
            break;
        else
            % run the appropriate script
            script = demos{selection,2}
            runscript(script, opts{:})
        end
    end
end

