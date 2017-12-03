camera = VideoCamera();

for i=1:50
    tic
    im0 = camera.grab();
    im = igamma(im0, 1/0.45);
    im = idouble(im);
    
    b = im(:,:,3) ./ sum(im, 3);
    bin = b > 0.8;
    bin = iopen(bin, eye(7,7));
    figure(2); idisp(bin);

    
    f = iblobs(bin, 'class', 1, 'area', [100 50000])
    figure(1); idisp(im0);
    if length(f) > 0
        [~,k] = max(f.area)
        f(k).plot_box('g')
        drawnow
    end
    toc
end

clear camera
