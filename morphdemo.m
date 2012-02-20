clf
input = ilabeltest();
input = idouble(input) * 0.5;

se = ones(3,3);
se = [0 1 0; 1 1 1; 0 1 0];

white = [1 1 1] * 0.5;
red = [1 0 0] * 0.5;
blue = [0 0 1] * 0.5;

result = ones(size(input)) * 0.5;

subplot(121);
h1 = gca;
im = icolor(input);
h1 = image(im);
set(h1, 'CDataMapping', 'direct');

subplot(122);
h2 = image(result);
colormap(gray);
set(h2, 'CDataMapping', 'scaled');
set(gca, 'CLim', [0 1]);
set(gca, 'CLimMode', 'manual');

nr_se = (numrows(se)-1)/2;
nc_se = (numcols(se)-1)/2;

for r=nr_se+1:numrows(input)-nr_se
    for c=nc_se+1:numcols(input)-nc_se
        im = icolor(input);

        win = input(r-nr_se:r+nr_se, c-nc_se:c+nc_se);

        rr = win .* se;
        if all(rr(find(se)))
            color = blue;
            result(r,c) = 1;
        else
            color = red;
            result(r,c) = 0;
        end

        for i=-nr_se:nr_se
            for j=-nc_se:nc_se
                if se(i+nr_se+1,j+nc_se+1) > 0
                    im(r+i,c+j,:) = im(r+i,c+j,:) + reshape(color, [1 1 3]);
                end
            end
        end

        set(h1, 'CData', im);

        set(h2, 'CData', result);

        pause(0.3);
        beep
    end
end
