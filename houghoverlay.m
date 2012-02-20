%HOUGHOVERLAY	Overlay lines on image.
%
%	houghoverlay(p)
%	houghoverlay(p, ls)
%	handles = houghoverlay(p, ls)
%
%	Overlay lines, one per row of p, onto the current figure.  The row
%	is interpretted as offset and theta, the Hough transform line
%	representation.
%
%	The optional argument, ls, gives the line style in normal Matlab
%	format.
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

function handles = houghoverlay(p, ls)

	hold_status = ishold;
	hold on

	if nargin < 2,
		ls = 'b';
	end
	
	% figure the x-axis scaling
	scale = axis;
	x = [scale(1):scale(2)]';
	y = [scale(3):scale(4)]';

	% p = [d theta]

	% plot it
	for i=1:numrows(p),
		d = p(i,1);
		theta = p(i,2);

		%fprintf('theta = %f, d = %f\n', theta, d);
		if abs(cos(theta)) > 0.5,
			% horizontalish lines
			hl(i) = plot(x, -x*tan(theta) + d/cos(theta), ls);
		else
			% verticalish lines
			hl(i) = plot( -y/tan(theta) + d/sin(theta), y, ls);
		end
	end

	if hold_status,
		hold on
	else
		hold off
	end

	if nargout > 0,
		handles = hl;
    end
    figure(gcf);        % bring it to the top
