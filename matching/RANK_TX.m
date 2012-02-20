function [RankTransform] = RANK(image,win_size)
%
% RankTransform = RANK (image, win_size)
%
% Performs the rank transform of an image using any size window
%
% win_size = win_size or [x_win_size y_win_size]
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

