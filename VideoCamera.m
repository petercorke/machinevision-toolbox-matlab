function vid = VideoCamera(varargin)

    % this function looks like a class, the only way to implement the
    % factory design pattern

    if exist('imaqhwinfo')
        % we have the Mathworks Image Acquisition Toolbox
        if nargin == 1 && strcmp(varargin{1}, '?')
            VideoCamera_framegrabber.list();
        else
            vid = VideoCamera_framegrabber(varargin);
        end
    elseif exist('framegrabber') == 3
        % we have the MVTB framegrabber MEX interface, for either
        % MacOS, Linux or Windows
        if nargin == 1 && strcmp(varargin{1}, '?')
            VideoCamera_fg.list();
        else
            vid = VideoCamera_fg(varargin);
        end
    else
        error('no video capture capability on this computer');
    end
