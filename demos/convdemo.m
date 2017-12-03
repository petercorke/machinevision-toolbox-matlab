%CONVDEMO Demonstrate correlation using animation
%
% CONVHDEMO(IM, K, OPTIONS) displays an animation to show the principles
% of the image correlation.  Two windows are displayed side by side, input 
% binary image on the left and output image on the right.  
% The kernel moves over the input image and is colored red.  Pixels in
% the output image are initially all grey but change to black or white
% as the structuring element moves.
%
% OUT = CONVDEMO(IM, K, OPTIONS) as above but returns the output image.
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
% See also IMORPH, IDILATE, IERODE.

function out = convdemo(input, K, varargin)
    
    opt.delay = 0.5;
    opt.movie = [];
    opt = tb_optparse(opt, varargin);
        
    clf
  
    kcolor = [1 0 0] * 0.5;
    
    result = ones(size(input)) * NaN;
    
    % draw the 2 pixel grids: original, convolved
    subplot(121);
    
    h1 = showpixels(input, 'nolabel', 'fmt', '%.02f', 'color', 'y',  'here');
    title('Input image','FontSize', 18)
    subplot(122);
    
    showpixels(result, 'nolabel', 'fmt', '%.02f', 'color', 'y',   'here');
    title('Output image','FontSize', 18)
    
    if ~isempty(opt.movie)
        anim = Animate(opt.movie);
        anim.add();
    end
    
                
    nr_k = (numrows(K)-1)/2;
    nc_k = (numcols(K)-1)/2;
    
    % for every output pixel
    for r=nr_k+1:numrows(input)-nr_k
        for c=nc_k+1:numcols(input)-nc_k
            
            % form a color version of input image
            im = icolor(input);
            
            % cut out the area under the kernel
            win = input(r-nr_k:r+nr_k, c-nc_k:c+nc_k);
            
            % apply the kernel (assuming both are binary images)
            result(r,c) = sum(sum( win .* K ));
           
            
            % for every pixel in the input image covered by the kernel, set
            % its color to that determined above
            for i=-nr_k:nr_k
                for j=-nc_k:nc_k
                        im(r+i,c+j,:) = min(1, im(r+i,c+j,:) + reshape(kcolor, [1 1 3]));
                end
            end
            
            % update the image color data
            set(h1, 'CData', im);
            %set(h2, 'CData', result);
    showpixels(result, 'nolabel', 'fmt', '%.02f', 'color', 'y',   'here');
            title('Output image','FontSize', 18)

            
            % optionally save the frame for making a movie
            if isempty(opt.movie)
                pause(opt.delay);
            else
                anim.add();
            end
        end
    end
    
    if nargout > 0
        out = result;
    end
