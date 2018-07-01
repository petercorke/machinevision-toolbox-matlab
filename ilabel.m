%ILABEL Label an image
%
% L = ILABEL(IM) is a label image that indicates connected components within
% the image IM (HxW).  Each pixel in L (HxW) is an integer label that indicates
% which connected region the corresponding pixel in IM belongs to.  Region
% labels are in the range 1 to M.
%
% [L,M] = ILABEL(IM) as above but returns the value of the maximum
% label value.
%
% [L,M,PARENTS] = ILABEL(IM) as above but also returns region hierarchy
% information.  The value of PARENTS(I) is the label of the parent, or
% enclosing, region of region I.  A value of 0 indicates that the region has
% no single enclosing region, for a binary image this means the region
% touches the edge of the image, for a multilevel image it means that the
% region touches more than one other region.
%
% [L,MAXLABEL,PARENTS,CLASS] = ILABEL(IM) as above but also returns the class
% of pixels within each region.  The value of CLASS(I) is the value of the
% pixels that comprise region I.
%
% [L,MAXLABEL,PARENTS,CLASS,EDGE] = ILABEL(IM) as above but also returns an
% edge point for each region.  EDGE(I) is the index of a pixel on the
% border of region I, use IND2SUB to convert it to a coordinate.
%
% Notes::
% - This algorithm is variously known as region labelling, connectivity
%   analysis, connected component analysis, blob labelling.
% - All pixels within a region have the same value (or class).
% - This is a "low level" function, IBLOBS is a higher level interface.
% - The image can be binary or greyscale.
% - Connectivity is only performed in 2 dimensions.
% - Connectivity is performed using 4 nearest neighbours by default.
%   - To use 8-way connectivity pass a second argument of 8, eg. ILABEL(IM, 8).
%   - 8-way connectivity introduces ambiguities, a chequerboard is two blobs.
% - A MEX file is provided which is about 50x faster.
%
% See also IBLOBS, IMOMENTS, PARENTS2GRAPH.

% Copyright (C) 1993-2018, by Peter I. Corke
%
% This file is part of The Machine Vision Toolbox for Matlab (MVTB).
%
% MVTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% MVTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
%
% You should have received a copy of the GNU Leser General Public License
% along with MVTB.  If not, see <http://www.gnu.org/licenses/>.
%
% http://www.petercorke.com

