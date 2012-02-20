%SiftCornerFeature SIFT point corner feature object
%
% A subclass of PointFeature for SIFT features.
%
% Methods::
% plot         Plot feature position
% plot_scale   Plot feature scale
% distance     Descriptor distance
% match        Match features
% ncc          Descriptor similarity
% uv           Return feature coordinate
% display      Display value
% char         Convert value to string
%
% Properties::
% u             horizontal coordinate
% v             vertical coordinate
% strength      feature strength
% theta         feature orientation [rad]
% scale         feature scale
% descriptor    feature descriptor (vector)
% image_id      index of image containing feature
%
% Properties of a vector of SiftCornerFeature objects are returned as a vector.
% If F is a vector (Nx1) of SiftCornerFeature objects then F.u is a 2xN matrix
% with each column the corresponding u coordinate.
%
% Notes::
% - SiftCornerFeature is a reference object.
% - SiftCornerFeature objects can be used in vectors and arrays
% - The SIFT algorithm is patented and not distributed with this toolbox.
%   You can download a SIFT implementation which this class can utilize.
%   See README.SIFT.
%
% References::
%
% "Distinctive image features from scale-invariant keypoints",
% D.Lowe, 
% Int. Journal on Computer Vision, vol.60, pp.91-110, Nov. 2004.
%
% See also ISIFT, PointFeature, ScalePointFeature, SurfPointFeature.

classdef SiftPointFeature < ScalePointFeature

    properties
        theta_
        image_id_
    end % properties

    methods
        function f = SiftPointFeature(varargin)
        %SiftPointFeature.SiftPointFeature Create a SIFT point feature object
        %   
        % F = SiftPointFeature() is a point feature object with null parameters.
        %   
        % F = PointFeature(U, V) is a point feature object with specified
        % coordinates.
        %   
        % F = PointFeature(U, V, STRENGTH) as above but with specified strength.
        %
        % See also isift.


            f = f@ScalePointFeature(varargin{:});  % invoke the superclass constructor
        end

        function val = theta(features)
            val = [features.theta_];
        end

        function val = image_id(features)
            val = [features.image_id_];
        end

        function plot_scale(features, varargin)
        %SiftPointFeature.plot_scale Plot feature scale
        %   
        % F.plot_scale(OPTIONS) overlay a marker to indicate feature point position and
        % scale.
        %   
        % F.plot_scale(OPTIONS, LS) as above but the optional line style arguments LS are
        % passed to plot.
        %   
        % If F is a vector then each element is plotted.
        %   
        % Options::
        % 'circle'    Indicate scale by a circle (default)
        % 'clock'     Indicate scale by circle with one radial line for orientation
        % 'arrow'     Indicate scale and orientation by an arrow
        % 'disk'      Indicate scale by a translucent disk
        % 'color',C   Color of circle or disk (default green)
        % 'alpha',A   Transparency of disk, 1=opaque, 0=transparent (default 0.2)

            opt.display = {'circle', 'clock', 'arrow', 'disk'};
            opt.color = 'g';
            opt.alpha = 0.2;
            [opt,args] = tb_optparse(opt, varargin);

            holdon = ishold;
            hold on

            s = 20/sqrt(pi);    % circle of same area as 20s x 20s square support region

            switch (opt.display)
            case 'circle'
                plot_circle([ [features.u_]; [features.v_] ], s*[features.scale_]', ...
                'color', opt.color, args{:});
            case 'clock'
                plot_circle([ [features.u_]; [features.v_] ], s*[features.scale_]', ...
                'color', opt.color, args{:});
                % plot radial lines
                for f=features
                    plot([f.u_, f.u_+s*f.scale_*cos(f.theta_)], ...
                        [f.v_, f.v_+s*f.scale_*sin(f.theta_)], ...
                        'color', opt.color, args{:});
                end
            case 'disk'
                plot_circle([ [features.u_]; [features.v_] ], s*[features.scale_]', ...
                        'fillcolor', opt.color, 'alpha', opt.alpha);
            case 'arrow'
                for f=features
                    quiver(f.u_, f.v_, s*f.scale_.*cos(f.theta_), ...
                            s*f.scale_.*sin(f.theta_), ...
                            'color', opt.color, args{:});
                end
            end
            if ~holdon
                hold off
            end
        end % plot

        function [m,corresp] = match(f1, f2)
        %SiftPointFeature.match Match SIFT point features
        %   
        % M = F.match(F2, OPTIONS) is a vector of FeatureMatch objects that 
        % describe candidate matches between the two vectors of SIFT 
        % features F and F2.  Correspondence is based on descriptor
        % similarity.

        %
        % [M,C] = F.match(F2, OPTIONS) as above but returns a correspodence
        % matrix where each row contains the indices of corresponding features
        % in F and F2  respectively.
        %
        % See also FeatureMatch.

        % TODO
        % Options::
        % 'thresh',T    Match threshold (default 0.05)
        % 'median'      Threshold at the median distance
        % ambiguity threshold, defaults to 1.5 in siftmatch
        % use distance
        %

            [matches,dist] = siftmatch([f1.descriptor], [f2.descriptor]);

            % matches is a 2xM matrix, one column per match, each column is the index of the
            % matching features in image 1 and 2 respectively
            % dist is a 1xM matrix of distance between the matched features, low is good.

            % sort into increasing distance
            [z,k] = sort(dist, 'ascend');
            matches = matches(:,k);
            dist = dist(:,k);

            m = [];
            cor = [];

            for i=1:numcols(matches),
                k1 = matches(1,i);
                k2 = matches(2,i);
                mm = FeatureMatch(f1(k1), f2(k2), dist(i));
                m = [m mm];
                cor(:,i) = [k1 k2]';
            end            

            if nargout > 1
                corresp = cor;
            end
        end


    end % methods

    methods(Static)

        % the MEX functions live in a private subdirectory, so these static methods
        % provide convenient access to them

        function [k,d] = sift(varargin)
            [k,d] = sift(varargin{:});
        end
    end

end % classdef
