%SAD	Stereo matching using Census transform 
%
%	[DISP SCORES] = CENSUS(LEFT, RIGHT, LEFT_RIGHT, CENSUS_WIN_SIZE, MATCH_WIN_SIZE, DISP_RANGE)
%
%       DISP = Disparity map
%       SCORES = CENSUS scores at each disparity
%       LEFT, RIGHT = images
%       LEFT_RIGHT = 'l' if wrt left image, 'r' if wrt right image
%       CENSUS_WIN_SIZE = census_win_size or [x_census_win_size y_census_win_size]
%       MATCH_WIN_SIZE = win_size or [x_win_size y_win_size]
%       DISP_RANGE = [START_DISPARITY END_DISPARITY]
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

