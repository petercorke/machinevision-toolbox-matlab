%COLORNAME Map between color names and RGB values
%
% RGB = COLORNAME(NAME) is the RGB-tristimulus value corresponding to the
% color specified by the string NAME.
%
% NAME = COLORNAME(RGB) is a string giving the name of the color that is 
% closest (Euclidean) to the given RGB-tristimulus value.
%
% XYZ = COLORNAME(NAME, 'xy') is the XYZ-tristimulus value corresponding to 
% the color specified by the string NAME.
%
% NAME = COLORNAME(XYZ, 'xy') is a string giving the name of the color that is 
% closest (Euclidean) to the given XYZ-tristimulus value.
%
% Notes::
% - Color name may contain a wildcard, eg. "?burnt"
% - Based on the standard X11 color database rgb.txt.
% - Tristimulus values are in the range 0 to 1


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

function r = colorname(a, varargin)

    opt.xy = false;
    opt = tb_optparse(opt, varargin);

    persistent  rgbtable;
    
    % ensure that the database is loaded
    if isempty(rgbtable),
        % load mapping table from file
        fprintf('loading rgb.txt\n');
        f = fopen('private/rgb.txt', 'r');
        k = 0;
        rgb = [];
        names = {};
        xy = [];

        while ~feof(f),       
            line = fgets(f);
            if line(1) == '#',
                continue;
            end

            [A,count,errm,next] = sscanf(line, '%d %d %d');
            if count == 3,
                k = k + 1;
                rgb(k,:) = A' / 255.0;
                names{k} = lower( strtrim(line(next:end)) );
                xy = tristim2cc( colorspace('RGB->XYZ', rgb) );
            end
        end
        s.rgb = rgb;
        s.names = names;
        s.xy = xy;
        rgbtable = s;
    end
    
    if isstr(a)
        % map name to rgb
        if a(1)  == '?' 
            % just do a wildcard lookup
            r = namelookup(rgbtable, a(2:end));
        else
            r = name2rgb(rgbtable, a, opt.xy);
        end
    elseif iscell(a)
        % map multiple names to rgb
        r = [];
        for name=a,
            rgb = name2rgb(rgbtable, name{1}, opt.xy);
            if isempty(rgb)
                warning('Color %s not found', name{1});
            end
            r = [r; rgb];
        end
    else
        if numel(a) == 3
            r = rgb2name(rgbtable, a(:)');
        elseif numcols(a) == 2 && opt.xy
            % convert xy to a name
            r = {};
            for k=1:numrows(a),
                r{k} = xy2name(rgbtable, a(k,:));
            end
        elseif numcols(a) == 3 && ~opt.xy
            % convert RGB data to a name
            r = {};
            for k=1:numrows(a),
                r{k} = rgb2name(rgbtable, a(k,:));
            end
        end
    end
end
    
function r = namelookup(table, s)
    s = lower(s);   % all matching done in lower case
    
    r = {};
    count = 1;
    for k=1:length(table.names),
        if ~isempty( findstr(table.names{k}, s) )
            r{count} = table.names{k};
            count = count + 1;
        end
    end
end

function r = name2rgb(table, s, isxy)

    if nargin < 3
        isxy = false;
    end
    s = lower(s);   % all matching done in lower case
    
    for k=1:length(table.names),
        if strcmp(s, table.names(k)),
            r = table.rgb(k,:);
            if isxy
                r
                XYZ = colorspace('RGB->XYZ', r);
                XYZ
                r = tristim2cc(XYZ);
            end
            return;
        end
    end
    r = [];
end

function r = rgb2name(table, v)
    d = table.rgb - ones(numrows(table.rgb),1) * v;
    n = colnorm(d');
    [z,k] = min(n);
    r = table.names{k};
end

function r = xy2name(table, v)
    d = table.xy - ones(numrows(table.xy),1) * v;
    n = colnorm(d');
    [z,k] = min(n);
    r = table.names{k};
end
