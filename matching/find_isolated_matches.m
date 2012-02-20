%FIND_ISOLATED_MATCHES	find isolated matches in disparity image
%
%	[I,S] = find_isolated_matches(D,neighbourhood,threshold)
%
% I = map of isolated matches (0 = isolated, 1 not isolated)
% S = difference between disparity and average disparity
% D = disparity map
% neighbourhood = [x y] area to be averaged
% threshold = check if a pixel differs from the nieghbourhood average by 
%  this threshold
% Author: Jasmine E. Banks (jbanks@ieee.org)

% Copyright in this software is owned by CSIRO.  CSIRO grants permission to
% any individual or institution to use, copy, modify, and distribute this
% software, provided that:
% 
% (a)     this copyright and permission notice appears in its entirety in or
% on (as the case may be) all copies of the software and supporting
% documentation; 
% 
% (b)     the authors of papers that describe software systems using this
% software package acknowledge such use by citing the paper as follows: 
% 
%     "Quantitative Evaluation of Matching Methods and Validity Measures for
%     Stereo Vision" by J. Banks and P. Corke, Int. J. Robotics Research,
%     Vol 20(7), 2001; and
% 
% (c)     users of this software acknowledge and agree that:
% 
%   (i) CSIRO makes no representations about the suitability of this software
%   for any purpose;
% 
%   (ii) that the software is provided "as is" without express or implied
%   warranty; and
%  
%   (iii) users of this software use the software entirely at their own risk.

function [I,S] = find_isolated_matches(D,neighbourhood,threshold)

I = ones(size(D,1),size(D,2));
S = zeros(size(D,1),size(D,2));
SZ = neighbourhood(1)*neighbourhood(2);

x_border = floor(neighbourhood(1)/2);
y_border = floor(neighbourhood(2)/2);

for j = y_border+1 : size(D,1)-y_border
  for i = x_border+1 : size(D,2)-x_border
    M = sum(sum(D(j-y_border:j+y_border,i-x_border:i+x_border))) / SZ;
    S(j,i) = abs(D(j,i)-M);
    if S(j,i) > threshold
      I(j,i) = 0;
    end
  end
end 
