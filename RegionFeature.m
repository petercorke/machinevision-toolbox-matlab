%RegionFeature Region feature class
%
% This class represents a region feature.
%
% Methods::
% boundary        Return the boundary as a list
% box             Return the bounding box
% plot            Plot the centroid
% plot_boundary   Plot the boundary
% plot_box        Plot the bounding box
% plot_ellipse    Plot the equivalent ellipse
% display         Display value
% char            Convert value to string
% pick            Return the index of the blob that is clicked
%
% Properties::
%  uc*            centroid, horizontal coordinate
%  vc*            centroid, vertical coordinate
%  p              centroid (uc, vc)
%  umin           bounding box, minimum horizontal coordinate
%  umax           bounding box, maximum horizontal coordinate
%  vmin           bounding box, minimum vertical coordinate
%  vmax           bounding box, maximum vertical coordinate
%  area*          the number of pixels
%  class*         the value of the pixels forming this region
%  label*         the label assigned to this region
%  children       a list of indices of features that are children of this feature
%  edgepoint      coordinate of a point on the perimeter
%  edge           a list of edge points 2xN matrix
%  perimeter*     edge length (pixels)
%  touch*         true if region touches edge of the image
%  a              major axis length of equivalent ellipse
%  b              minor axis length of equivalent ellipse
%  theta*         angle of major ellipse axis to horizontal axis
%  aspect*        aspect ratio b/a (always <= 1.0)
%  circularity*   1 for a circle, less for other shapes
%  moments        a structure containing moments of order 0 to 2
%  bbox*          the bounding box, 2x2 matrix [umin umax; vmin vmax]
%  bboxarea*      bounding box area
% Note::
%  - Properties indicated with a * can be determined for a vector of RegionFeatures
%    and the result will be a vector of those properties (not a list) with elements
%    corresponding to the original vector of RegionFeatures.
%  - RegionFeature is a reference object.
%  - RegionFeature objects can be used in vectors and arrays
%  - This class behaves differently to LineFeature and PointFeature when
%    getting properties of a vector of RegionFeature objects.  For example
%    R.u_ will be a list not a vector.
%    
% See also IBLOBS, IMOMENTS.

