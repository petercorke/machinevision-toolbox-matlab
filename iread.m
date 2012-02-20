%IREAD  Read image from file
%
% IM = IREAD() presents a file selection GUI from which the user can select
% an image file which is returned as 2D or 3D matrix.  On subsequent calls 
% the initial folder is as set on the last call.
%
% IM = IREAD(FILE, OPTIONS) reads the specified file and returns a matrix.  If
% the path is relative it is searched for on Matlab search path.
%
% Wildcards are allowed in file names.  If multiple files match a 3D or 4D image
% is returned where the last dimension is the number of images in the sequence.
%
% Options::
% 'uint8'      return an image with 8-bit unsigned integer pixels in 
%              the range 0 to 255
% 'single'     return an image with single precision floating point pixels
%              in the range 0 to 1.
% 'double'     return an image with double precision floating point pixels
%              in the range 0 to 1.
% 'grey'       convert image to greyscale if it's color using ITU rec 601
% 'grey_709'   convert image to greyscale if it's color using ITU rec 709
% 'gamma',G    gamma value, either numeric or 'sRGB'
% 'reduce',R   decimate image by R in both dimensions
% 'roi',R      apply the region of interest R to each image, 
%              where R=[umin umax; vmin vmax].
% Notes::
% - A greyscale image is returned as an HxW matrix
% - A color image is returned as an HxWx3 matrix
% - A greyscale image sequence is returned as an HxWxN matrix where N is the 
%   sequence length 
% - A color image sequence is returned as an HxWx3xN matrix where N is the 
%   sequence length 
%
% See also IDISP, IMONO, IGAMMA, IMWRITE, PATH.



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


function [I,info] = iread(filename, varargin)
    persistent mypath

    % options
    %
    %   'float
    %   'uint8
    %   'grey'
    %   'gray'
    %   'grey_601'
    %   'grey_709'
    %   'grey_value'
    %   'gray_601'
    %   'gray_709'
    %   'gray_value'
    %   'reduce', n

    opt.type = {[], 'double', 'single', 'uint8'};
    opt.mkGrey = {[], 'grey', 'gray', 'mono', '601', 'grey_601', 'grey_709'};
    opt.gamma = [];
    opt.reduce = 1;
    opt.roi = [];
    opt.disp = [];

    opt = tb_optparse(opt, varargin);

    im = [];
    
    if nargin == 0,
        % invoke file browser GUI
        [file, npath] = uigetfile(...
            {'*.png;*.pgm;*.ppm;*.jpg;*.tif', 'All images';
            '*.pgm', 'PGM images';
            '*.jpg', 'JPEG images';
            '*.gif;*.png;*.jpg', 'web images';
            '*.*', 'All files';
            }, 'iread');
        if file == 0,
            fprintf('iread canceled from GUI\n');
            return; % cancel button pushed
        else
            % save the path away for next time
            mypath = npath;
            filename = fullfile(mypath, file);
            im = loadimg(filename, opt);
        end
    elseif (nargin == 1) & exist(filename,'dir'),
        % invoke file browser GUI
        if isempty(findstr(filename, '*')),
            filename = strcat(filename, '/*.*');
        end
        [file,npath] = uigetfile(filename, 'iread');
        if file == 0,
            fprintf('iread canceled from GUI\n');
            return; % cancel button pushed
        else
            % save the path away for next time
            mypath = npath;
            filename = fullfile(mypath, file);
            im = loadimg(filename, opt);
        end
    else
        % some kind of filespec has been given
        if ~isempty(strfind(filename, '*')) | ~isempty(strfind(filename, '?')),
            % wild card files, eg.  'seq/*.png', we need to look for a folder
            % seq somewhere along the path.
                        [pth,name,ext] = fileparts(filename);

            if opt.verbose
                fprintf('wildcard lookup: %s %s %s\n', pth, name, ext);
            end
            
            % search for the folder name along the path
            folderonpath = pth;
            for p=path2cell(path)'  % was userpath
                if exist( fullfile(p{1}, pth) ) == 7
                    folderonpath = fullfile(p{1}, pth);
                    if opt.verbose
                        fprintf('folder found\n');
                    end
                    break;
                end
            end
            s = dir( fullfile(folderonpath, [name, ext]));      % do a wildcard lookup

            if length(s) == 0,
                error('no matching files found');
            end

            for i=1:length(s)
                im1 = loadimg( fullfile(folderonpath, s(i).name), opt);
                if i==1
                    % preallocate storage, much quicker
                    im = zeros([size(im1) length(s)], class(im1));
                end
                if ndims(im1) == 2
                    im(:,:,i) = im1;
                elseif ndims(im1) == 3
                    im(:,:,:,i) = im1;
                end
            end
        else
            % simple file, no wildcard
            if strncmp(filename, 'http://', 7)
                im = loadimg(filename, opt);
            elseif exist(filename)
                im = loadimg(filename, opt);
            else
                % see if it exists on the Matlab search path
                for p=path2cell(path)'
                    if exist( fullfile(p{1}, filename) ) > 0
                        im = loadimg(fullfile(p{1}, filename), opt);
                        break;
                    end
                end
  
            end
        end
    end

                      
    if isempty(im)
        error(sprintf('cant open file: %s', filename));
    end
    if nargout > 0
        I = im;
        if nargout > 1
            info = imfinfo(filename);
        end
    else
        % if no output arguments display the image
        if ndims(I) <= 3
            idisp(I);
        end
    end
end

function im = loadimg(name, opt)

    % now we read the image
    im = imread(name);

    if opt.verbose
        if ndims(im) == 2
            fprintf('loaded %s, %dx%d\n', name, size(im,2), size(im,1));
        elseif ndims(im) == 3
            fprintf('loaded %s, %dx%dx%d\n', name, size(im,2), size(im,1), size(im,3));
        end
    end

    % optionally convert it to greyscale using specified method
    if ~isempty(opt.mkGrey) && (ndims(im) == 3)
        im = imono(im, opt.mkGrey);
    end

    % optionally chop out a roi
    if ~isempty(opt.roi)
        im = iroi(im, opt.roi);
    end

    % optionally decimate it
    if opt.reduce > 1,
        im = im(1:opt.reduce:end, 1:opt.reduce:end, :);
    end

    % optionally convert to specified numeric type
    if ~isempty(opt.type)
        if isempty(findstr(opt.type, 'int'))
            im = cast(im, opt.type) / double(intmax(class(im)));
        else
            im = cast(im, opt.type);
        end
    end

    % optionally gamma correct it
    if ~isempty(opt.gamma)
        im = igamma(im, opt.gamma);
    end

    if opt.disp
        idisp(im);
    end

end