function [L,N,P,C,E] = ilabel(im, connectivity)
    
    if nargin < 2
        connectivity = 4;
    end
    assert(any(connectivity==[4 8]), 'connectivity must be 4 or 8');
    
    labellist = [];
    
    % we'll make the labels uint32s, >= 1, they are unique and never recycled.
    width = numcols(im); height = numrows(im);
    limage = zeros(size(im), 'uint32');
    parents = uint32(0);
    blobsize = uint32(0);
    UNKNOWN = 0;
    THRESH = 0;
    nextlabel = int32(0);  % the highest label yet assigned
    edge = [];
    color = [];
    
    for row=1:height
        prevlab = UNKNOWN;
        for col=1:width
            curpix = im(row,col);
            curlab = UNKNOWN;  % start with no label
            
            if col>1
                % possible to inherit from the left
                prevpix = im(row,col-1);
                if curpix == prevpix
                    % if no change in pixel value, then inherit label from the left
                    curlab = prevlab;
                end
            end
            
            if row>1
                % possible to inherit from above
                if im(row-1,col) == curpix && limage(row-1,col) ~= curlab
                    % assign label from the N
                    newlabel = limage(row-1,col);
                    
                    if curlab ~= UNKNOWN
                        % new label dominates
                        
                        limage(limage==curlab) = newlabel;  % MERGE
                        parents(parents==curlab) = newlabel;
                        
                        labellist = [labellist curlab];  % recycle the old label
                        blobsize(newlabel) = blobsize(newlabel) + blobsize(curlab);
                    end
                    curlab = newlabel;
                    
                elseif connectivity == 8
                    % deal with 8-way connectivity
                    if col>1 && im(row-1,col-1) == curpix && limage(row-1,col-1) ~= curlab
                        % merge to the NW
                        newlabel = limage(row-1, col-1);
                        
                        if curlab ~= UNKNOWN
                            limage(limage==curlab) = newlabel;  % MERGE
                            parents(parents==curlab) = newlabel;
                            
                            labellist = [labellist curlab];  % recycle the old label
                                                        
                            if parents(curlab) == 0
                                parents(newlabel) = 0;
                            end
                            blobsize(newlabel) = blobsize(newlabel) + blobsize(curlab);
                        end
                        curlab = newlabel;
                        
                    elseif  (col<width) && im(row-1,col+1) == curpix && limage(row-1,col+1) ~= curlab
                        % merge to the NE
                        newlabel = limage(row-1, col+1);
                        
                        if curlab ~= UNKNOWN
                            limage(limage==curlab) = newlabel;  % MERGE
                            parents(parents==curlab) = newlabel;
                            
                            labellist = [labellist curlab];  % recycle the old label
                            
                            blobsize(newlabel) = blobsize(newlabel) + blobsize(curlab);
                        end
                        curlab = newlabel;
                    end
                end
            end
            
            if row>1 && col>1
                % check for enclosure
                
                left = prevlab;
                above = limage(row-1,col);
                northwest = limage(row-1,col-1);
                if left == curlab && above == curlab && northwest ~= curlab
                    % we have an enclosure
                    % northwest is enclosed by curlab
                    % northwest is the child of curlab
                    % curlab is the parent of northwest
                    parents(northwest) = curlab;
                    
                    % save the coordinate and color of the northwest blob
                    edge(northwest) = (row-2) + height*(col-2) + 1;
                       
                    if blobsize(curlab) > THRESH
                        parents(northwest) = curlab;
                        %                     else
                        %                         % its a runt
                        %                         lmap(curlab) = northwest;
                    end
                end
            end
            
            % if label still not known, assign a new value
            if curlab == UNKNOWN
                % find the next label
                if length(labellist) == 0
                    % create a new label
                    nextlabel = nextlabel + 1;
                    curlab = nextlabel;
                else
                    % use a recycled label
                    curlab = labellist(1);
                    labellist(1) = [];
                end
                % new blob, set its size to 0 and note its color
                blobsize(curlab) = 0;
                color(curlab) = im(row,col);
            end
            
            blobsize(curlab) = blobsize(curlab) + 1;
            
            limage(row,col) = curlab;
            prevlab = curlab;
            prevpix = curpix;
        end
    end
        
    % we're done
    % however the labels are not consecutive and the data in the edge, color
    % and parent arrays are sparse
    
    % create a map:  map(label) -> consecutive label
    map = [];    
    uniqlabels = unique(limage(:))';
    map(uniqlabels) = 1:length(uniqlabels);
    
    % map the label image
    if nargout > 0
        L = reshape( map(limage(:)), size(limage) );
    end
    
    % number of unique labels
    if nargout > 1
        N = length(uniqlabels);
    end
    
    % parent array
    if nargout > 2
        % find the valid indices into parent, color, edge arrays
        % the edge array has a nonzero entry if the blob has been enclosed
        
        if isempty(edge)
            numedge = 0;
        else
            numedge = length(edge);
        end
        
        % make a list of valid edge coordinates
        %  only for blobs that were enclosed, ie. didn't touch the edge
        k = [];
        for u=uniqlabels
            if u <= numedge && edge(u) > 0
                k = [k u];
            end
        end

        P = zeros(1,N);   % init to zero
        P(map(k)) = map(parents(k)); % map parents and children
    end
    
    % pixel class array
    if nargout > 3
        % map the entries
        C = color( find(map>0) );
    end
    
   % edge point coordinates
    if nargout > 4
        % map the entries
        E = zeros(1,N);
        E(map(k)) = edge(k);
    end
end