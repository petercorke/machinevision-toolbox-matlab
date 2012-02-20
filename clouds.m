function im = clouds(dim)
    fname = '/tmp/zz.ppm';

    if nargin < 1
        dim = [256 256];
    end

    system( sprintf('ppmforge -clouds -width %d -height %d 1> %s 2> /dev/null', dim(1), dim(2), fname) );

    [im,n] = imread(fname, 'PPM');
