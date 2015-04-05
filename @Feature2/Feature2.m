classdef Feature2 < handle

    properties
        feature
        descriptor
    end

    methods
        function f = Feature2(ff, dd)
            if nargin == 0
                f.feature = rand(100, 3);
                f.descriptor = rand(100, 20);
            elseif nargin == 1
                f.feature =ff;
                f.descriptor = [];
            elseif nargin == 2
                f.feature =ff;
                f.descriptor = dd;
            end
        end

        function s = char(f)
            s = '';
            for i=1:numrows(f.feature)
                s = char(s, sprintf('%f %f', f.feature(i,1:2)));
            end
        end

        function display(f)
            disp( f.char() );
        end

        function z = bob(f, a,b,c)
            fprintf('nargin=%d, a=%f\n', nargin, a);
            z = a;
        end
        
        function out = end(f,k,n)
            k,n
            %out = end(A.feature,k,n);
            if k == 1
                out = numrows(f.feature);
            else
                out = 1;
            end
        end

        function s = size(f)
            s = [numrows(f.feature) 1];
        end

        function n = length(f)
            n = numrows(f.feature);
        end
        %{
        function n = numel(f)
            n = numrows(f.feature);
        end
        %}
    end % methods
end % classdef
