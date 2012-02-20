classdef Image < handle

    properties
        image
    end

    methods
        function im = Image(m)
            im.image = m;
        end

        function display(im)
            loose = strcmp( get(0, 'FormatSpacing'), 'loose');
            if loose
                disp(' ');
            end
            disp([inputname(1), ' = '])
            if loose
                disp(' ');
            end
            disp(char(im))
            if loose
                disp(' ');
            end
        end

        function disp(im)
            idisp(im.image);
        end

        % double
        % int
        % grey
        % gamma


        function s = char(im)
            s = sprintf('%d x %d', im.width, im.height);
        end
    end
end
