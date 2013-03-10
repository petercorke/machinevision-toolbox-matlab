%LOADPCD Load a point cloud from a PCD format file
%
% P = LOADPCD(FNAME) is a set of points (3xN) loaded from the PCD format
% file FNAME.  The columns of P represent the 3D points.
%
% Notes::
% - Only the x y z field format are currently supported
% - The file can be in ascii or binary format, binary_compressed is not
%   supported
%
% See also pclviewer, loadpcd.
%
% Copyright (C) 2013, by Peter I. Corke

% TODO
% - add color
% - handle binary_compressed
% - handle organized point clouds
% - allow fields to be of different types, particularly useful for RGB

function points = loadpcd(fname)

    verbose = true;
    
    fp = fopen(fname, 'r');
    
    
    while true
        line = fgetl(fp);
        
        if line(1) == '#'
            continue;
        end
        
        [field,remain] = strtok(line, ' \t');
        remain = strtrim(remain);
        
        switch field
            case 'VERSION'
                continue;
            case 'FIELDS'
                fields = remain;
            case 'TYPE'
                type = remain;
            case 'WIDTH'
                width = str2num(remain);
            case 'HEIGHT'
                height = str2num(remain);
            case 'POINTS'
                npoints = str2num(remain);
            case 'SIZE'
                size = str2num(remain);
            case 'COUNT'
                count = str2num(remain);
            case 'DATA'
                mode = remain;
                break;
            otherwise
                fprintf('unknown field %s\n', field);
        end
    end
    
    if verbose
        if height == 1
            org = 'unorganized';
        else
            org = 'organized';
        end
        fprintf('%s: %s, %s, <%s> %dx%d\n', ...
            fname, mode, org, fields, width, height);
        fprintf('  %s; %s\n', type, num2str(size));
    end
    
    if any(count > 1)
        error('can only handle 1 element per dimension');
    end
    
    switch mode
        case 'ascii'
            format = '';
            for j=1:numcols(size)
                [tok,type] = strtok(type);
                format = [format '%' lower(tok) num2str(size(j)*8)];
                    end
            c = textscan(fp, format, npoints);
            points = [];
            for j=1:length(c)
                points = [points; c{j}'];
            end
            
        case 'binary'
            format = '';
            for j=1:numcols(size)
                [tok,type] = strtok(type);
                typ(j) = tok;
            end
            if any(typ ~= typ(1))
                error('for binary reading all fields must be of same TYPE');
            end
            if any(size ~= size(1))
                error('for binary reading all fields must be of same SIZE');
            end
            
            % map IUF -> int, uint, float
            switch typ(1)
                case 'I'
                    fmt = 'int';
                case 'U'
                    fmt = 'uint';
                case 'F'
                    fmt = 'float';
            end
                
            format = [format '*' fmt num2str(size(j)*8)];
            points = fread(fp, [numel(size) npoints], format);

            
        otherwise
            % I have no idea how binary_compressed works...
            error('unknown DATA mode: %s', mode);
    end
    
    % convert RGB from float to rgb
    if strcmp(fields, 'x y z rgb')
        rgb = typecast(points(4,:), 'uint32');
        R = double(bitand(255, bitshift(rgb, 16))) /255;
        G = double(bitand(255, bitshift(rgb, 8))) /255;
        B = double(bitand(255, rgb)) /255;
        
        points = [points(1:3,:); R; G; B];
    end
               
    fclose(fp);