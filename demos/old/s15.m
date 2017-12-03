im = iread('flowers8.png');

figure(1); idisp(im);
figure(2); idisp(im(:,:,1));
idisp(im(:,:,2));
idisp(im(:,:,3));

im(100,200,1)
im(100,200,:)
squeeze( im(100,200,:) )

colorname('maroon')
colorname([1 0.41 0.71])
