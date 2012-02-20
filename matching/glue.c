/*
 * Copyright in this software is owned by CSIRO.  CSIRO grants permission to
 * any individual or institution to use, copy, modify, and distribute this
 * software, provided that:
 * 
 * (a)     this copyright and permission notice appears in its entirety in or
 * on (as the case may be) all copies of the software and supporting
 * documentation; 
 * 
 * (b)     the authors of papers that describe software systems using this
 * software package acknowledge such use by citing the paper as follows: 
 * 
 *     "Quantitative Evaluation of Matching Methods and Validity Measures for
 *     Stereo Vision" by J. Banks and P. Corke, Int. J. Robotics Research,
 *     Vol 20(7), 2001; and
 * 
 * (c)     users of this software acknowledge and agree that:
 * 
 *   (i) CSIRO makes no representations about the suitability of this software
 *   for any purpose;
 * 
 *   (ii) that the software is provided "as is" without express or implied
 *   warranty; and
 *  
 *   (iii) users of this software use the software entirely at their own risk.
 *
 *  Author: Jasmine E. Banks (jbanks@ieee.org)
 */
#define BUFLEN 100

void mexFunction(
		 int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  double *left_image;
  double *right_image;
  double *window_size;
  double *disprange; 
  double *disparity;
  double *scores;
  char *left_right;

  unsigned int left_image_cols, left_image_rows, right_image_rows, right_image_cols;
  int x_win_size, y_win_size, i, j, dispmin, dispmax, status, temp;
  unsigned char *leftI, *rightI, *leftI_ptr, *rightI_ptr; 
  signed char *dispI;
  double *scoresD, *scores_ptr, *disp_ptr;

  /* Check for proper number of arguments */
  if (nrhs != 5) {
    mexErrMsgTxt("[Disparity Scores]= Match_Function(left_image,right_image,left-right,[x_window_size y_window_size], [min_disparity max_disparity])"); }
  else if (nlhs > 2) {
    mexErrMsgTxt("[Disparity Scores] are returned by this function."); }

  /* Get size of input images */
  left_image_rows = mxGetM(prhs[0]);
  left_image_cols = mxGetN(prhs[0]);
  right_image_rows = mxGetM(prhs[1]);
  right_image_cols = mxGetN(prhs[1]);

  if ((left_image_rows != right_image_rows) || (left_image_cols != right_image_cols)) {
    mexErrMsgTxt("Left and right images must be the same size."); }

  /* Create matrix for the return arguments */
  plhs[0] = mxCreateDoubleMatrix (left_image_rows, left_image_cols, mxREAL);
  if (nlhs == 2) plhs[1] = mxCreateDoubleMatrix (left_image_rows, left_image_cols, mxREAL);

  /* Get input arguments */
  left_image = mxGetPr(prhs[0]);
  right_image = mxGetPr(prhs[1]);

  left_right = mxCalloc(BUFLEN,sizeof(char));
  status = mxGetString(prhs[2], left_right, BUFLEN);

  window_size = mxGetPr(prhs[3]);
  if (mxGetM(prhs[3]) * mxGetN(prhs[3]) > 1) {
	x_win_size = (int)window_size[0];
	y_win_size = (int)window_size[1];
  } else {
	x_win_size = y_win_size = (int)window_size[0];
  }
  disprange = mxGetPr(prhs[4]);
  if (mxGetM(prhs[4]) * mxGetN(prhs[4]) > 1) {
	dispmin = (int)disprange[0];
	dispmax = (int)disprange[1];
  } else {
	dispmin = 0;
	dispmax = (int)disprange[0];
  }

  disparity = mxGetPr(plhs[0]);
  if (nlhs == 2) 
    scores = mxGetPr(plhs[1]); 

  leftI= (unsigned char*) mxCalloc (left_image_cols * left_image_rows, sizeof(unsigned char));
  rightI= (unsigned char*) mxCalloc (left_image_cols * left_image_rows, sizeof(unsigned char));
  dispI= (signed char*) mxCalloc (left_image_cols * left_image_rows, sizeof(signed char));
  scoresD = (double *) mxCalloc (left_image_cols * left_image_rows, sizeof(double));

  /* Transpose row-column order of input matrices */
  leftI_ptr = leftI;
  rightI_ptr = rightI;

  for (i = 0; i < left_image_rows; i++)
    for (j = 0; j < left_image_cols; j++) {
      unsigned int pix;
      
      pix = (unsigned int) *(left_image + j*left_image_rows + i);
      *(leftI_ptr++)= (unsigned char) pix;

      pix = (unsigned int) *(right_image + j*left_image_rows + i);
      *(rightI_ptr++) = (unsigned char) pix;
    }
    
  printf("Image size: %d x %d\n", left_image_rows, left_image_cols); 
  printf("Window size: %d x %d, disparity: %d - %d\n", x_win_size, y_win_size, dispmin, dispmax);
  
  if (left_right[0] == 'r')
    MATCH_RIGHT (leftI, rightI, dispI, scoresD, left_image_cols, left_image_rows, x_win_size, y_win_size, dispmin, dispmax);

  else if (left_right[0] == 'l')
    MATCH_LEFT (leftI, rightI, dispI, scoresD, left_image_cols, left_image_rows, x_win_size, y_win_size, dispmin, dispmax);

  /* Transpose result matrices */
  disp_ptr = disparity;

  for (i = 0; i < left_image_cols; i++) 
    for (j = 0; j < left_image_rows; j++) {
      temp = (int) *(dispI + j*left_image_cols + i);
      *(disp_ptr++) = (double) temp;
    }

  if (nlhs == 2) { 
    scores_ptr = scores;
    for (i = 0; i < left_image_cols; i++) 
      for (j = 0; j < left_image_rows; j++) 
      *(scores_ptr++) = *(scoresD + j*left_image_cols + i);
  }
} /* mexFunction */