% TODO:
% make property of object vector like Line/PointFeature


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
classdef RegionFeature < handle
    properties
        area_
        uc_          % centroid
        vc_
        
        umin_        % the bounding box
        umax_
        vmin_
        vmax_

        class_       % the class of the pixel in the original image
        label_       % the label assigned to this region
        parent      % the label of this region's parent
        children    % a list of features that are children of this feature
        edgepoint   % (x,y) of a point on the perimeter
        edge        % list of edge points
        perimeter_   % length of edge
        touch_       % 0 if it doesnt touch the edge, 1 if it does

        % equivalent ellipse parameters
        a_           % the major axis length
        b_           % the minor axis length  b<a
        theta_       % angle of major axis with respect to horizontal
        aspect_      % b/a  < 1.0
        circularity_

        moments     % moments, a struct of: m00, m01, m10, m02, m20, m11

    end

    properties (Dependent=true)
        bbox_       % bounding box
        bboxarea_   % bounding box area
    end

    methods

        function b = RegionFeature(b)
        %RegionFeature.RegionFeature Create a region feature object
        %
        % R = RegionFeature() is a region feature object with null parameters.

            b.area_ = [];
            b.label_ = [];
            b.edge = [];
        end

        function display(b)
        %RegionFeature.display Display value
        %
        % R.display() is a compact string representation of the region feature.
        % If R is a vector then the elements are printed one per line.
        %
        % Notes::
        % - this method is invoked implicitly at the command line when the result
        %   of an expression is a RegionFeature object and the command has no trailing
        %   semicolon.
        %
        % See also RegionFeature.char.


            loose = strcmp( get(0, 'FormatSpacing'), 'loose');
            if loose
                disp(' ');
            end
            disp([inputname(1), ' = '])
            if loose
                disp(' ');
            end
            disp(char(b))
            if loose
                disp(' ');
            end
        end

        function ss = char(b)
        %RegionFeature.char Convert to string
        %
        % S = R.char() is a compact string representation of the region feature.
        % If R is a vector then the string has multiple lines, one per element.

            ss = '';
            for i=1:length(b)
                bi = b(i);
                if isempty(bi.area_)
                    s = '[]';
                elseif isempty(bi.label)
                    s = sprintf('area=%d, cent=(%.1f,%.1f), theta=%.2f, b/a=%.3f', ...
                        bi.area_, bi.uc_, bi.vc_, bi.theta_, bi.aspect_);
                elseif ~isempty(bi.edge)
                    s = sprintf('(%d) area=%d, cent=(%.1f,%.1f), theta=%.2f, b/a=%.3f, class=%d, label=%d, touch=%d, parent=%d, perim=%.1f, circ=%.3f', ... 
                        i, bi.area_, bi.uc_, bi.vc_, bi.theta_, bi.aspect_, bi.class_, bi.label_, ...
                        bi.touch_, bi.parent, bi.perimeter_, bi.circularity_);
                else
                    s = sprintf('(%d) area=%d, cent=(%.1f,%.1f), theta=%.2f, b/a=%.3f, color=%d, label=%d, touch=%d, parent=%d', ... 
                        i, bi.area_, bi.uc_, bi.vc_, bi.theta_, bi.aspect_, bi.class_, bi.label_, ...
                        bi.touch_, bi.parent);
                end
                ss = strvcat(ss, s);
            end
        end

        function b = box(bb)
        %RegionFeature.box Return bounding box
        %
        % B = R.box() is the bounding box in standard Toolbox form [xmin,xmax; ymin, ymax].
            b = [bb.umin_ bb.umax_; bb.vmin_ bb.vmax_];
        end

        function plot_boundary(bb, varargin)
        %RegionFeature.plot_boundary Plot boundary
        %
        % R.plot_boundary() overlay perimeter points on current plot.
        %
        % R.plot_boundary(LS) as above but the optional line style arguments LS are
        % passed to plot.
        %
        % Notes::
        % - If R is a vector then each element is plotted.
        %
        % See also BOUNDMATCH.

            holdon = ishold;
            hold on
            for b=bb
                if isempty(b.edge)
                    error('edge has not been computed for this blob');
                end
                plot(b.edge(1,:), b.edge(2,:), varargin{:});
            end
            if ~holdon
                hold off
            end
        end

        function plot(bb, varargin)
        %RegionFeature.plot Plot centroid
        %
        % R.plot() overlay the centroid on current plot.  It is indicated with 
        % overlaid o- and x-markers.
        %
        % R.plot(LS) as above but the optional line style arguments LS are
        % passed to plot.
        %
        % If R is a vector then each element is plotted.
            holdon = ishold;
            hold on
            for b=bb
                %% TODO: mark with x and o, dont use markfeatures
                %markfeatures([b.uc_ b.uc_], 0, varargin{:});
                if isempty(varargin)
                    plot(b.uc_, b.vc_, 'go');
                    plot(b.uc_, b.vc_, 'gx');
                else
                    plot(b.uc_, b.vc_, varargin{:})
                end

            end
            if ~holdon
                hold off
            end
        end

        function plot_box(bb, varargin)
        %RegionFeature.plot_box Plot bounding box
        %
        % R.plot_box() overlay the the bounding box of the region on current plot.
        %
        % R.plot_box(LS) as above but the optional line style arguments LS are
        % passed to plot.
        %
        % If R is a vector then each element is plotted.
            for b=bb
                plot_box(b.umin_, b.vmin_, b.umax_, b.vmax_, varargin{:});
            end
        end

        function plot_ellipse(bb, varargin)
        %RegionFeature.plot_ellipse Plot equivalent ellipse
        %
        % R.plot_ellipse() overlay the the equivalent ellipse of the region on current plot.
        %
        % R.plot_ellipse(LS) as above but the optional line style arguments LS are
        % passed to plot.
        %
        % If R is a vector then each element is plotted.
            for b=bb
                J = [b.moments.u20 b.moments.u11; b.moments.u11 b.moments.u02];
                plot_ellipse(4*J/b.moments.m00, [b.uc_, b.vc_], varargin{:});
            end
        end
        
        function plot_centroid(bb, ls)
            
            if nargin == 1
            
            plot_point(bb.p,'ko'); plot_point(bb.p, 'kx');
            else
                plot_point(bb.p, ls);
            end
        end
        
        function t = contains(f, coord)
        %RegionFeature.contains Test if coordinate is contained within region bounding box
        %
        % R.contains(coord) true if the coordinate COORD lies within the bounding box
        % of the region feature R.  If R is a vector, return a vector of logical
        % values, one per input region.
        %
            u = coord(1);
            v = coord(2);
            t = zeros(1,length(f));
            for i=1:length(f)
                box = f(i).bbox_();

                t(i) = u>= box(1,1) && u<=box(1,2) && v>=box(2,1) && v<=box(2,2);
            end
        end
        
        function sel = pick(f)
        %RegionFeature.pick Select blob from mouse click
        %
        % I = R.pick() is the index of the region feature within the vector of
        % RegionFeatures R to which the clicked point corresponds.  Since regions
        % can overlap of be contained in other regions, the region with the
        % smallest area of bounding box that contains the selected point is
        % returned.
        %
        % See also GINPUT, RegionFeature.inbox.
        
        [u,v] = ginput(1);
            
            ind = [];
            areas = [];
            for i=1:length(f)
                blob = f(i);
                if blob.contains([u,v])
                    ind = [ind i];
                    areas = [areas blob.bboxarea];
                end
            end
            [~,k] = min(areas);
            sel = ind(k);
        end
        
        function [ri,thi] = boundary(fv, varargin)
        %RegionFeature.boundary Boundary in polar form
        %
        % [D,TH] = R.boundary() is a polar representation of the boundary with
        % respect to the centroid.  D(i) and TH(i) are the distance to the boundary
        % point and the angle respectively.  These vectors have 400 elements
        % irrespective of region size.
            ri = []; thi = [];
            assert(~isempty(fv(1).edge), 'No edge points -- use the ''boundary'' option');
            
            for f = fv
                dxy = bsxfun(@minus, f.edge, [f.uc_ f.vc_]');

                r = colnorm(dxy)';
                th = -atan2(dxy(2,:), dxy(1,:));

                s = linspace(1, length(r), 400)';
                ri = [ri interp1(1:length(r), r, s, 'spline')];
                if nargout > 1
                thi = [thi interp1(1:length(th), th, s, 'spline')];
                end
            end
        end

        function bb = get.bbox_(f)
            bb = [f.umin_ f.umax_; f.vmin_ f.vmax_];
        end
        
        function a = get.bboxarea_(f)
            a = (f.umax_-f.umin_)*(f.vmax_-f.vmin_);
        end

        % methods to provide convenient access to properties of object vectors
        function val = uc(f)
            val = [f.uc_];
        end

        function val = vc(f)
            val = [f.vc_];
        end

        function val = umin(f)
            val = [f.umin_];
        end

        function val = vmin(f)
            val = [f.vmin_];
        end

        function val = umax(f)
            val = [f.umax_];
        end

        function val = vmax(f)
            val = [f.vmax_];
        end

        function val = a(f)
            val = [f.a_];
        end

        function val = b(f)
            val = [f.b_];
        end

        function val = p(f)
            val = [[f.uc_]; [f.vc_]];
        end
        
        function val = theta(f)
            val = [f.theta_];
        end
        
        function val = class(f)
            val = [f.class_];
        end

        function val = label(f)
            val = [f.label_];
        end

        function val = touch(f)
            val = [f.touch_];
        end

        function val = aspect(f)
            val = [f.aspect_];
        end
        
        function val = area(f)
            val = [f.area_];
        end
        
        function val = circularity(f)
            val = [f.circularity_];
        end

        function val = perimeter(f)
            val = [f.perimeter_];
        end

        function val = bboxarea(f)
            val = [f.bboxarea_];
        end
        
        function val = bbox(f)
            val = [f.bbox_];
        end
    end
    
    methods(Static = true)
        %BOUNDMATCH Match boundary profiles
%
% X = BOUNDMATCH(R1, R2) is the correlation of the two boundary profiles
% R1 and R2.  Each is an Nx1 vector of distances from the centroid of
% an object to points on its perimeter at equal angular increments spanning
% 2pi radians.  X is also Nx1 and is a correlation whose peak indicates the 
% relative orientation of one profile with respect to the other.
%
% [X,S] = BOUNDMATCH(R1, R2) as above but also returns the relative scale
% S which is the size of object 2 with respect to object 1.
%
% Notes::
% - Can be considered as matching two functions defined over S(1).
%
% See also RegionFeature.boundary, XCORR.


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
function [s,kk] = boundmatch(r1, r2, varargin)

    assert(numrows(r1) == numrows(r2), 'r1 and r2 must have same number of rows');
    
    opt.normalize = true;
    opt = tb_optparse(opt, varargin);
    if opt.normalize
        r1 = r1/sum(r1);
        r2 = bsxfun(@times, r2, 1./sum(r2));
    end
    r1 = r1 - mean(r1);
    r2 = bsxfun(@minus, r2, mean(r2));
    
    ss1 = sum(r1.^2);

    
    for i=1:numcols(r2)
        r = r2(:,i);
            ss2 = sum(r.^2);
            denom = sqrt(ss1 * ss2);
                  z = zeros(size(r1));
  
        for j=1:length(r1)
            rs = circshift(r, j-1);
            z(j) = (r1' * rs) / denom;
        end
        
        [s(i),idx(i)] = max(z);
    end
    if nargout > 1
        kk = idx;
    end
end
    end
end
