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
#ifndef STANDALONE 
#include "mex.h"
#define CALLOC mxCalloc
#else

#include <stdlib.h>
#define CALLOC calloc
#endif

#include <math.h>

#ifdef STANDALONE

void rank_transform (unsigned char *image, int x_window_size, int y_window_size, int width, int height, unsigned char *rank_tx) {
  int i, j, x_surround, y_surround, top, bottom, left, right, x, y, incr;
  unsigned char *rank_ptr, *image_row_ptr, *pix_ptr, *top_corner, centre_val;

  x_surround = (x_window_size - 1) / 2; 
  y_surround = (y_window_size - 1) / 2;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;
  incr = width - x_window_size;

  image_row_ptr = image;

  for (y = top; y < bottom; y++) {
    rank_ptr = rank_tx + y * width + left;
    top_corner = image_row_ptr;

    for (x = left; x < right; x++) {
      pix_ptr =  top_corner;
      *rank_ptr = 0;
      centre_val = *(top_corner + width * y_surround + x_surround);
			
      for (i = 0; i < y_window_size; i++) {
	for (j = 0; j < x_window_size; j++) {
	  if (*pix_ptr < centre_val)
	    (*rank_ptr)++;

	  pix_ptr++;
	}
	pix_ptr += incr;
      } /* for i */	

      top_corner++;
      rank_ptr++;
    } /* for */

    image_row_ptr += width;
  } /* for */
} /* rank_transform */

#else

/* Rank transform function called from matlab, takes negative values in image */
void rank_transform (double *image, int x_window_size, int y_window_size, int width, int height, int *rank_tx) {
  int i, j, x_surround, y_surround, top, bottom, left, right, x, y, incr;
  int *rank_ptr;
  double *image_row_ptr, *pix_ptr, *top_corner, centre_val;

  x_surround = (x_window_size - 1) / 2; 
  y_surround = (y_window_size - 1) / 2;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;
  incr = width - x_window_size;

  image_row_ptr = image;

  for (y = top; y < bottom; y++) {
    rank_ptr = rank_tx + y * width + left;
    top_corner = image_row_ptr;

    for (x = left; x < right; x++) {
      pix_ptr =  top_corner;
      *rank_ptr = 0;
      centre_val = *(top_corner + width * y_surround + x_surround);
			
      for (i = 0; i < y_window_size; i++) {
	for (j = 0; j < x_window_size; j++) {  
	  if (*pix_ptr < centre_val)
	    (*rank_ptr)++;

	  pix_ptr++;
	}
	pix_ptr += incr;
      } /* for i */	

      top_corner++;
      rank_ptr++;
    } /* for */

    image_row_ptr += width;
  } /* for */
} /* rank_transform */

void mexFunction(
		 int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  double *image;
  double *rank_scores;
  double *window_size;

  unsigned int cols, rows;
  int x_win_size, y_win_size, i, j;
  double *imageD, *imageD_ptr;
  int  *rank_scoresI;
  double *rank_scores_ptr;

  /* Check for proper number of arguments */
  if (nrhs != 2) {
    mexErrMsgTxt("[RankTransform]= RANK_TX(image,[x_win_size y_win_size])"); }
  else if (nlhs != 1) {
    mexErrMsgTxt("[RANK Transformed image] is returned by this function."); }

  /* Get size of input image */
  rows = mxGetM(prhs[0]);
  cols = mxGetN(prhs[0]);

  /* Create matrix for the return arguments */
  plhs[0] = mxCreateDoubleMatrix (rows, cols, mxREAL);

  /* Get input arguments */
  image = mxGetPr(prhs[0]);
  window_size = mxGetPr(prhs[1]);
  if (mxGetM(prhs[1]) * mxGetN(prhs[1]) > 1) {
    x_win_size = (int)window_size[0];
    y_win_size = (int)window_size[1];
  } else {
    x_win_size = y_win_size = (int)window_size[0];
  }

  /* Set pointers to output arguments */
  rank_scores = mxGetPr(plhs[0]);

  imageD = (double*) CALLOC (cols * rows, sizeof(double));
  rank_scoresI = (int*) CALLOC (cols * rows, sizeof(int));

  /* Transpose row-column order of input matrix */
  imageD_ptr = imageD;
  for (i = 0; i < rows; i++)
    for (j = 0; j < cols; j++) 
      *(imageD_ptr++)=  *(image + j*rows + i); 
 
  rank_transform(imageD, x_win_size, y_win_size, cols, rows, rank_scoresI);
 
  /* Transpose result matrix */
  rank_scores_ptr = rank_scores;
  for (i = 0; i < cols; i++) 
    for (j = 0; j < rows; j++) 
      *(rank_scores_ptr++) = (double) *(rank_scoresI + j*cols + i);

} /* mexFunction */

#endif
