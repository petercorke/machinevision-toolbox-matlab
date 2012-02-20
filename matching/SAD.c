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

void match_SAD_right (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *scores, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity) {
  unsigned int x, y, x_surround, y_surround, i, j, offsetx, right_x, top, bottom, left, right, incr, sum, prev_sum, diff, *min_array;
  unsigned char *left_corner, *right_corner, *ptr_left, *ptr_right;
  unsigned int left_pix, right_pix;

  int disp, t, right_lim, left_lim;

  x_surround = (x_window_size - 1) / 2;  
  y_surround = (y_window_size - 1) / 2;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;
  incr = width - x_window_size;

  min_array = (unsigned int *) CALLOC (width * height, sizeof(unsigned int));
  for (i = 0; i < width * height; i++)
    min_array[i] = 0xffffffff;

  for (disp = min_disparity; disp <= max_disparity; disp++) {
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
      right_lim = (disp < 0)? right : right - disp;
      left_lim = (disp < 0)? left - disp : left;

      for (right_x = left_lim; right_x < right_lim; right_x++) { 
	ptr_left = left_corner;
	ptr_right = right_corner;

	if ((y == top) && (right_x == left_lim)) { /* If top left hand corner */
	  for (i = 0; i < y_window_size; i++) {
	    for (j = 0; j < x_window_size; j++) {
	      left_pix = (unsigned int) *ptr_left;
	      right_pix = (unsigned int) *ptr_right;

	      t = right_pix - left_pix;
	      sum +=  (t > 0)? t:-t;
		
	      ptr_left++;
	      ptr_right++;
	    } /* for j */

	    ptr_left += incr;
	    ptr_right += incr;
	  } /* for i */
	  
	  prev_sum = sum;
	    
	} else if (right_x == left_lim) { /* if left pixel in row */
	
	  sum = prev_sum;

	  ptr_left -= width; ptr_right -= width;

	  /* subtract first row of previous window */
	  for (i = 0; i < x_window_size; i++) {
	    left_pix = (unsigned int) *(ptr_left);
	    right_pix = (unsigned int) *(ptr_right);

	    t = right_pix - left_pix;
	    sum -= (t > 0)? t:-t;

	    ptr_left ++;
	    ptr_right ++;
	  }

	  ptr_left = left_corner + (y_window_size - 1) * width;
	  ptr_right = right_corner + (y_window_size - 1) * width;
	  
	  /* add new last row */
	  for (i = 0; i < x_window_size; i++) {
	    left_pix = (unsigned int) *(ptr_left);
	    right_pix = (unsigned int) *(ptr_right);

	    t = right_pix - left_pix;
	    sum += (t > 0)? t:-t;

	    ptr_left ++;
	    ptr_right ++;
	  } /* for i */
	    
	  prev_sum = sum;
	  
	} else {
	  ptr_left--; ptr_right--;

	  for (i = 0; i < y_window_size; i++) {
	    left_pix = (unsigned int) *(ptr_left);
	    right_pix = (unsigned int) *(ptr_right);

	    /* subtract first column of previous window */
	    t = right_pix - left_pix;
	    sum -= (t > 0)? t:-t;

	    ptr_left += x_window_size;
	    ptr_right += x_window_size;

	    left_pix = (unsigned int) *(ptr_left);
	    right_pix = (unsigned int) *(ptr_right);
      
	    /* add new last column */
	    t = right_pix - left_pix;
	    sum += (t > 0)? t:-t;
	      
	    ptr_left += incr;
	    ptr_right += incr;

	  } /* for i */
	} /* if */

	if (sum < *(min_array + width * y + right_x)) {
	  *(disparity + width * y + right_x) = disp; /* - min_disparity; */
	  *(min_array + width * y + right_x) = sum;
	} /* if */

	left_corner++;
	right_corner++;
      
      } /* for right_x */
    } /* for y*/
  } /* for disparity */
  printf("\n");
  
  for (i = 0; i < width * height; i++)
    *(scores + i) = (double) *(min_array + i);

#ifdef STANDALONE
  free(min_array);
#endif
} /* match_SAD_right */

