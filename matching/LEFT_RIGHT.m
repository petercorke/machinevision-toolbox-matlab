% [Valid_Left, Valid_Right] = LEFT_RIGHT (left_disp, right_disp, [x_border y_border])
%
% Performs left-right consistency checking
%
% left_disp, right_disp = disparity maps with respect to each image
% x_border, y_border 
%
% Valid_Left, Valid_Right = validity masks computed with respect to each image
%
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

