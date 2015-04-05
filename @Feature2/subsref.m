function out = subsref(this, index)

    index

    i = 1;

    while i <= numel(index)
        idx = index(i)
        switch idx.type

            case '.'
                switch idx.subs
                    case 'u'
                        this = this.feature(:,1);
                    case 'v'
                        this = this.feature(:,2);
                    case 'uv'
                        this = this.feature(:,1:2);
                    case 'descriptor'
                        this = this.descriptor;
                    otherwise
                        % see if its a defined method
                        fprintf('field %s not found\n', idx.subs);
                        if any( strcmp(idx.subs, methods(this)) )
                            if i < numel(index) && strcmp(index(i+1).type, '()')
                                this = feval(idx.subs, this, index(i+1).subs{:});
                                i = i+1;
                            else
                                this = builtin(idx.subs, this);
                            end
                        end
                end

            case '()'
                if isa(this, 'Feature2')
                    % if its a Feature2 class then extract a subscript
                    % range
                    d = this.feature(idx.subs{:},:);
                    this = Feature2(d);
                else
                    % else do builtin subscript handling
                    this = builtin('subsref', this, idx);
                end

            otherwise
                disp('bad index');
        end
        
        i = i+ 1;
    end

    out = this;
