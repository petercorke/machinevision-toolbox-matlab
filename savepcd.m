%SAVEPCD Write a point cloud to file in PCD format
%
% SAVEPCD(FNAME, P) writes the point cloud P (3xN) to the file FNAME.  The 
% columns of P represent the 3D points.
%
% Notes::
% - Only the x y z field format are currently supported
% - The file is written in ascii format
%
% See also pclviewer, readpcd.
%
% Copyright (C) 2013, by Peter I. Corke

% TODO
% - add color
function savepcd(fname, points)
    % save points in xyz format
    % TODO
    %  binary format, RGB
    
    fp = fopen(fname, 'w');
    
    fprintf(fp, '# .PCD v.7 - Point Cloud Data file format');
    fprintf(fp, 'VERSION .7\n');
    fprintf(fp, 'FIELDS x y z\n');
    fprintf(fp, 'SIZE 4 4 4\n');
    fprintf(fp, 'TYPE F F F\n');
    fprintf(fp, 'COUNT 1 1 1\n');
    fprintf(fp, 'WIDTH %d\n', numcols(points));
    fprintf(fp, 'HEIGHT 1\n'); % unorganized point cloud
    fprintf(fp, 'POINTS %d\n', numcols(points));
    fprintf(fp, 'DATA ascii\n');
    
    for p=points
        fprintf(fp, '%f %f %f\n', p);
    end
    
    
