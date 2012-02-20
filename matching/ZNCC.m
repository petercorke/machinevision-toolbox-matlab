%SAD	Stereo matching using Zero Mean Normalised Cross Correlation metric
%
%	[DISP SCORES] = ZNCC(LEFT, RIGHT, LEFT_RIGHT, WIN_SIZE, DISP_RANGE)
%
%       DISP = Disparity map
%       SCORES = ZNCC scores at each disparity
%       LEFT, RIGHT = images
%       LEFT_RIGHT = 'l' if wrt left image, 'r' if wrt right image
%       WIN_SIZE = window size or [x_size y_size]
%       DISP_RANGE = [START_DISPARITY END_DISPARITY]
