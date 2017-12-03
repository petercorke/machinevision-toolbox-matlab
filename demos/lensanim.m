function lensanim
    %     draw(4)
    %     return
    res = 100;
    anim = Animate('lensanim');
    for zo=[9:-0.05:2]
        draw(zo);
        
        set(gcf,'PaperPositionMode','auto')
        %     oldscreenunits = get(gcf,'Units');
        %     oldpaperunits = get(gcf,'PaperUnits');
        %     oldpaperpos = get(gcf,'PaperPosition');
        %     set(gcf,'Units','pixels');
        %     scrpos = get(gcf,'Position');
        %     newpos = scrpos/res;
        %     set(gcf,'PaperUnits','inches',...
        %         'PaperPosition',newpos)
        drawnow
        %print('-dpng', sprintf('frame%04d.png', frame), ['-r' num2str(res)]);
        anim.add();
        %     drawnow
        %     set(gcf,'Units',oldscreenunits,...
        %         'PaperUnits',oldpaperunits,...
        %         'PaperPosition',oldpaperpos)
        
    end
    anim.close();
end

function draw(zo)
    
    f = 0.8;
    yo = 2;
    
    if nargin < 1
        zo = 4;
    end
    
    clf
    % setup the graphics
    axis equal
    axis([-10 1.5 -2 2]);
    xlabel('z');
    ylabel('y');
    
    % draw the lens
    draw_lens(0, 2);
    
    % draw focal points
    plot_circle([f 0 ], 0.05, 'fillcolor', 'k', 'edgecolor', 'k')
    plot_circle([-f 0 ], 0.05, 'fillcolor', 'k', 'edgecolor', 'k')
    
    % draw horizontal axis
    line([-10 1.5], [0 0]);
    
    % draw the lens plane
    line([0 0], [-2 2]);
    text(0, 0.2, 'lens plane',  'FontUnits', 'points', 'FontSize', 14,'Rotation', 90, 'VerticalAlignment', 'Bottom');
    
    % draw the focal plane
    
    line([f f], [-2 2], 'Color', 'k', 'LineStyle', '--');
    text(f, 0.2, 'focal plane',  'FontUnits', 'points', 'FontSize', 14,'Rotation', 90, 'VerticalAlignment', 'Bottom');
    grid
    %'FontUnits', 'points', 'FontSize', 14,    
    % now do the ray tracing
    
    % draw the object arrow
    draw_arrow(-zo, yo);
    
    % draw the image arrow
    zi = 1/(1/f - 1/zo);  % position
    h = f*yo / (zo-f);    % height
    draw_arrow(zi, -h);
    
    % draw construction lines
    line([-zo 0], [yo -h], 'Color', 'r');
    line([0 zi], [-h -h], 'Color', 'r');
    line([-zo zi], [yo -h], 'Color', 'r');  % pinhole ray
    
end

function draw_lens(x, h)
    r = 6;
    c = sqrt(r^2-h^2);
    th_max = atan(h/c);
    th = [-1:0.05:1]*th_max;
    X = c- r*cos(th);
    Y = r*sin(th);
    X = [X -X];
    Y = [Y Y(end:-1:1)];
    patch(X, Y, 'y');
end

function draw_arrow(x, h)
    t = 3;   % line thickness
    w = 0.1*h;  % head width
    l = 0.2*h;  % head height
    color = 'b';
    
    
    line([x x], [0 h-l], 'LineWidth', t+h, 'Color', color);
    X = [x x-w x+w];
    Y = [h h-l h-l];
    patch(X, Y, color, 'EdgeColor', color);
end