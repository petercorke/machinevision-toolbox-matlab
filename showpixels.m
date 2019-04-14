%SHOWPIXELS Show low resolution image
%
% Displays a low resolution image in detail as a grid with colored lines
% between pixels and numeric display of pixel values at each pixel.  Useful
% for illustrating principles in teaching.
%
% Options::
% 'fmt',F          Format string (defaults to %d or %.2f depending on image type)
% 'label'          Display axis labels (default true)
% 'color',C        Text color (default 'b')
% 'fontsize',S     Font size (default 12)
% 'pixval'         Display pixel numeric values (default true)
% 'tick'           Display axis tick marks (default true)
% 'cscale',C       Color map scaling [min max] (defaults [0 1] or [0 255])
% 'uv',UV          UV={u,v} vectors of u and v coordinates
% 'highlight',V    highlight cells with values in the set V
% 'hide',V         don't display values in the set V
% 'contrast'       display text as white against dark squares
% 'infsymbol'      use the mathematical symbol for inf
% 'infstr',S       label cell with Inf value as S
% 'hlcolor',C      highlight color (default 'r')
%
% Notes::
% - This is meant for small images, say 10x10 pixels.

% TODO
% - allow arbitrary nan and inf colors

function hout = showpixels(im, varargin)
    
    assert( size(im,1)<=20 && size(im,2)<=20, 'showpixels is meant for small images');
    
    ismembernan = @(a,b) ismember(a,b) | (isnan(a) & any(isnan(b)));

    nr = size(im,1); nc = size(im,2);
    if isinteger(im)
        opt.fmt = '%d';
        opt.cscale = [0 255];
    else
        opt.fmt = '%.2f';
        opt.cscale = [0 1];
    end
    opt.label = true;
    opt.tick = true;
    opt.color = 'b';
    opt.fontsize = 12;
    opt.pixval = true;
    opt.uv = [];
    opt.highlight = [];
    opt.contrast = NaN;
    opt.hide = [];
    opt.infsymbol = false;
    opt.infstr = '';
    opt.hlcolor = 'r';
    
    [opt,args] = tb_optparse(opt, varargin);
    
    imv = im;   % use this to display values
    imc = im;   % use this to display colors/grey
    
    if ~isempty(opt.uv)
        args = ['xydata', {opt.uv}, args];
        ulab = opt.uv{1};
        vlab = opt.uv{2};
    else
        
        ulab = 1:nc;
        vlab = 1:nr;
    end
    
%     % display the image
%     if opt.nancolor
%         imc(isnan(im)) = Inf;  % all Nans -> Inf
%     end
%     if ~opt.infcolor
%         imc(isinf(im)) = 0;
%     end
    
    %idisp(imc, 'nogui', 'square', 'cscale', opt.cscale, args{:})
    hi = imagesc(imc, opt.cscale);
    
    % handle highlighted values
    alpha = ones(size(imc));
    if ~isempty(opt.highlight)
        for hl = opt.highlight
            if isnan(hl)
                alpha(isnan(im)) = 0;
            elseif isinf(hl)
                alpha(isinf(im)) = 0;
            else
                alpha(im == hl) = 0;
            end
        end
    end
    ax = gca;
    ax.Color = opt.hlcolor;
    hi.AlphaData = alpha;
    
    if ~opt.label
        xlabel('');
        ylabel('');
    end
    
    colormap(gray);
%     if opt.nancolor || opt.infcolor
%             colormap([colormap; 1 0 0]);
%     else
%         im(isnan(im)) = 0.5;  % ???
%     end

 
    %axis equal
    hold on
    
    umin = min(ulab); vmin = min(vlab);
    umax = max(ulab); vmax = max(vlab);
    
    
    % draw horizontal lines
    for row=vlab
        plot([umin-1 umax]+0.5, [row row]+0.5, '-y');
    end
    % draw vertical lines
    for col=ulab
        plot([col col]+0.5, [vmin-1 vmax]+0.5, '-y');
    end
    
    % write pixel values in the squares
    if opt.pixval
        for row=1:nr
            for col=1:nc
                val = imv(row,col);
                if ~ismembernan(val, opt.hide)
                    % value is not hidden
                    if isinf(val)
                        if opt.infsymbol
                            % display infinity symbol
                            h = text(ulab(col), vlab(row), '\bf\infty' );
                        elseif ~isempty(opt.infstr)
                            h = text(ulab(col), vlab(row), opt.infstr );
                        end
                    else
                        % display the numeric value or Inf or NaN
                        h = text(ulab(col), vlab(row), sprintf(opt.fmt, val) );
                    end
                    if isnan(opt.contrast)
                        color = opt.color;  % no contrast given
                    else
                        if ~isinf(val)
                            color = [1 1 1]*(val<=opt.contrast);
                        else
                            color = opt.color;
                        end
                    end
                    set(h, 'Color', color, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', opt.fontsize );
                end
            end
        end
    end
    
    xaxis(min(ulab)-0.5, max(ulab)+0.5)
    yaxis(min(vlab)-0.5, max(vlab)+0.5)
    if opt.tick
        set(gca, 'XTick', ulab);
        set(gca, 'YTick', vlab);
    else
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
    end
    
    if nargout > 0
        hout = findall(gca, 'type', 'image');
    end
end
