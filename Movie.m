%MOVIE Class to read movie file
%
% A concrete subclass of ImageSource that acquires images from a web camera
% built by Axis Communications (www.axis.com).
%
% Methods::
% grab    Aquire and return the next image
% size    Size of image
% close   Close the image source
% char    Convert the object parameters to human readable string
%
% Properties::
% curFrame        The index of the frame just read
% totalDuration   The running time of the movie (seconds)
%
% See also ImageSource, Video.
%
%
% SEE ALSO: Video

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


classdef Movie < ImageSource

    properties

        rate            % frame rate at which movie was capture

        nframes;
        
        totalDuration   % in seconds
        skippedFrames

        curFrame
        skip
        
        movie
        
        fullfilename

    end

    methods

        function m = Movie(filename, varargin)
        %Movie.Movie Image source constructor
        %   
        % M = Movie(FILE, OPTIONS) is an Movie object that returns frames
        % from the movie file FILE.
        %   
        % Options::
        % 'uint8'     Return image with uint8 pixels (default)
        % 'float'     Return image with float pixels
        % 'double'    Return image with double precision pixels
        % 'grey'      Return greyscale image
        % 'gamma',G   Apply gamma correction with gamma=G
        % 'scale',S   Subsample the image by S in both directions
        % 'skip',S    Read every S'th frame from the movie


            % invoke the superclass constructor and process common arguments
            m = m@ImageSource(varargin{:});

            m.curFrame = 1;
            
            % open the movie file and copy some of its parameters to object
            % properties
            
            % see if it exists on the MATLAB search path
            p = fileparts( which('iread') );
            pth = [ fullfile(p, 'images') path2cell(path)];
            for p=pth
                fname = fullfile(p{1}, filename);
                if exist( fname ) > 0
                    m.fullfilename = fullfile(p{1}, filename);
                    m.movie = VideoReader(m.fullfilename);
                    break;
                end
            end
            
            if isempty(m.movie)
                error('MVTB:badarg:nosuchfile', 'Can''t find file: %s', filename);
            end

            m.width = m.movie.Width;
            m.height = m.movie.Height;
            m.rate = m.movie.FrameRate;
            m.totalDuration = m.movie.Duration;
            m.nframes = m.movie.NumberOfFrames;
        
        end
        

        function paramSet(m, varargin)
            opt.skip = 1;
            
            disp(varargin)
            opt = tb_optparse(opt, varargin);
            m.skip = opt.skip;
        end
        
        % destructor
        function delete(m)
            fprintf('Movie destructor, delete movie object\n');
            delete(m.movie);
        end

        function close(m)
        %Movie.close Close the image source
        %
        % M.close() closes the connection to the movie.

            delete(m.movie);
        end

        function sz = size(m)
            sz = [m.width m.height];
        end

        function [out, time] = grab(m, varargin)
        %Movie.grab Acquire next frame from movie
        %
        % IM = M.grab() acquires the next image from the movie
        %
        % IM = M.grab(OPTIONS) as above but allows the next frame to be
        % specified.
        %
        % Options::
        % 'skip',S    Skip frames, and return current+S frame
        % 'frame',F   Return frame F within the movie
        %
        % Notes::
        % - If no output argument given the image is displayed using IDISP.

            opt.skip = m.skip;
            opt.frame = [];
            
            opt = tb_optparse(opt, varargin);
            

            if isempty(opt.frame)
                m.curFrame = m.curFrame + opt.skip;
            else
                m.curFrame = opt.frame;
            end
            
            % read next frame from the file
            if m.curFrame < m.nframes
                try
                    data = read(m.movie, m.curFrame);
                catch me
                    % it seems that the test above is not enough to prevent reading past
                    % the end of file...
                    if strcmp(me.identifier, 'MATLAB:audiovideo:VideoReader:invalidFrameVarFrameRate')
                        out = [];
                        return;
                    else
                        rethrow(me);
                    end
                end
            else
                out = [];
                return;
            end


            if (numel(data) > 3*m.width*m.height)
                warning('Movie: dimensions do not match data size. Got %d bytes for %d x %d', numel(data), m.width, m.height);
            end

            if any(size(data) == 0)
                warning('Movie: could not decode frame %d', m.curFrame);
            else
                % the data ordering is wrong for matlab images, so permute it
                %data = permute(reshape(data, 3, m.width, m.height),[3 2 1]);
                im = data;
            end

            % apply options specified at construction time
            im = m.convert(im);
            
            if nargout == 0
                idisp(im);
            else
                out = im;
            end
        end

        function s = char(m)
        %Movie.char Convert to string
        %
        % M.char() is a string representing the state of the movie object in 
        % human readable form.

            s = m.fullfilename;
            s = strvcat(s, sprintf('%d x %d @ %d fps; %d frames, %g sec', m.width, m.height, m.rate,  m.nframes, m.totalDuration));
            s = strvcat(s, sprintf('cur frame %d/%d (skip=%d)', m.curFrame, m.nframes, m.skip));
        end

    end
end


function c = path2cell(s)
    remain = s;
    c = {};
    while true
        [str, remain] = strtok(remain, ':');
        if isempty(str), break; end
        c = [c str];
    end
end
