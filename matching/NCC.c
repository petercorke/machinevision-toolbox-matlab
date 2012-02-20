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

void match_NCC_right (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *max_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity) {
  unsigned int x, y, x_surround, y_surround, i, j, offsetx, right_x, top, bottom, left, right, incr;
  unsigned char *left_corner, *right_corner, *ptr_left, *ptr_right;
  double left_pix, right_pix;

  double ncc, den;
  double sum, sum_left, sum_right, prev_sum, prev_sum_left, prev_sum_right;
  int disp, right_lim, left_lim;

  x_surround = (x_window_size - 1) / 2; 
  y_surround = (y_window_size - 1) / 2;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;
  incr = width - x_window_size;

  /*  max_array = (double *) CALLOC (width * height, sizeof(double)); */
  for (i = 0; i < width * height; i++)
    max_array[i] = 0;

  for (disp = min_disparity; disp < max_disparity; disp++) {
#ifndef STANDALONE
    printf ("%d ",disp);
#else
    printf ("%d\r",disp);
#endif
    
    for (y = top; y < bottom; y++) {  
      if (disp < 0) {
	left_corner =  left_image + (y - y_surround) * width;
	right_corner = right_image + (y - y_surround) * width - disp;
      } else { 
	left_corner =  left_image + (y - y_surround) * width + disp;
	right_corner = right_image + (y - y_surround) * width;
      }

      sum = 0;
      sum_left = 0;
      sum_right = 0;
      right_lim = (disp < 0)? right : right - disp;
      left_lim = (disp < 0)? left - disp:left;

      for (right_x = left_lim; right_x < right_lim; right_x++) {
	ptr_left = left_corner;
	ptr_right = right_corner;

	if ((y == top) && (right_x == left_lim)) { /* If top left hand corner */
	  for (i = 0; i < y_window_size; i++) {
	    for (j = 0; j < x_window_size; j++) {
	      left_pix = (double) *ptr_left;
	      right_pix = (double) *ptr_right;

	      sum += left_pix * right_pix;
	      sum_left += left_pix * left_pix;
	      sum_right += right_pix * right_pix;
	
	      ptr_left++;
	      ptr_right++;
	    } /* for j */

	    ptr_left += incr;
	    ptr_right += incr;
	  } /* for i */

	  prev_sum = sum;
	  prev_sum_left = sum_left;
	  prev_sum_right = sum_right;

	} else if (right_x == left_lim) {
	
	  sum = prev_sum;
	  sum_left = prev_sum_left;
	  sum_right = prev_sum_right;

	  ptr_left -= width; ptr_right -= width;

	  for (i = 0; i < x_window_size; i++) {
	    left_pix = (double) *(ptr_left);
	    right_pix = (double) *(ptr_right);
   
	    /* subtract first row of previous window */
	    sum -= left_pix * right_pix;
	    sum_left -= left_pix * left_pix;
	    sum_right -= right_pix * right_pix;

	    ptr_left ++;
	    ptr_right ++;
	  }

	  ptr_left = left_corner + (y_window_size - 1) * width;
	  ptr_right = right_corner + (y_window_size - 1) * width;

	  for (i = 0; i < x_window_size; i++) {
	    left_pix = (double) *(ptr_left);
	    right_pix = (double) *(ptr_right);
	
	    /* add new last column */
	    sum += left_pix * right_pix;
	    sum_left += left_pix * left_pix;
	    sum_right += right_pix * right_pix;

	    ptr_left ++;
	    ptr_right ++;
	  } /* for i */

	  prev_sum = sum;
	  prev_sum_left = sum_left;
	  prev_sum_right = sum_right;

	} else {
	  ptr_left--; ptr_right--;

	  for (i = 0; i < y_window_size; i++) {
	    left_pix = (double) *(ptr_left);
	    right_pix = (double) *(ptr_right);

	    /* subtract first column of previous window */
	    sum -= left_pix * right_pix;
	    sum_left -= left_pix * left_pix;
	    sum_right -= right_pix * right_pix;

	    ptr_left += x_window_size;
	    ptr_right += x_window_size;

	    left_pix = (double) *(ptr_left);
	    right_pix = (double) *(ptr_right);
	      
	    /* add new last column */
	    sum += left_pix * right_pix;
	    sum_left += left_pix * left_pix;
	    sum_right += right_pix * right_pix;

	    ptr_left += incr;
	    ptr_right += incr;

	  } /* for i */
	} /* if */

	den = sqrt (sum_left * sum_right);
	
	if (den != 0)  
	  ncc = (sum) / den;
	else 
	  ncc = 0;

	if (ncc > *(max_array + width * y + right_x)) {
	  *(disparity + width * y + right_x) = disp; /* - min_disparity; */ 
	  *(max_array + width * y + right_x) = ncc;
	} /* if */

	left_corner++;
	right_corner++;
      } /* for right_x */
    } /* for y*/
  } /* for disparity */
  printf("\n");
} /* match_NCC_right */

