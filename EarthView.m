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
    end

    methods
        function ev = EarthView(key, varargin)
        %EarthView.EarthView
        %
            ev = ev@ImageSource(varargin);

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

        function im = grab(ev, varargin)
        % EarthView.grab Grab an aerial image
        %

            opt.type = {'satellite', 'map', 'hybrid'};

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
                zoom = args{3};
            end

            % now read the map
            url = sprintf('http://maps.google.com/staticmap?center=%.6f,%.6f&zoom=%d&size=%dx%d&format=png&maptype=%s&key=%s&sensor=false', lat, lon, zoom, ev.width, ev.height, opt.type, ev.key);

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
        end

        function close()
        end

        function paramSet(varargin)
        end

    end
end
