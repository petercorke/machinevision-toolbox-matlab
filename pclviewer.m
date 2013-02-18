%PCLVIEWER View a point cloud using PCL
%
% PCLVIEWER(P) writes the point cloud P (3xN) to a temporary file and invokes
% the PCL point cloud viewer for fast display and visualization.  The columns of P
% represent the 3D points.
%
% PCLVIEWER(P, ARGS) as above but the optional arguments ARGS are passed to the
% PCL viewer.
%
% Notes::
% - Only the x y z field format are currently supported
% - The file is written in ascii format
%
% See also savepcd, readpcd.
%
% Copyright (C) 2013, by Peter I. Corke

% TODO
% - add color


function pclviewer(points, args)
    
    % change the next line to suit your operating system
    viewer = '/usr/local/bin/pcl_viewer.app/Contents/MacOS/pcl_viewer';

     
    pointfile = [tempname '.pcd'];
    
    if nargin < 2
        args = '';
    end
    
    savepcd(pointfile, points);
    
    system(sprintf('%s %s %s &', ...
        viewer, pointfile, args));
   
    pause(1)
    delete(pointfile);
    