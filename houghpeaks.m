%HOUGHPEAKS   Find Hough accumulator peaks.
%
%	p = houghpeaks(H, N, hp)
%
%  Returns the coordinates of N peaks from the Hough
%  accumulator.  The highest peak is found, refined to subpixel precision,
%  then hp.radius radius around that point is zeroed so as to eliminate
%  multiple close minima.  The process is repeated for all N peaks.
%  p is an n x 3 matrix where each row is the offset, theta and
%  relative peak strength (range 0 to 1).
%
%  The peak detection loop breaks early if the remaining peak has a relative 
%  strength less than hp.houghThresh.
%  The peak is refined by a weighted mean over a w x w region around
%  the peak where w = hp.interpWidth.
%
% Parameters affecting operation are:
%
%	hp.houghThresh	threshold on relative peak strength (default 0.4)
%	hp.radius       radius of accumulator cells cleared around peak 
%                                 (default 5)
%	hp.interpWidth  width of region used for peak interpolation
%                                 (default 5)
%
% SEE ALSO: ihough

% Copyright (C) 1995-2009, by Peter I. Corke
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

function p = houghpeaks(H, N, params)
		% for houghpeaks
		%default.houghThresh = 0.40;
		%default.radius = 5;
		%default.interpWidth = 5;

	if nargin < 3,
		params.houghThresh = 0.40;
		params.radius = 5;
		params.interpWidth = 5;
	end
	if nargin < 2,
		N = 5;
    end

	nr = numrows(H.h);
	nc = numcols(H.h);
	[x,y] = meshgrid(1:nc, 1:nr);

    nw2= floor((params.interpWidth-1)/2);
    [Wx,Wy] = meshgrid(-nw2:nw2,-nw2:nw2);
    globalMax = max(H.h(:));
    
    for i=1:N,
        % find the current peak
        [mx,where] = max(H.h(:));
        
        % is the remaining peak good enough?
        if mx < (globalMax*params.houghThresh),
            break;
        end
        [rp,cp] = ind2sub(size(H.h), where);
        
        if params.interpWidth == 0,
            d = H.d(rp);
            theta = H.theta(cp);
            p(i,:) = [d theta mx/globalMax];
        else,
            % refine the peak to subelement accuracy
            try,
                Wh = H.h(rp-nw2:rp+nw2,cp-nw2:cp+nw2);
            catch,
                % window is at the edge, do it the slow way
                % we wrap the coordinates around the accumulator on all edges
                for r2=1:2*nw2+1,
                    r3 = rp+r2-nw2-1;
                    if r3 > nr,
                        r3 = r3 - nr;
                    elseif r3 < 1,
                        r3 = r3 + nr;
                    end
                    for c2=1:2*nw2+1,
                        c3 = cp+c2-nw2-1;
                        if c3 > nc,
                            c3 = c3 - nc;
                        elseif c3 < 1,
                            c3 = c3 + nc;
                        end
                        Wh(r2,c2) = H.h(r3,c3);
                    end
                end

            end
            rr = Wy .* Wh;
            cc = Wx .* Wh;
            ri = sum(rr(:)) / sum(Wh(:)) + rp;
            ci = sum(cc(:)) / sum(Wh(:)) + cp;
            %fprintf('refined %f %f\n', r, c);

            % interpolate the line parameter values
            d = interp1(H.d, ri);
            theta = interp1(H.theta, ci);
            p(i,:) = [d theta mx/globalMax];

        end
        
		% remove the region around the peak
		k = (x(:)-cp).^2 + (y(:)-rp).^2 < params.radius^2;
		H.h(k) = 0;
	end
