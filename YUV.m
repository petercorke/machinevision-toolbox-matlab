%YUV Class to read YUV4MPEG file
%
% A concrete subclass of ImageSource that returns images from a YUV4MPEG format
% uncompressed video file.
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
        
        fp

    end

    methods

        function yuv = Movie(filename, varargin)
        %YUV.YUV YUV4MPEG sequence constructor
        %   
        % Y = YUV(FILE, OPTIONS) is a YUV4MPEG object that returns frames
        % from the file FILE.
%	Open a yuv4mpeg format file.  This contains uncompressed color
%	images in 4:2:0 format, with a full resolution luminance plane
%	followed by U and V planes at half resolution both directions.
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
            yuv = yuvm@ImageSource(varargin{:});

            yuvm.curFrame = 1;
            yuv.skip = 1;
            
            yuv.fp = fopen(filename, 'r');

            hdr = fgets(yuv.fp);
            yuv.hdr = hdr;
            while length(hdr) > 1,
                [s, hdr] = strtok(hdr);
                switch s(1),
                case {'Y'}
                    if strcmp(s, 'YUV4MPEG2') == 0,
                        fclose(yuv.fp);
                        error('not a YUV4MPEG stream');
                    end
                case {'W'}
                    yuv.width = str2num(s(2:end));
                case {'H'}
                    yuv.height = str2num(s(2:end));
                otherwise
                    fprintf('found <%s>\n', s);
                end
            end
        end
        

        function paramSet(m, varargin)
            opt.skip = 1;
            
            disp(varargin)
            opt = tb_optparse(opt, varargin);
            opt
            m.skip = opt.skip;
        end
        
        % destructor
        function delete(m)
            close(yuv.fp);
        end

        function close(m)
        %Movie.close Close the image source
        %
        % M.close() closes the connection to the movie.

            delete(m.movie);
        end

        function sz = size(yuv)
            sz = [yuv.width yuv.height];
        end

        function [o1,o2,o3] = grab(m, varargin)
        %Movie.grab Acquire next frame from movie
        %
        % IM = Y.grab(OPTIONS) is the next frame from the file.
        %
        % Options::
        % 'skip',S    Skip frames, and return current+S frame
        % 'frame',F   Return frame F within the movie
        % 'rgb'       Return as an RGB image, Y image is downsized by two (default).
        % 'rgb2'      Return as an RGB image, U and V images are upsized by two.
        % 'yuv'       Return Y, U and V images.
        %
        % Notes::
        % - If no output argument given the image is displayed using IDISP.
        % - For the 'yuv' option three output arguments must be given.

            opt.skip = m.skip;
            opt.frame = [];
            opt.mode = {'rgb', 'rgb2', 'yuv'};
            
            opt = tb_optparse(opt, varargin);
            
            if isempty(opt.frame)
                m.curFrame = m.curFrame + opt.skip;
            else
                m.curFrame = opt.frame;
            end
            
            % read next frame from the file
            if m.curFrame <= m.nframes
                data = yuv.yuvread(m.movie, m.curFrame);
            else
                out = [];
                return;
            end

            % apply options specified at construction time
            Y = yuv.convert(Y);
            U = yuv.convert(U);
            V = yuv.convert(V);

            % convert to RGB if required
            switch opt.mode
            case 'rgb'
                [R,G,B] = yuv2rgb(Y,U,V);
                o1 = cat(3, R, G, B);
            case 'rgb2'
                [R,G,B] = yuv2rgb2(Y,U,V);
                o1 = cat(3, R, G, B);
            case 'yuv'
                o1 = Y;
                o2 = U;
                o3 = V;
            end
            
        end

        function s = char(m)
        %Movie.char Convert to string
        %
        % M.char() is a string representing the state of the movie object in 
        % human readable form.

            s = '';
            s = strvcat(s, sprintf('%d x %d', m.width, m.height);
            s = strvcat(s, sprintf('cur frame %d/%d (skip=%d)', m.curFrame, m.nframes, m.skip));
        end

    end % methods

    methods(Access=protected)


        %YUVREAD	Read frame from a YUV4MPEG file
        %
        %	[y,u,v] = yuvread(yuv, skip)
        %	[y,u,v, h] = yuvread(yuv, skip)
        %
        %	Returns the Y, U and V components from the specified frame of
        %	YUV file.  Optionally returns the frame header h.

        function [Y,U,V, h] = yuvread(yuv, skip)


            if nargin == 1,
                skip = 0;
            end

            while skip >= 0,
                % read and display the header
                hdr = fgets(yuv.fp);
                fprintf('header: %s', hdr);


                % read the YUV data
                [Y,count] = fread(yuv.fp, yuv.w*yuv.h, 'uchar');
                if count ~= yuv.w*yuv.h,
                    Y = [];
                    return;
                end
                [V,count] = fread(yuv.fp, yuv.w*yuv.h/4, 'uchar');
                if count ~= yuv.w*yuv.h/4,
                    Y = [];
                    return;
                end
                [U,count] = fread(yuv.fp, yuv.w*yuv.h/4, 'uchar');
                if count ~= yuv.w*yuv.h/4,
                    Y = [];
                    return;
                end

                skip = skip - 1;
            end

            Y = reshape(Y, yuv.w, yuv.h)';
            U = reshape(U, yuv.w/2, yuv.h/2)';
            V = reshape(V, yuv.w/2, yuv.h/2)';

            if nargin == 4,
                h = hdr;
            end
        end

        %YUV2RGB	Convert YUV format to RGB
        %
        %	[r,g,b] = yuvread(y, u, v)
        %	rgb = yuvread(y, u, v)
        %
        %	Returns the equivalent RGB image from YUV components.  The Y image is
        %	halved in resolution.
        function [R,G,B] = yuv2rgb(y, u, v)

            % subsample, probably should smooth first...
            y = y(1:2:end, 1:2:end);

            Cr = u - 128;
            Cb = v - 128;

            % convert to RGB
            r = (y + 1.366*Cr - 0.002*Cb);
            g = (y - 0.700*Cr - 0.334*Cb);
            b = (y - 0.006*Cr + 1.732*Cb);

            % clip the values into range [0, 255]
            r = max(0, min(r, 255));
            g = max(0, min(g, 255));
            b = max(0, min(b, 255));

            if nargout == 1,
                R(:,:,1) = r;
                R(:,:,2) = g;
                R(:,:,3) = b;
            else
                R = r;
                G = g;
                B = b;
            end
        end

        %YUV2RGB	Convert YUV format to RGB
        %
        %	[r,g,b] = yuvread2(y, u, v)
        %	rgb = yuvread(y, u, v)
        %
        %	Returns the equivalent RGB image from YUV components.  The UV images are
        %	doubled in resolution so the resulting color image is original size.
        %
        function [R,G,B] = yuv2rgb2(y, u2, v2)

            % subsample, probably should smooth first...
            u = zeros(2*size(u2));
            v = zeros(2*size(v2));

            for i=1:4,
                u(1:2:end,1:2:end) = u2;
                v(1:2:end,1:2:end) = v2;

                u(2:2:end,1:2:end) = u2;
                v(2:2:end,1:2:end) = v2;

                u(1:2:end,2:2:end) = u2;
                v(1:2:end,2:2:end) = v2;

                u(2:2:end,2:2:end) = u2;
                v(2:2:end,2:2:end) = v2;
            end

            Cr = u - 128;
            Cb = v - 128;

            % convert to RGB
            r = (y + 1.366*Cr - 0.002*Cb);
            g = (y - 0.700*Cr - 0.334*Cb);
            b = (y - 0.006*Cr + 1.732*Cb);

            % clip the values into range [0, 255]
            r = max(0, min(r, 255));
            g = max(0, min(g, 255));
            b = max(0, min(b, 255));

            if nargout == 1,
                R(:,:,1) = r;
                R(:,:,2) = g;
                R(:,:,3) = b;
            else
                R = r;
                G = g;
                B = b;
            end
        end
    end % protected methods
end
