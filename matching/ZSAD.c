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

/***************************************************************************************
compute_means
***************************************************************************************/
void compute_means_zsad (unsigned char *left_image, unsigned char *right_image, int x_window_size, int y_window_size, int width, int height, double *left_means, double *right_means) {
  int x_surround, y_surround, top, bottom, left, right, x, y, i, j, incr, first_col;
  unsigned char *right_corner, *left_corner, *left_row, *right_row, *ptr_right, *ptr_left;
  double *right_mean_ptr, *left_mean_ptr, size_sq;

  size_sq = x_window_size * y_window_size;
  x_surround = (x_window_size - 1) / 2; 
  y_surround = (y_window_size - 1) / 2;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;
  incr = width - x_window_size;

  left_mean_ptr = left_means;
  right_mean_ptr = right_means;

  left_row = left_image;
  right_row = right_image;

  for (y = top; y < bottom; y++) 
    for (x = left; x < right; x++) {
	*(right_means + y*width + x) = 0.0;
	*(left_means + y*width + x) = 0.0;
			
	for (i = -x_window_size/2; i <= x_window_size/2; i++) 
	  for (j = -y_window_size/2; j <= y_window_size/2; j++) {
	    *(left_means + y*width + x) += (double) *(left_image + (y+j)*width + (x+i));
	    *(right_means + y*width + x) += (double) *(right_image + (y+j)*width + (x+i));
	  }

	*(right_means + y*width + x) /= size_sq;
	*(left_means + y*width + x) /= size_sq;
    } /* for */
} /* compute_means */

void match_ZSAD_right (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity) {
  unsigned char *ptr_left, *ptr_right;
  unsigned int right_x;
  int disp, right_lim, left_lim, y, i, j, top, bottom, left, right, x_surround, y_surround;
  double left_pix, right_pix, *left_means, *right_means, *left_mean_ptr, *right_mean_ptr, sum, t;

  left_means = (double*) CALLOC (width * height, sizeof(double));
  right_means = (double*) CALLOC (width * height, sizeof(double));
  compute_means_zsad(left_image, right_image, x_window_size, y_window_size, width, height, left_means, right_means);
  
  x_surround = (x_window_size - 1) / 2;  
  y_surround = (y_window_size - 1) / 2;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;

  /* Set minimum array to a really large number */
  for (i = 0; i < width * height; i++)
    min_array[i] = 1E10;

  for (disp = min_disparity; disp < max_disparity; disp++) {
#ifndef STANDALONE
    printf ("%d ",disp);
#else
    printf ("%d\r",disp);
#endif
    
    for (y = top; y < bottom; y++) {

      if (disp < 0) {
	ptr_left =  left_image + y * width + x_surround;
	ptr_right = right_image + y * width - disp + x_surround;
	left_mean_ptr = left_means + y*width + x_surround;
	right_mean_ptr = right_means + y*width - disp + x_surround;

      } else { 
	ptr_left =  left_image + y * width + disp + x_surround;  
	ptr_right = right_image + y * width + x_surround;	
	left_mean_ptr = left_means + y*width + disp + x_surround;
	right_mean_ptr = right_means + y*width + x_surround;
      }

      right_lim = (disp < 0)? right : right - disp;
      left_lim = (disp < 0)? left - disp : left;

      for (right_x = left_lim; right_x < right_lim; right_x++) { 

	sum = 0;

	for (i = -x_surround; i <= x_surround; i++) 
	  for (j = -y_surround; j <= y_surround; j++) {
	    left_pix = ((double)  *(ptr_left + j*width + i)) - *left_mean_ptr;
	    right_pix = ((double) *(ptr_right + j*width + i)) - *right_mean_ptr;

	    t = right_pix - left_pix;
	    sum +=  (t > 0)? t:-t;
	  } /* for j */
	
	if (sum < *(min_array + width * y + right_x)) {
	  *(disparity + width * y + right_x) = disp; /* - min_disparity; */
	  *(min_array + width * y + right_x) = sum;
	} /* if */

	ptr_left++;
	ptr_right++;
	left_mean_ptr++;
	right_mean_ptr++;
      } /* for right_x */
    } /* for y*/
  } /* for disparity */

#ifdef STANDALONE
  free(left_means);
  free(right_means);
#endif

  printf("\n");
} /* match_ZSAD_right */

void match_ZSAD_left (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity) {
  unsigned int left_x;
  unsigned char *ptr_left, *ptr_right;
  double left_pix, right_pix, t, sum, *left_means, *right_means, *left_mean_ptr, *right_mean_ptr;
  int disp, right_lim, left_lim, y, i, j, top, bottom, left, right, x_surround, y_surround;

  left_means = (double*) CALLOC (width * height, sizeof(double));
  right_means = (double*) CALLOC (width * height, sizeof(double));
  compute_means_zsad(left_image, right_image, x_window_size, y_window_size, width, height, left_means, right_means);

  x_surround = (x_window_size - 1) / 2; 
  y_surround = (y_window_size - 1) / 2;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;

  for (i = 0; i < width * height; i++)
    min_array[i] = 1E10;

  for (disp = min_disparity; disp < max_disparity; disp++) {
#ifndef STANDALONE
    printf ("%d ",disp);
#else
    printf ("%d\r",disp);
#endif
    
    for (y = top; y < bottom; y++) {

      if (disp < 0) {
	ptr_left =  left_image + y*width + x_surround;
	ptr_right = right_image + y*width - disp + x_surround;
	left_mean_ptr = left_means + y*width + x_surround;
	right_mean_ptr = right_means + y*width - disp + x_surround;

      } else { 
	ptr_left =  left_image + y*width + disp + x_surround;  
	ptr_right = right_image + y*width + x_surround;
	left_mean_ptr = left_means + y*width + disp + x_surround;
	right_mean_ptr = right_means + y*width + x_surround;
      }

      right_lim = (disp < 0)? right + disp : right;
      left_lim = (disp < 0)? left : left + disp;

      for (left_x = left_lim; left_x < right_lim; left_x++) { 
	sum = 0; 
	
	for (i = -x_surround; i <= x_surround; i++) 
	  for (j = -y_surround; j <= y_surround; j++) {
	      left_pix = ((double) *(ptr_left + j*width + i)) - *left_mean_ptr;
	      right_pix = ((double) *(ptr_right + j*width + i)) - *right_mean_ptr;

	      t = right_pix - left_pix;
	      sum +=  (t > 0)? t:-t;
	    } /* for j */

	if (sum < *(min_array + width * y + left_x)) {
	  *(disparity + width * y + left_x) = disp; /* - min_disparity;*/
	  *(min_array + width * y + left_x) = sum;
	} /* if */

	ptr_left++;
	ptr_right++;
	left_mean_ptr++;
	right_mean_ptr++;
      } /* for left_x */
    } /* for y*/
  } /* for disparity */

#ifdef STANDALONE
  free(left_means);
  free(right_means);
#endif

  printf("\n");
} /* match_ZSAD_left */

#define MATCH_RIGHT     match_ZSAD_right
#define	MATCH_LEFT	match_ZSAD_left

#ifndef STANDALONE 
#include	"glue.c"
#endif
