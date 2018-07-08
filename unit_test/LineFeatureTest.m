function tests = LineFeatureTest
    tests = functiontests(localfunctions)
    clc
end

function setupOnce(tc)
    im = testpattern('squares', 256, 256, 128);
    im = irotate(im, -0.3);
    edges = icanny(im);
    
    tc.TestData.edges = edges;
end

function teardownOnce(tc)
    close all
end

function constructor_test(tc)
    
    % create Hough object
    h = Hough(tc.TestData.edges);
    tc.verifyClass(h, 'Hough');
    
    s = char(h);
    tc.verifyClass(s, 'char');
    
    h.display;
    h.show();
end

function simple_test(tc)
    % check accumulators are correct size
    im = [0 0 0; 0 1 0; 0 0 0];
    h = Hough(im, 'nbins', [6 5]);
    tc.verifyEqual( size(h.A), [5 6]);
    
    h = Hough(im, 'nbins', 4);
    tc.verifyEqual( size(h.A), [5 4]);

    % simple example with 2 edge points
    edge = [
        0 0 0
        0 1 1
        0 0 0];
    out = [
        0     0     0     0
        2     0     0     0
        0     2     0     0
        0     0     2     1
        0     0     0     1
     ];
    h = Hough(edge, 'nbins', 4)
    tc.verifyEqual(h.A, out);

     % test vote weighting
     h = Hough(edge*2, 'nbins', 4);
     tc.verifyEqual( h.A, out*2);
     
     h = Hough(edge*2, 'nbins', 4, 'equal');
     tc.verifyEqual( h.A, out);
     
     % test xy input mode
     h = Hough([2 2; 2 3]', 'nbins', 4, 'points', [3 3]);
     tc.verifyEqual( h.A, out);
     
     % test xy input mode with weights
     h = Hough([2 2 5; 2 3 5]', 'nbins', 4, 'points', [3 3]);
     tc.verifyEqual( h.A, out*5);

     % test point, rather than image, mode
%      h=Hough([2 3; 2 2], 'points', 'nbins', 4)
%      tc.verifyEqual( h.A, out);
end

function square_test(tc)
    edges = tc.TestData.edges;

    h = Hough(edges);
    
    % create LineFeature objects
    lines = h.lines();
    tc.verifyClass(lines, 'LineFeature');
    
    tc.verifyEqual(numel(lines), 11);
    tc.verifyTrue( isempty(lines.length) );
    tc.verifyEqual( length(lines.theta), 11);
    tc.verifyEqual( length(lines.rho), 11);
    tc.verifyEqual( length(lines.strength), 11);
    
    s = char(lines);
    tc.verifyClass(s, 'char');
    tc.verifyEqual( size(s,1), 11);
    

end

function show_test(tc)
    h = Hough(tc.TestData.edges);
    
    clf
    h.show();
    a = gca;
    tc.verifyNotEmpty(a.Children);
    tc.verifyNumElements(a.Children, 1);
    tc.verifyMatches(a.Children.Type, 'image')

end

function plot_test(tc)
    h = Hough(tc.TestData.edges);
    clf
    h.plot('b');
    
    a = gca;
    tc.verifyNotEmpty(a.Children);
    tc.verifyNumElements(a.Children, 11);
    tc.verifyTrue(all( strcmp({a.Children.Type}, 'line') ) )
end



function square_suppress_test(tc)
    edges = tc.TestData.edges;
    
    % create new Hough and lines with non-local maxima suppression
    h = Hough(edges, 'suppress', 5);
    tc.verifyClass(h, 'Hough');
    
    lines = h.lines();
    tc.verifyClass(lines, 'LineFeature');
    tc.verifyEqual(numel(lines), 4);
    
    s = char(lines);
    tc.verifyClass(s, 'char');
    tc.verifyEqual(size(s,1), 4);
    

    % test line support
    lines = lines.seglength(edges);
    tc.verifyClass(lines, 'LineFeature');
    tc.verifyEqual(numel(lines), 4);
    
    tc.verifyEqual( numel(lines), 4);
    tc.verifyEqual( length(lines.theta), 4);
    tc.verifyEqual( length(lines.rho), 4);
    tc.verifyEqual( length(lines.length), 4);
    tc.verifyEqual( length(lines.strength), 4);
end