void match_SAD_left (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *scores, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity) {
  unsigned int x, y, x_surround, y_surround, i, j, offsetx, left_x, top, bottom, left, right, incr, sum, prev_sum, diff, *min_array;
  unsigned char *left_corner, *right_corner, *ptr_left, *ptr_right;
  unsigned int left_pix, right_pix;

  int disp, t, right_lim, left_lim;

  x_surround = (x_window_size - 1) / 2;  
  y_surround = (y_window_size - 1) / 2;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;
  incr = width - x_window_size;

  min_array = (unsigned int *) CALLOC (width * height, sizeof(unsigned int));
  for (i = 0; i < width * height; i++)
    min_array[i] = 0xffffffff;

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
      right_lim = (disp < 0)? right + disp : right;
      left_lim = (disp < 0)? left : left + disp;

      for (left_x = left_lim; left_x < right_lim; left_x++) { 
	ptr_left = left_corner;
	ptr_right = right_corner;

	if ((y == top) && (left_x == left_lim)) { /* If top left hand corner */
	  for (i = 0; i < y_window_size; i++) {
	    for (j = 0; j < x_window_size; j++) {
	      left_pix = (unsigned int) *ptr_left;
	      right_pix = (unsigned int) *ptr_right;

	      t = right_pix - left_pix;
	      sum +=  (t > 0)? t:-t;
		
	      ptr_left++;
	      ptr_right++;
	    } /* for j */

	    ptr_left += incr;
	    ptr_right += incr;
	  } /* for i */
	  
	  prev_sum = sum;
	    
	} else if (left_x == left_lim) { /* if left pixel in row */
	
	  sum = prev_sum;

	  ptr_left -= width; ptr_right -= width;

	  /* subtract first row of previous window */
	  for (i = 0; i < x_window_size; i++) {
	    left_pix = (unsigned int) *(ptr_left);
	    right_pix = (unsigned int) *(ptr_right);

	    t = right_pix - left_pix;
	    sum -= (t > 0)? t:-t;

	    ptr_left ++;
	    ptr_right ++;
	  }

	  ptr_left = left_corner + (y_window_size - 1) * width;
	  ptr_right = right_corner + (y_window_size - 1) * width;
	  
	  /* add new last row */
	  for (i = 0; i < x_window_size; i++) {
	    left_pix = (unsigned int) *(ptr_left);
	    right_pix = (unsigned int) *(ptr_right);

	    t = right_pix - left_pix;
	    sum += (t > 0)? t:-t;

	    ptr_left ++;
	    ptr_right ++;
	  } /* for i */
	    
	  prev_sum = sum;
	  
	} else {
	  ptr_left--; ptr_right--;

	  for (i = 0; i < y_window_size; i++) {
	    left_pix = (unsigned int) *(ptr_left);
	    right_pix = (unsigned int) *(ptr_right);

	    /* subtract first column of previous window */
	    t = right_pix - left_pix;
	    sum -= (t > 0)? t:-t;

	    ptr_left += x_window_size;
	    ptr_right += x_window_size;

	    left_pix = (unsigned int) *(ptr_left);
	    right_pix = (unsigned int) *(ptr_right);
	      
	    /* add new last column */
	    t = right_pix - left_pix;
	    sum += (t > 0)? t:-t;
	      
	    ptr_left += incr;
	    ptr_right += incr;

	  } /* for i */
	} /* if */

	if (sum < *(min_array + width * y + left_x)) {
	  *(disparity + width * y + left_x) = disp; /* - min_disparity;*/
	  *(min_array + width * y + left_x) = sum;
	} /* if */

	left_corner++;
	right_corner++;
      
      } /* for left_x */
    } /* for y*/
  } /* for disparity */
  printf("\n");

  for (i = 0; i < width * height; i++)
    *(scores + i) = (double) *(min_array + i);

#ifdef STANDALONE
  free(min_array);
#endif
} /* match_SAD_left */

#define MATCH_RIGHT     match_SAD_right
#define	MATCH_LEFT	match_SAD_left

#ifndef STANDALONE 
#include	"glue.c"
#endif
