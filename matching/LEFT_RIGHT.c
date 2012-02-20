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
#include <stdio.h>
#include <stdlib.h>
#include "area.h"
#define CALLOC calloc

#endif

#include <math.h>

#define THRESHOLD 2

#ifdef STANDALONE

void left_right (signed char *left_disp, signed char *right_disp, signed char *left_disp_valid, signed char *right_disp_valid, int width, int height, int x_border, int y_border) {

  int i,j, predicted_right, predicted_left, x_surround, y_surround, top, bottom, left, right;
  double leftd, rightd;

  x_surround = x_border;  
  y_surround = y_border;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;

  for (i = top; i < bottom; i++) {

    for (j = left; j < right; j++) { 
      
      /* start with computed disparity wrt left image */
      leftd = *(left_disp + i*width + j);

      /* find predicted disparity in right image */   
      predicted_right = j - leftd;

      /* Check if beyond limits */
      if ((predicted_right < 0) || (predicted_right > width)) 
	*(left_disp_valid + i*width + j) = 0;
      else {
	
	/* Check difference between predicted disparity and stored */
	if (fabs(*(right_disp + i*width + predicted_right) - leftd) < THRESHOLD)
	   *(left_disp_valid + i*width + j) = 1;
	else 
	  *(left_disp_valid + i*width + j) = 0;
      }
    } /* for j */
  } /* for i */ 

  for (i = top; i < bottom; i++) {  

    for (j = left; j < right; j++) { 

      /* start with computed disparity wrt right image */
      rightd = *(right_disp + i*width + j);

      /* find predicted disparity in left image */   
      predicted_left = j + rightd;

      /* Check if beyond limits */
      if ((predicted_left < 0) || (predicted_left > width)) 
	*(right_disp_valid + i*width + j) = 0;
      else {

	/* Check difference between predicted disparity and stored */
	if (fabs(*(left_disp + i*width + predicted_left) - rightd) < THRESHOLD)
	   *(right_disp_valid + i*width + j) = 1;
	else 
	  *(right_disp_valid + i*width + j) = 0;
      }
    } /* for j */
  } /* for i */
} /* left_right */

#else

void left_right (double *left_disp, double *right_disp, double *left_disp_valid, double *right_disp_valid, int width, int height, int x_border, int y_border) {

  int i,j, predicted_right, predicted_left, x_surround, y_surround, top, bottom, left, right;
  double leftd, rightd;

  x_surround = x_border;  
  y_surround = y_border;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;

  for (i = top; i < bottom; i++) {
    for (j = left; j < right; j++) { 
      
      /* start with computed disparity wrt left image */
      leftd = *(left_disp + i*width + j);

      /* find predicted disparity in right image */   
      predicted_right = j - leftd;

      /* Check if beyond limits */
      if ((predicted_right < 0) || (predicted_right > width)) 
	*(left_disp_valid + i*width + j) = 0;
      else {
	
	/* Check difference between predicted disparity and stored */
	if (fabs(*(right_disp + i*width + predicted_right) - leftd) < THRESHOLD)
	   *(left_disp_valid + i*width + j) = 1;
	else 
	  *(left_disp_valid + i*width + j) = 0;
      }
    } /* for j */
  } /* for i */ 

  for (i = top; i < bottom; i++) {
    for (j = left; j < right; j++) { 

      /* start with computed disparity wrt right image */
      rightd = *(right_disp + i*width + j);

      /* find predicted disparity in left image */   
      predicted_left = j + rightd;

      /* Check if beyond limits */
      if ((predicted_left < 0) || (predicted_left > width)) 
	*(right_disp_valid + i*width + j) = 0;
      else {

	/* Check difference between predicted disparity and stored */
	if (fabs(*(left_disp + i*width + predicted_left) - rightd) < THRESHOLD)
	   *(right_disp_valid + i*width + j) = 1;
	else 
	  *(right_disp_valid + i*width + j) = 0;
      }
    } /* for j */
  } /* for i */
} /* left_right */

void mexFunction(
		 int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  double *left_disp;
  double *right_disp; 
  double *window_size;
  double *left_disp_valid;
  double *right_disp_valid;

  unsigned int left_cols, left_rows, right_rows, right_cols, i, j, x_win_size, y_win_size;
  double *leftdispD, *rightdispD, *leftdispvalidD, *rightdispvalidD, *leftD_ptr, *rightD_ptr; 
  double *right_disp_ptr, *left_disp_ptr;

  /* Check for proper number of arguments */
  if (nrhs != 3) {
    mexErrMsgTxt("[Left_Disp Right_Disp]= LEFT_RIGHT(left_disp,right_disp,[x_border y_border])"); }
  else if (nlhs != 2) {
    mexErrMsgTxt("[Left_Disp Right_Disp] are returned by this function."); }

  /* Get size of input images */
  left_rows = mxGetM(prhs[0]);
  left_cols = mxGetN(prhs[0]);

  right_rows = mxGetM(prhs[1]);
  right_cols = mxGetN(prhs[1]);

  if ((left_rows != right_rows) || (left_cols != right_cols)) {
    mexErrMsgTxt("Left and right disparity images must be the same size."); }

  /* Create matrix for the return arguments */
  plhs[0] = mxCreateDoubleMatrix (left_rows, left_cols, mxREAL);
  plhs[1] = mxCreateDoubleMatrix (left_rows, left_cols, mxREAL);
  plhs[2] = mxCreateDoubleMatrix (left_rows, left_cols, mxREAL);
 
  /* Get input arguments */
  left_disp = mxGetPr(prhs[0]);
  right_disp = mxGetPr(prhs[1]);
  window_size = mxGetPr(prhs[2]);
  if (mxGetM(prhs[2]) * mxGetN(prhs[2]) > 1) {
	x_win_size = (int)window_size[0];
	y_win_size = (int)window_size[1];
  } else {
	x_win_size = y_win_size = (int)window_size[0];
  }
  /* Set pointers to output arguments */
  left_disp_valid = mxGetPr(plhs[0]);
  right_disp_valid = mxGetPr(plhs[1]);

  leftdispD = (double*) CALLOC (left_cols * left_rows, sizeof(double));
  rightdispD = (double*) CALLOC (left_cols * left_rows, sizeof(double));

  leftdispvalidD = (double*) CALLOC (left_cols * left_rows, sizeof(double)); 
  rightdispvalidD = (double*) CALLOC (left_cols * left_rows, sizeof(double));

  /* Transpose row-column order of input matrices */
  leftD_ptr = leftdispD;
  rightD_ptr = rightdispD;
  for (i = 0; i < left_rows; i++)
    for (j = 0; j < left_cols; j++) {
      *(leftD_ptr++)= *(left_disp + j*left_rows + i);
      *(rightD_ptr++) = *(right_disp + j*left_rows + i);
    }
    
  left_right(leftdispD, rightdispD, leftdispvalidD, rightdispvalidD, left_cols, left_rows, x_win_size,y_win_size);
 
  /* Transpose result matrices */
  right_disp_ptr = right_disp_valid;
  left_disp_ptr = left_disp_valid;
  for (i = 0; i < left_cols; i++) 
    for (j = 0; j < left_rows; j++) { 
      *(left_disp_ptr++) = *(leftdispvalidD + j*left_cols + i); 
      *(right_disp_ptr++) =   *(rightdispvalidD + j*left_cols + i);
    }
} /* mexFunction */

#endif
