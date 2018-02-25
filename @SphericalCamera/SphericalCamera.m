%SphericalCamera  Spherical camera class
%
% A concrete class a spherical-projection camera.
%
% Methods::
%
% project          project world points
%
% plot             plot/return world point on image plane
% hold             control hold for image plane
% ishold           test figure hold for image plane
% clf              clear image plane
% figure           figure holding the image plane
% mesh             draw shape represented as a mesh
% point            draw homogeneous points on image plane
% line             draw homogeneous lines on image plane
% plot_camera      draw camera
%
% rpy              set camera attitude
% move             copy of Camera after motion
% centre           get world coordinate of camera centre
%
% delete           object destructor
% char             convert camera parameters to string
% display          display camera parameters
%
% Properties (read/write)::
% npix         image dimensions in pixels (2x1)
% pp           intrinsic: principal point (2x1)
% rho          intrinsic: pixel dimensions (2x1) in metres
% T            extrinsic: camera pose as homogeneous transformation
%
% Properties (read only)::
% nu    number of pixels in u-direction
% nv    number of pixels in v-direction
%
% Note::
%  - SphericalCamera is a reference object.
%  - SphericalCamera objects can be used in vectors and arrays
%
% See also Camera.




% Copyright (C) 1993-2017, by Peter I. Corke
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
%
% http://www.petercorke.com

classdef SphericalCamera < Camera
    
    properties
    end
    
    properties (SetAccess = private)
    end
    
    properties (GetAccess = private, SetAccess = private)
        
    end
    
    properties (GetAccess = private)
    end
    
    properties (Dependent = true, SetAccess = private)
    end
    
    %TODO
    % pixel noise
    % image paint and rotate
    % Tcam and Tobj animation handle this in the superclass project function
    
    methods
        
        function c = SphericalCamera(varargin)
            %SphericalCamera.Spherical Create spherical projection camera object
            %
            % C = SphericalCamera() creates a spherical projection camera with canonic
            % parameters: f=1 and name='canonic'.
            %
            % C = CentralCamera(OPTIONS) as above but with specified parameters.
            %
            % Options::
            % 'name',N                  Name of camera
            % 'pixel',S                 Pixel size: SxS or S(1)xS(2)
            % 'pose',T                  Pose of the camera as a homogeneous
            %                           transformation
            %
            % See also Camera, CentralCamera, FisheyeCamera, CatadioptricCamera.
            
            % invoke the superclass constructor
            c = c@Camera(varargin{:});
            c.type = 'Spherical';
            c.limits = [-pi pi 0 pi];
            
            if nargin == 0
                % default values
                c.type = 'spherical';
                c.name = 'spherical-default';
            end
            
            % process remaining options
            opt.default = false;
            
            [opt,args] = tb_optparse(opt, varargin);
            if opt.default
                c.name = 'default';
                n = 0;
            end
        end
        
        function s = char(c)
            
            s = sprintf('name: %s [%s]', c.name, c.type);
            s = strvcat(s, char@Camera(c) );
        end
        
        % return field-of-view angle for x and y direction (rad)
        function th = fov(c)
            th = 2*pi;
        end
        
        % override the superclass method
        function labelaxes(c)
            h = c.h_imageplane;
            xlabel(h, 'Longitude \phi (rad)');
            ylabel(h, 'Colatitude \theta (rad)');
            % would be nice to make this square
        end
        
        function f = project(cam, P, varargin)
            %SphericalCamera.project Project world points to image plane
            %
            % PT = C.project(P, OPTIONS) are the image plane coordinates for the world
            % points P.  The columns of P (3xN) are the world points and the columns
            % of PT (2xN) are the corresponding spherical projection points, each column
            % is phi (longitude) and theta (colatitude).
            %
            % Options::
            % 'pose',T         Set the camera pose to the pose T (homogeneous transformation (4x4) or SE3)
            %                  before projecting points to the camera image plane.  Temporarily overrides
            %                  the current camera pose C.T.
            % 'objpose',T      Transform all points by the pose T (homogeneous transformation (4x4) or SE3)
            %                  before projecting them to the camera image plane.
            %
            % See also SphericalCamera.plot.
            
            
            opt.objpose = [];
            opt.pose = [];
            
            [opt,arglist] = tb_optparse(opt, varargin);
            
            if isempty(opt.pose)
                opt.pose = cam.T;
            end
            % transform the object
            if isempty(opt.objpose)
                opt.objpose = SE3();
            else
                opt.objpose = SE3.check(opt.objpose);
            end
            
            P = inv(opt.pose) * opt.objpose * P;         % project them
            
            R = sqrt( sum(P.^2) );
            x = P(1,:) ./ R;
            y = P(2,:) ./ R;
            z = P(3,:) ./ R;
            r = sqrt( x.^2 + y.^2);
            %theta = atan2(r, z);
            theta = acos(P(3,:)./R);
            phi = atan2(y, x);
            f = [phi; theta];
        end
        
        
    end % methods
end % class
