%ScalePointFeature  ScalePointCorner feature object
%
% A subclass of PointFeature for features with scale.
%
% Methods::
% plot         Plot feature position
% plot_scale   Plot feature scale
% distance     Descriptor distance
% ncc          Descriptor similarity
% uv           Return feature coordinate
% display      Display value
% char         Convert value to string
%
% Properties::
% u             horizontal coordinate
% v             vertical coordinate
% strength      feature strength
% scale         feature scale
% descriptor    feature descriptor (vector)
%
% Properties of a vector of ScalePointFeature objects are returned as a vector.
% If F is a vector (Nx1) of ScalePointFeature objects then F.u is a 2xN matrix
% with each column the corresponding point coordinate.
%
% See also PointFeature, SurfPointFeature, SiftPointFeature.


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

classdef ScalePointFeature < PointFeature

    properties
        scale_
    end % properties

    methods
        function f = ScalePointFeature(varargin)
        %ScalePointFeature.ScalePointFeature Create a scale point feature object
        %
        % F = ScalePointFeature() is a point feature object with null parameters.
        %
        % F = ScalePointFeature(U, V) is a point feature object with specified
        % coordinates.
        %
        % F = ScalePointFeature(U, V, STRENGTH) as above but with specified strength.
        %
        % F = ScalePointFeature(U, V, STRENGTH, SCALE) as above but with specified 
        % feature scale.
            f = f@PointFeature(varargin{:});  % invoke the superclass constructor

            if nargin > 3
                f.scale_ = varargin{4};
            end
        end

        function val = scale(features)
            val = [features.scale_];
        end


        function plot_scale(features, varargin)
        %ScalePointFeature.plot_scale Plot feature scale
        %
        % F.plot_scale(OPTIONS) overlay a marker at the feature position.
        %
        % F.plot_scale(OPTIONS, LS) as above but the optional line style arguments LS are
        % passed to plot.
        %
        % If F is a vector then each element is plotted.
        %
        % Options::
        % 'circle'    Indicate scale by a circle (default)
        % 'disk'      Indicate scale by a translucent disk
        % 'color',C   Color of circle or disk (default green)
        % 'alpha',A   Transparency of disk, 1=opaque, 0=transparent (default 0.2)

            opt.display = {'circle', 'disk'};
            opt.color = 'g';
            opt.alpha = 0.2;
            [opt,args] = tb_optparse(opt, varargin);
            
            if length(args) == 1 && isstr(args{1})
                opt.color = args{1};
                args = {};
            end
            
            holdon = ishold;
            hold on

            s = 1;

            switch (opt.display)
            case 'circle'
                plot_circle([ [features.u_]; [features.v_] ], s*[features.scale_]', ...
                'color', opt.color, args{:});
            case 'disk'
                plot_circle([ [features.u_]; [features.v_] ], s*[features.scale_]', ...
                    'fillcolor', opt.color, 'alpha', opt.alpha);
            end
            if ~holdon
                hold off
            end
        end % plot

    end % methods
end % classdef
