%MORPHDEMO Demonstrate morphology using animation
%
% MORPHDEMO(IM, SE, OPTIONS) displays an animation to show the principles
% of the mathematical morphology operations dilation or erosion.  Two
% windows are displayed side by side, input binary image on the left and
% output image on the right.  The structuring element moves over the input
% image and is colored red if the result is zero, else blue.  Pixels in
% the output image are initially all grey but change to black or white
% as the structuring element moves.
%
% OUT = MORPHDEMO(IM, SE, OPTIONS) as above but returns the output image.
%
% Options::
% 'dilate'      Perform morphological dilation
% 'erode'       Perform morphological erosion
% 'delay'       Time between animation frames (default 0.5s)
% 'scale',S     Scale factor for output image (default 64)
% 'movie',M     Write image frames to the folder M
%
% Notes::
% - This is meant for small images, say 10x10 pixels.
%
% See also SHOWPIXELS, IMORPH, IDILATE, IERODE.

function out = morphdemo(input, se, varargin)
    
    opt.op = {'', 'erode', 'dilate'};
    opt.delay = 0.5;
    opt.movie = [];
    opt = tb_optparse(opt, varargin);

    input = idouble(input) * 0.8;
    
    clf
    
    red = [1 0 0] * 0.5;
    blue = [0 0 1] * 0.5;
    
    result = ones(size(input)) * 0.5;
    
    % draw the 2 pixel grids: original, morphologically transformed
    subplot(121);
    h1 = showpixels(input, 'nopixval', 'nolabel',   'here');
    title('Input image','FontSize', 18)
    
    subplot(122);
    h2 = showpixels(result, 'nopixval', 'nolabel',   'here');
    title('Output image','FontSize', 18)
    
    
    if ~isempty(opt.movie)
        anim = Animate(opt.movie);
        anim.add();
    end
    
    nr_se = (numrows(se)-1)/2;
    nc_se = (numcols(se)-1)/2;
    
    % for every output pixel
    for r=nr_se+1:numrows(input)-nr_se
        for c=nc_se+1:numcols(input)-nc_se
            
            % form a color version of input image
            im = icolor(input);
            
            % cut out the area under the SE
            win = input(r-nr_se:r+nr_se, c-nc_se:c+nc_se);
            
            % apply the SE (assuming both are binary images)
            rr = win .* se;
            
            % choose SE display color and result according to the morph operation
            switch opt.op
                case 'erode'
                    if all(rr(find(se)))
                        color = blue;
                        result(r,c) = 1;
                    else
                        color = red;
                        result(r,c) = 0;
                    end
                case 'dilate'
                    if any(rr(find(se)))
                        color = blue;
                        result(r,c) = 1;
                    else
                        color = red;
                        result(r,c) = 0;
                    end
                otherwise
                    error('Unknown operator %s', opt.op);
            end
            
            % for every pixel in the input image covered by the SE, set
            % its color to that determined above
            for i=-nr_se:nr_se
                for j=-nc_se:nc_se
                    if se(i+nr_se+1,j+nc_se+1) > 0
                        im(r+i,c+j,:) = min(1, im(r+i,c+j,:) + reshape(color, [1 1 3]));
                    end
                end
            end
            
            % update the image color data
            set(h1, 'CData', im);
            set(h2, 'CData', result);
            
            % optionally save the frame for making a movie
            if isempty(opt.movie)
                pause(opt.delay);
            else
                anim.add();
            end
        end
    end
    
    if nargout > 0
        out = result > 0.6;
    end