void match_NCC_left (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *max_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity) {
  unsigned int x, y, x_surround, y_surround, i, j, offsetx, left_x, top, bottom, left, right, incr, first_row, first_block;
  unsigned char *left_corner, *right_corner, *ptr_left, *ptr_right;
  double left_pix, right_pix;

  double ncc, den;
  double sum, sum_left, sum_right, prev_sum, prev_sum_left, prev_sum_right;
  int disp, right_lim, left_lim;

  x_surround = (x_window_size - 1) / 2;  
  y_surround = (y_window_size - 1) / 2;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;
  incr = width - x_window_size;

  /*  max_array = (double *) CALLOC (width * height, sizeof(double)); */
  for (i = 0; i < width * height; i++)
    max_array[i] = 0;

  for (disp = min_disparity; disp < max_disparity; disp++) {
#ifndef STANDALONE
    printf ("%d ",disp);
#else
    printf ("%d\r",disp);
#endif
      
    for (y = top; y < bottom; y++) {  
      if (disp < 0) {
	left_corner =  left_image + (y - y_surround) * width;
	right_corner = right_image + (y - y_surround) * width - disp;
      } else { 
	left_corner =  left_image + (y - y_surround) * width + disp;
	right_corner = right_image + (y - y_surround) * width;
      }

      sum = 0;
      sum_left = 0;
      sum_right = 0;
      right_lim = (disp < 0)? right + disp: right;
      left_lim = (disp < 0)? left : left + disp;

      for (left_x = left_lim; left_x < right_lim; left_x++) {
	ptr_left = left_corner;
	ptr_right = right_corner;

	if ((y == top) && (left_x == left_lim)) { /* If top left hand corner */
	  for (i = 0; i < y_window_size; i++) {
	    for (j = 0; j < x_window_size; j++) {
	      left_pix = (double) *ptr_left;
	      right_pix = (double) *ptr_right;

	      sum += left_pix * right_pix;
	      sum_left += left_pix * left_pix;
	      sum_right += right_pix * right_pix;
	
	      ptr_left++;
	      ptr_right++;
	    } /* for j */

	    ptr_left += incr;
	    ptr_right += incr;
	  } /* for i */

	  prev_sum = sum;
	  prev_sum_left = sum_left;
	  prev_sum_right = sum_right;

	} else if (left_x == left_lim) {
	
	  sum = prev_sum;
	  sum_left = prev_sum_left;
	  sum_right = prev_sum_right;

	  ptr_left -= width; ptr_right -= width;

	  for (i = 0; i < x_window_size; i++) {
	    left_pix = (double) *(ptr_left);
	    right_pix = (double) *(ptr_right);
   
	    /* subtract first row of previous window */
	    sum -= left_pix * right_pix;
	    sum_left -= left_pix * left_pix;
	    sum_right -= right_pix * right_pix;

	    ptr_left ++;
	    ptr_right ++;
	  }

	  ptr_left = left_corner + (y_window_size - 1) * width;
	  ptr_right = right_corner + (y_window_size - 1) * width;

	  for (i = 0; i < x_window_size; i++) {
	    left_pix = (double) *(ptr_left);
	    right_pix = (double) *(ptr_right);
	
	    /* add new last column */
	    sum += left_pix * right_pix;
	    sum_left += left_pix * left_pix;
	    sum_right += right_pix * right_pix;

	    ptr_left ++;
	    ptr_right ++;
	  } /* for i */

	  prev_sum = sum;
	  prev_sum_left = sum_left;
	  prev_sum_right = sum_right;

	} else {
	  ptr_left--; ptr_right--;

	  for (i = 0; i < y_window_size; i++) {
	    left_pix = (double) *(ptr_left);
	    right_pix = (double) *(ptr_right);

	    /* subtract first column of previous window */
	    sum -= left_pix * right_pix;
	    sum_left -= left_pix * left_pix;
	    sum_right -= right_pix * right_pix;

	    ptr_left += x_window_size;
	    ptr_right += x_window_size;

	    left_pix = (double) *(ptr_left);
	    right_pix = (double) *(ptr_right);
	      
	    /* add new last column */
	    sum += left_pix * right_pix;
	    sum_left += left_pix * left_pix;
	    sum_right += right_pix * right_pix;

	    ptr_left += incr;
	    ptr_right += incr;

	  } /* for i */
	} /* if */

	den = sqrt (sum_left * sum_right);
	
	if (den != 0)  
	  ncc = (sum) / den;
	else 
	  ncc = 0;

	if (ncc > *(max_array + width * y + left_x)) {
	  *(disparity + width * y + left_x) = disp; /*- min_disparity;*/
	  *(max_array + width * y + left_x) = ncc;
	} /* if */

	left_corner++;
	right_corner++;
      } /* for left_x */
    } /* for y*/
  } /* for disparity */
  printf("\n");
} /* match_NCC_left */

#define	MATCH_RIGHT	match_NCC_right
#define MATCH_LEFT      match_NCC_left

#ifndef STANDALONE 
#include	"glue.c"
#endif

