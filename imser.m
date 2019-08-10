%IMSER Maximally stable extremal regions
%
% LABEL = IMSER(IM, OPTIONS) is a segmentation of the greyscale image IM (HxW)
% based on maximally stable extremal regions.  LABEL (HxW) is an image where 
% each element is the integer label assigned to the corresponding pixel in IM.
% The labels are consecutive integers starting at zero.
%
% [LABEL,NREG] = IMSER(IM, OPTIONS) as above but NREG is the number of regions
% found, or one plus the maximum value of LABEL.
%
% Options::
% 'dark'    looking for dark features against a light background (default)
% 'light'   looking for light features against a dark background
%
% Example::
%
%     im = iread('castle_sign2.png', 'grey', 'double');
%     [label,n] = imser(im, 'light');
%     idisp(label)
%
% Notes::
% - Is a wrapper for vl_mser, part of VLFeat (vlfeat.org), by Andrea Vedaldi
%   and Brian Fulkerson.
% - vl_mser is a MEX file.
% - Relies on ilabel, if this is not a MEX file will be slow to execute.
%
% Reference::
%
% "Robust wide-baseline stereo from maximally stable extremal regions",
% J. Matas, O. Chum, M. Urban, and T. Pajdla, 
% Image and Vision Computing,
% vol. 22, pp. 761-767, Sept. 2004.
%
% See also ITHRESH, ILABEL, IGRAPHSEG.


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

function [all,nsets,R] = imser(im, varargin)
    assert(exist('vl_mser') == 3, 'VL_FEAT is not installed');
    assert(size(im,3) == 1, 'monochrome images only');

    % process the argument list.
    %  we add two arguments 'light', 'dark' for the wrapper, the rest get
    % get passed to MSER.
    opt.invert = {'', 'dark', 'light'};
    opt.area = [];
    opt.delta = 5;
    opt.maxvariation = 0.25;
    opt.mindiversity = 0.2;

    [opt] = tb_optparse(opt, varargin);

    % add default args if none given
    switch opt.invert
        case 'dark'
            args = {'BrightOnDark', 0, 'DarkOnBright', 1 };
        case 'light'
            args = {'BrightOnDark', 1, 'DarkOnBright', 0 };
        otherwise
            args = {'BrightOnDark', 1, 'DarkOnBright', 1 };
    end
    
    if ~isempty(opt.area)
        assert(length(opt.area) == 2, 'area option must be [min max] in pixels');
        np = prod(size(im));
        args = [args, 'MinArea', opt.area(1)/np, 'MaxArea', opt.area(2)/np];
    else
        args = [args, 'MinArea', 0.0001, 'MaxArea', 0.1];
    end
    args = [args, 'MinDiversity', opt.mindiversity, 'MaxVariation', opt.maxvariation, 'Delta', opt.delta];
    
    if opt.verbose
        args = [args, 'Verbose'];
    end


    % MSER operates on a uint8 image
    if isfloat(im)
        im = iint(im);
    end

    R = vl_mser(im, args{:});
    fprintf('%d MSERs found\n', length(R)+1);

    %f1
    %idisp(im);

    all = zeros( size(im) );
    count = 1;
    for r=R'
        if r > 0
            bim = im <= im(r);
        else
            r = -r;
            bim = im >= im(r);
        end
        lim = ilabel(bim);
        mser_blob = lim == lim(r);

        %sum(mser_blob(:))

        %idisp(mser_blob)
        all(mser_blob) =  count;
        count = count + 1;
%         [row,col] = ind2sub(size(bim), r);
        %hold on
        %plot(col, row, 'g*');
        %pause(.2)
    end
    nsets = count;
