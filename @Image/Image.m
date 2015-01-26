classdef Image < handle

    properties
        w
        h
        np
        ns
        image
        history
    end

    methods
        function im = Image(m)
            im.image = m;
            im.history = '';

            im.h = size(m, 1);
            im.w = size(m, 2);
            im.np = 1;
            im.ns = 1;
            if ndims(m) == 3
                if size(m, 3) == 3
                    m.np = 3;
                else
                    m.ns = size(m, 3);
                end
            elseif ndims(m) == 4
                m.np = size(m, 3);
                m.ns = size(m, 4);
            end
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
            %idisp(im.image);
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

        % double
        % int
        % grey
        % gamma


        function s = char(im)
            s = sprintf('%d x %d', im.w, im.h);
            if m.np > 1
                s = [s sprintf(': %d planes')];
            end
            if m.ns > 1
                s = [s sprintf(': %d frames')];
            end
        end
    end
end
