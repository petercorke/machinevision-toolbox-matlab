%IANIMATE Display an image sequence
%
% IANIMATE(IM, OPTIONS) displays a greyscale image sequence IM (HxWxN)
% where N is the number of frames in the sequence.
%
% IANIMATE(IM, FEATURES, OPTIONS) displays a greyscale image sequence IM with
% point features overlaid.  FEATURES (Nx1) cell array whose elements are
% vectors of feature objects.  The feature is plotted using the object's plot
% method and additional options are passed through to that method.
%
% Examples::
%
% Animate image sequence:
%     ianimate(seq);
%
% Animate image sequence with overlaid corner features:
%     c = icorner(im, 'nfeat', 200);  % computer corners
%     ianimate(seq, features, 'gs');  % features shown as green squares
%
% Options::
%  'fps',F       set the frame rate (default 5 frames/sec)
%  'loop'        endlessly loop over the sequence
%  'movie',M     save the animation as a series of PNG frames in the folder M
%  'npoints',N   plot no more than N features per frame (default 100)
%  'only',I      display only the I'th frame from the sequence
%
% See also PointFeature, IHARRIS, ISURF, IDISP.


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

% TODO should work with color image sequence, dims are: row col plane seq

function ianimate(im, varargin)

    points = [];
    opt.fps = 5;
    opt.loop = false;
    opt.npoints = 100;
    opt.only = [];
    opt.movie = [];

    [opt, arglist]  = tb_optparse(opt, varargin);

    if length(arglist) >= 1 && iscell(arglist(1))
        points = arglist{1};
        arglist = arglist(2:end);
    end
    
    clf
    pause on
    colormap(gray(256));
    
    if ~isempty(opt.movie)
        mkdir(opt.movie);
        framenum = 1;
    end

    while true
        for i=1:size(im,3)
            if opt.only ~= i
                continue;
            end
            image(im(:,:,i), 'CDataMapping', 'Scaled');
            if ~isempty(points)
                f = points{i};
                n = min(opt.npoints, length(f));
                f(1:n).plot(arglist{:});
            end
            title( sprintf('frame %d', i) );

            if opt.only == i
                return;
            end
            if isempty(opt.movie)
                            pause(1/opt.fps);
            else
                f = getframe;
                imwrite(f.cdata, sprintf('%s/%04d.png', opt.movie, framenum));
                framenum = framenum+1;
            
            end
        end

        if ~opt.loop
            break;
        end
   end
