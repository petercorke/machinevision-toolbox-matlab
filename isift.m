%ISIFT SIFT feature extractor
%
% SF = ISIFT(IM, OPTIONS) is a vector of SiftPointFeature objects
% representing scale and rotationally invariant interest points in the
% image IM.
%
% Options::
% 'nfeat',N          set the number of features to return (default Inf)
% 'suppress',R       set the suppression radius (default 0)
% 'id',V             set the image_id of all features
%-
% 'Octaves',N        set the number of octaves of the DoG scale space
% 'Levels',L         set the number of levels per octave of the DoG scale space (3)
% 'FirstOctave', N   set the index of the first octave of the DoG scale space (0)
% 'PeakThresh',N     set the peak selection threshold (0)
% 'EdgeThresh',N     set the non-edge selection threshold (10)
% 'NormThresh', N    set the minimum l2-norm of the descriptors before normalization. 
%                    Descriptors below the threshold are set to zero (-inf)
% 'Magnif',N         set the descriptor magnification factor (3)
% 'WindowSize',N     set the variance of the Gaussian window (2)
%
% See VLFeat.org for more details.
%
%
% Properties and methods::
%
% The SiftPointFeature object has many properties including:
%  u            horizontal coordinate
%  v            vertical coordinate
%  strength     feature strength
%  descriptor   feature descriptor (128x1)
%  sigma        feature scale
%  theta        feature orientation [rad]
%  image_id     a value passed as an option to ISIFT
%
% The SiftPointFeature object has many methods including:
%  plot         Plot feature position
%  plot_scale   Plot feature scale
%  distance     Descriptor distance
%  match        Match features
%  ncc          Descriptor similarity
%
% See SiftPointFeature and PointFeature classes for more details.
% 
% Notes::
% - Greyscale images only.
% - If IM is HxWxN it is considered to be an image sequence and F is a cell 
%   array with N elements, each of which is the feature vectors for the 
%   corresponding image in the sequence.
% - If VLFeat is installed uses vl_feat()
%   - at least 5x faster
%   - does not return feature strength
%   - does not sort features by strength
%   - 'nfeat' option cannot be used, adjust 'PeakThresh' to control the
%     number of features
% - Default MEX implementation by Andrea Vedaldi (2006).
%   - Features are returned in descending strength order.
% - The SIFT algorithm is covered by US Patent 6,711,293 (March 23, 2004) held
%   by the Univerity of British Columbia.
% - ISURF is a functional equivalent.
%
% Reference::
% "Distinctive image features from scale-invariant keypoints",
% David G. Lowe,
% International Journal of Computer Vision, 60, 2 (2004), pp. 91-110.
%
% See also SiftPointFeature, ISURF, ICORNER.


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

function features = isift(im, varargin)

    opt.suppress = 0;
    opt.nfeat = Inf;
    opt.id = [];

    [opt,arglist] = tb_optparse(opt, varargin);

    if iscell(im)
        % images provided as a cell array, return a cell array
        % of SIFT object vectors
        fprintf('extracting SIFT features for %d greyscale images\n', length(im));
        features = {};
        for i=1:length(im)
            sf = isift(im{i}, 'setopt', opt, 'id', i);

            features{i} = sf;
            fprintf('.');
        end
        fprintf('\n');
        return
    end

    % convert color image to greyscale
    if iscolor(im)
       im = imono(im);
    end

    if ndims(im) > 2

        % TODO sequence of color images..

        % images provided as an array, return a cell array
        % of SIFT object vectors
        if opt.verbose
            fprintf('extracting SIFT features for %d greyscale images\n', size(im,3));
        end
        features = {};
        for i=1:size(im,3)
            sf = isift(im(:,:,i), 'setopt', opt);
            for j=1:length(sf)
                sf(j).image_id_ = i;
            end
            features{i} = sf;
            fprintf('.');
        end
        if opt.verbose
            fprintf('\n');
        end
        return
    end


    % do SIFT using a static method that wraps the implementation
    [key,desc] = SiftPointFeature.sift(im, arglist{:});

    % key has 1 column per feature, the rows are: x, y, scale, theta, strength
    % desc has 1 column per feature, 128 elements

    fprintf('%d corners found (%.1f%%), ', numcols(key), ...
        numcols(key)/prod(size(im))*100);

    % sort into descending order of corner strength if provided
    if numrows(key) > 4
        [z,k] = sort(key(5,:), 'descend');
        key = key(:,k);
        desc = desc(:,k);
        n = min(opt.nfeat, numcols(key));

    else
        key = [key; NaN*ones(1, numcols(key))];
        n = numcols(key);
        if ~isinf(opt.nfeat)
            warning('cannot limit number of returned features using vl_feat');
        end
    end

    % allocate storage for the objects

    features = [];
    i = 1;
    while i<=n
        if i > numcols(key)
            break;
        end

        % enforce separation between corners
        % TODO: strategy of Brown etal. only keep if 10% greater than all within radius
        if (opt.suppress > 0) && (i>1)
            d = sqrt( ([features.v]'-key(2,i)).^2 + ([features.u]'-key(1,i)).^2 );
            if min(d) < opt.suppress
                continue;
            end
        end
        f = SiftPointFeature(key(1,i), key(2,i), key(5,i));
        f.scale_ = 1.5*4*key(3,i);
        f.theta_ = key(4,i)';
        f.descriptor_ = cast(desc(:,i), 'single');
        f.image_id_ = opt.id;

        features = [features f];
        i = i+1;
    end
    fprintf(' %d corner features saved\n', i-1);
