%EarthView
%
% Maximum size is 640x640 for free access, business users can get more.
%
% Examples::
%
%  Show aerial view of Brisbane, Australia at zoom scale 11.
%
%          ev = EarthView();
%          ev.grab(-27,153, 11);
%          ev.grab('brisbane', 14)
%          ev.grab('brisbane', 14, 'map')
%
% Notes::
% - A key is required before you can use the Google Static Maps API.  The key is a long string that can
%   be passed to the constructor or saved as an environment variable GOOGLE_KEY.  You need a Google account
%   before you can register for a key.
% - Google limit the number of map queries limit to 1000 unique (different) image requests per viewer per day.
%   A 403 error is returned if the daily quota is exceeded.
% - There are lots of conditions on what you can do with the images, particularly with respect to publication.
%   See the Google web site for details.
%
% Author::
%  Peter Corke, with some lines of code from from get_google_map by Val
%  Schmidt.
%
% See also ImageSource.

classdef EarthView < ImageSource

% e = EarthView() is an object that returns images of the Earth's surface
% obtained from Google Maps.
%
% e = EarthView(googlekey) as above but the google key string is passed in.
%
% e.grab(lat, lon, zoom, options)

    properties
        key
        type
        scale
    end

    methods
        function ev = EarthView(key, varargin)
        %EarthView.EarthView
        %
        
        %TODO
        %  clone this for new StreetView API
        %  method to return lat/long or NE matrices corresp to pixels
        
            ev = ev@ImageSource(varargin);
            
            opt.type = {'satellite', 'map', 'hybrid'};
            opt.scale = 18;
            
            [opt,args] = tb_optparse(opt, varargin);
            
            ev.type = opt.type;
            ev.scale = 1;
          

            % set default size params if not set
            if isempty(ev.width)
                ev.width = 640;
                ev.height = 640;
            end

            if nargin == 0
                ev.key = getenv('GOOGLE_KEY');
            else
                ev.key = key;
            end
            
        end

        function [im,E,N] = grab(ev, varargin)
        % EarthView.grab Grab an aerial image
        %
        % im = EarthView.grab(lat, long, OPTIONS) is an image of the Earth
        % centred at the geographic coordinate (lat, long).
        %
        % im = EarthView.grab(lat, long, zoom, OPTIONS) as above with the specified
        % zoom.
        %
        % [im,E,N] = EarthView.grab(lat, long, OPTIONS) as above but also
        % returns the estimated easting E and northing N for the corresponding pixels 
        % in im. 
        %
        % Notes::
        % - If northing/easting outputs are requested the function
        %   deg2utm is required (from MATLAB Central)
        % - The easting/northing is somewhat approximate, see
        %   get_google_map on MATLAB Central.

            opt.type = {'satellite', 'map', 'hybrid'};
            opt.scale = ev.scale;

            [opt,args] = tb_optparse(opt, varargin);

            % build the URL
            if ischar(args{1})
                % given a string name, do a geocode lookup
                place = args{1};
                zoom = args{2};

                % build the URL, and load the XML document
                url = sprintf('http://maps.googleapis.com/maps/api/geocode/xml?address=%s&sensor=false', place);
                doc = xmlread(url);

                % walk the XML document
                locations = doc.getElementsByTagName('location')

                if locations.getLength > 1
                    fprintf('%d places called %s found\n', locations.getLength, place);
                end

                location = locations.item(0);   % take the first return

                node_lat = location.getElementsByTagName('lat');
                el = node_lat.item(0);
                lat = str2num( el.getFirstChild.getData );

                node_lon = location.getElementsByTagName('lng');
                el = node_lon.item(0);
                lon = str2num( el.getFirstChild.getData );
            else
                lat = args{1};
                lon = args{2};
                if length(args) == 3
                    zoom = args{3};
                else
                    zoom = 18;
                end
                
            end
            % now read the map
            url = sprintf('http://maps.google.com/staticmap?center=%.6f,%.6f&zoom=%d&size=%dx%d&scale=%d&format=png&maptype=%s&key=%s&sensor=false', lat, lon, zoom, ev.width, ev.height, opt.scale, opt.type, ev.key);

            [idx,cmap] = imread(url, 'png');
            cmap = iint(cmap);

            % apply the color map
            view = cmap(idx(:)+1,:);

            % knock it into shape
            view = shiftdim( reshape(view', [3 size(idx)]), 1);
            view = ev.convert(view);

            if nargout == 0
                idisp(view);
            else
                im = view;
            end
            
            if nargout > 1
                % compute the northing/easting at each pixel.
                %
                % the following lines of code from get_google_map by Val Schmidt 
                % ESTIMATE BOUNDS OF IMAGE:
                %
                % Normally one must specify a center (lat,lon) and zoom level for a map.
                % Zoom Notes:
                % ZL: 15, hxw = 640x640, image dim: 2224.91 x 2224.21 (mean 2224.56)
                % ZL: 16, hxw = 640x640, image dim: 1128.01m x 1111.25m (mean 1119.63)
                % This gives an equation of roughly (ZL-15)*3.4759 m/pix * pixels
                % So for an image at ZL 16, the LHS bound is 
                % LHS = centerlonineastings - (zl-15) * 3.4759 * 640/2;
                [lonutm latutm zone] = deg2utm(lat,lon);
                Hdim = (2^15/2^zoom) * 3.4759 * ev.width;
                Vdim = (2^15/2^zoom) * 3.4759 * ev.height;

                ell = lonutm - Hdim/2;
                nll = latutm - Vdim/2;
                eur = lonutm + Hdim/2;
                nur = latutm + Vdim/2;

                Nvec = linspace(nur,nll,ev.height); % lat is highest at image row 1
                Evec = linspace(ell,eur,ev.width);
                [E,N] = meshgrid(Evec, Nvec);
            end
        end

        function close()
        end

        function paramSet(varargin)
        end

    end
end
