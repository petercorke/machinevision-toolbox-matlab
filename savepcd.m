%SAVEPCD Write a point cloud to file in PCD format
%
% SAVEPCD(FNAME, P) writes the point cloud P (MxN) to the file FNAME as an
% unorganized point cloud.  The columns of P represent the 3D points.
%
% If M=3 then the rows are x, y, z.
% If M=6 then the rows are x, y, z, R, G, B where R,G,B are in the range 0
% to 1.
%
% Notes::
% - Only the "x y z" and "x y z rgb" field formats are currently supported.
% - The file is written in ascii format as an unorganized point cloud.
%
% See also pclviewer, readpcd.
%
% Copyright (C) 2013, by Peter I. Corke

% TODO
% - handle organized point clouds

function savepcd(fname, points)
    % save points in xyz format
    % TODO
    %  binary format, RGB
    
    fp = fopen(fname, 'w');
    
    fprintf(fp, '# .PCD v.7 - Point Cloud Data file format');
    fprintf(fp, 'VERSION .7\n');
    if numrows(points) == 6
        % rgb data as well
        fprintf(fp, 'FIELDS x y z rgb\n');
        fprintf(fp, 'SIZE 4 4 4 4\n');
        fprintf(fp, 'TYPE F F F I\n');
        fprintf(fp, 'COUNT 1 1 1 1\n');
    else
        fprintf(fp, 'FIELDS x y z\n');
        fprintf(fp, 'SIZE 4 4 4\n');
        fprintf(fp, 'TYPE F F F\n');
        fprintf(fp, 'COUNT 1 1 1\n');
    end
    fprintf(fp, 'WIDTH %d\n', numcols(points));
    fprintf(fp, 'HEIGHT 1\n'); % unorganized point cloud
    fprintf(fp, 'POINTS %d\n', numcols(points));
    fprintf(fp, 'DATA ascii\n');
    
    if numrows(points) == 6
        % RGB data as well
        RGB = uint32(points(4:6,:)*255);
        rgb = (RGB(1,:)*256+RGB(2,:))*256+RGB(3,:);

        for i=1:numcols(points)
            fprintf(fp, '%f %f %f %d\n', points(1:3,i), rgb(i));
        end
        
    else
        % uncolored points
        for p=points
            fprintf(fp, '%f %f %f\n', p);
        end
    end
    

