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
#define COUNT_TABLE_BITS 256

void calc_table (int N, long int start, long int end, unsigned char *table, unsigned char count) {

  /*printf("%d\t%d\t%d\t%d\n",N,start,end,count);*/
  if (N == 1) {
    *(table + start) = count;

  } else {
    calc_table (N/2, start, start + (end-start+1)/2 - 1, table, count);
    calc_table (N/2, start + (end-start+1)/2, end, table, count + 1);
  }
} /* calc_table */

void print_table(unsigned char *count_table, int N) {
  int i;
  for (i=0; i<N; i++)
    printf("%d\t%d\n",i,*(count_table+i));
}

void census_transform (unsigned char *image, int x_window_size, int y_window_size, int width, int height, int num_buffs, int size_buff, long int *census_tx) {
  int i, j, x_surround, y_surround, top, bottom, left, right, x, y, incr, index, k;
  unsigned char *image_row_ptr, *pix_ptr, *top_corner, centre_val;
  long int *census_ptr;

  x_surround = (x_window_size - 1) / 2; 
  y_surround = (y_window_size - 1) / 2;
  top = y_surround;
  left = x_surround;
  right = width - x_surround;
  bottom = height - y_surround;
  incr = width - x_window_size;

  image_row_ptr = image;

  for (y = top; y < bottom; y++) {
    census_ptr = census_tx + (y * width + left) * num_buffs;
    top_corner = image_row_ptr;

    for (x = left; x < right; x++) {
      pix_ptr =  top_corner;
      centre_val = *(top_corner + width * y_surround + x_surround);
	      
      /* initialise census transform to 0 */
      for (i = 0; i < num_buffs; i++) 
	  *(census_ptr + i) = 0;

      k = 0;
      for (i = 0; i < y_window_size; i++) {
	for (j = 0; j < x_window_size; j++) {   
	  index = k / size_buff;
	  *(census_ptr + index) <<= 1;
	  if (*pix_ptr < centre_val)
	    *(census_ptr + index) |= 1;
	  pix_ptr++;
	  k++;
	} /* for j */
	pix_ptr += incr;
      } /* for i */	

      top_corner++;
      census_ptr += num_buffs;
    } /* for x */

    image_row_ptr += width;
  } /* for */
} /* census_transform */

void CENSUS_RIGHT (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_census_win_size, int y_census_win_size, int x_window_size, int y_window_size, int min_disparity, int max_disparity) {
  unsigned int right_x;
  int right_lim, left_lim, y, i, top, bottom, left, right, x_surround, y_surround, diff, num_buffs, extra_bits, size_buff, div_buffs, index, u, v, incr, x_surr1, y_surr1;
  long int *census_left, *census_right, *ptr_censusl, *ptr_censusr, census_l, census_r, bit_left, bit_right, *buff_r, *buff_l, *lptr, *rptr, xor_res;
  int disp;

  double d; unsigned int ind;
  unsigned char *count_table;

  count_table = (unsigned char*) CALLOC(256, sizeof(unsigned char));
  calc_table (COUNT_TABLE_BITS, 0, COUNT_TABLE_BITS-1, count_table, 0);
  /* print_table(count_table,COUNT_TABLE_BITS); */

  size_buff = sizeof(long int) * 8;
  div_buffs = (x_census_win_size * y_census_win_size) / size_buff;
  extra_bits = (x_census_win_size * y_census_win_size) % size_buff;
  num_buffs = div_buffs + ((extra_bits > 0)?1:0);

  buff_l = (long int*) CALLOC(num_buffs, sizeof(long int));
  buff_r = (long int*) CALLOC(num_buffs, sizeof(long int));

  census_left = (long int*) CALLOC(width * height * num_buffs, sizeof(long int));
  census_transform (left_image, x_census_win_size, y_census_win_size, width, height, num_buffs, size_buff, census_left);
  census_right = (long int*) CALLOC(width * height * num_buffs, sizeof(long int));
  census_transform (right_image, x_census_win_size, y_census_win_size, width, height, num_buffs, size_buff, census_right);

  x_surround = (x_window_size - 1) / 2; 
  y_surround = (y_window_size - 1) / 2;
  x_surr1 = x_surround + x_census_win_size/2; 
  y_surr1 = y_surround + y_census_win_size/2;
  top = y_surr1;
  left = x_surr1;
  right = width - x_surr1;
  bottom = height - y_surr1;
  incr = (width - x_window_size) * num_buffs;

  /* Set minimum array to a really large number */
  for (i = 0; i < width * height; i++)
    min_array[i] = 1E10;

  for (disp = min_disparity; disp < max_disparity; disp++) {
#ifndef STANDALONE
    fprintf (stderr, "%d ",disp);
#else
    printf ("%d\n",disp);
#endif
 
    for (y = top; y < bottom; y++) {

      if (disp < 0) {
	ptr_censusl =  census_left + ((y - y_surround) * width + x_surr1 - x_surround) * num_buffs;
	ptr_censusr = census_right + ((y - y_surround) * width - disp + x_surr1 - x_surround) * num_buffs;

      } else { 
	ptr_censusl =  census_left + ((y - y_surround) * width + disp + x_surr1 - x_surround) * num_buffs;  
	ptr_censusr = census_right + ((y - y_surround) * width + x_surr1 - x_surround) * num_buffs;
      }

      right_lim = (disp < 0)? right : right - disp;
      left_lim = (disp < 0)? left - disp : left;
      /*printf("%d\n",y);*/

      for (right_x = left_lim; right_x < right_lim; right_x++) { 

	lptr = ptr_censusl;
	rptr = ptr_censusr;

	diff = 0;
	for (u = 0; u < y_window_size; u++) {
	  for (v = 0; v < x_window_size * num_buffs; v++) {
	
	    census_l = *lptr;
	    census_r = *rptr;

	    xor_res = census_l ^ census_r;
	    for (i = 0; i < sizeof(long int); i++) {
	      diff += *(count_table + (xor_res & 0x00ff));
	      xor_res >> 8;
	    }

	    /*	    for (i = 0; i < size_buff; i++) 
	      if (xor_res & (1 << i))
		diff ++; */

	    /*	    d = log10(2);
	    while (xor_res != 0) {
	      xor_res -= pow (2, floor (log10(xor_res) / d));
	      diff++;
	    }*/
		
	    lptr ++;
	    rptr ++;
	  } /* for v */
	  
	  lptr += incr;
	  rptr += incr;
	} /* for u */
	
	if (diff < *(min_array + width * y + right_x)) {
	  *(disparity + width * y + right_x) = (unsigned char) disp; /* - min_disparity; */
	  *(min_array + width * y + right_x) = diff;
	} /* if */

	ptr_censusl += num_buffs;
	ptr_censusr += num_buffs;
      } /* for right_x */
    } /* for y*/
  } /* for disparity */

#ifdef STANDALONE
  free (count_table);
  free (buff_l); free(buff_r);
  free (census_left); free(census_right);
#endif

  printf("\n");
} /* CENSUS_RIGHT */

void CENSUS_LEFT (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_census_win_size, int y_census_win_size, int x_window_size, int y_window_size, int min_disparity, int max_disparity) {
  unsigned int left_x, xor_res;
  int right_lim, left_lim, y, i, j, top, bottom, left, right, x_surround, y_surround, diff, num_buffs, extra_bits, size_buff, div_buffs, k, index, u, v, incr, x_surr1, y_surr1;
  long int *census_left, *census_right, *ptr_censusl, *ptr_censusr, census_l, census_r, bit_left, bit_right, *buff_r, *buff_l, *lptr, *rptr;  
  unsigned char *count_table;
  int disp;

  count_table = (unsigned char*) CALLOC(COUNT_TABLE_BITS, sizeof(unsigned char));
  calc_table (COUNT_TABLE_BITS, 0, COUNT_TABLE_BITS-1, count_table, 0);

  size_buff = sizeof(long int) * 8;
  div_buffs = (x_census_win_size * y_census_win_size) / size_buff;
  extra_bits = (x_census_win_size * y_census_win_size) % size_buff;
  num_buffs = div_buffs + ((extra_bits > 0)?1:0);

  buff_l = (long int*) CALLOC(num_buffs, sizeof(long int));
  buff_r = (long int*) CALLOC(num_buffs, sizeof(long int));

  census_left = (long int*) CALLOC(width*height*num_buffs, sizeof(long int));
  census_transform (left_image, x_census_win_size, y_census_win_size, width, height, num_buffs, size_buff, census_left);
  census_right = (long int*) CALLOC(width*height*num_buffs, sizeof(long int));
  census_transform (right_image, x_census_win_size, y_census_win_size, width, height, num_buffs, size_buff, census_right);
 
  x_surround = (x_window_size - 1) / 2; 
  y_surround = (y_window_size - 1) / 2;
  x_surr1 = x_surround + x_census_win_size/2; 
  y_surr1 = y_surround + y_census_win_size/2;
  top = y_surr1;
  left = x_surr1;
  right = width - x_surr1;
  bottom = height - y_surr1;
  incr = (width - x_window_size) * num_buffs;

  for (i = 0; i < width * height; i++)
    min_array[i] = 1E10;

  for (disp = min_disparity; disp < max_disparity; disp++) {
#ifndef STANDALONE
    printf ("%d ",disp);
#else
    printf ("%d\n",disp);
#endif
    
    for (y = top; y < bottom; y++) {

      if (disp < 0) {
	ptr_censusl =  census_left + ((y - y_surround) * width + x_surr1 - x_surround) * num_buffs;
	ptr_censusr = census_right + ((y - y_surround) * width - disp + x_surr1 - x_surround) * num_buffs;
      } else { 
	ptr_censusl =  census_left + ((y - y_surround) * width + disp + x_surr1 - x_surround) * num_buffs;  
	ptr_censusr = census_right + ((y - y_surround) * width + x_surr1 - x_surround) * num_buffs;
      }

      right_lim = (disp < 0)? right + disp : right;
      left_lim = (disp < 0)? left : left + disp;

      for (left_x = left_lim; left_x < right_lim; left_x++) { 

	lptr = ptr_censusl;
	rptr = ptr_censusr;

	diff = 0;
	for (u = 0; u < y_window_size; u++) {
	  for (v = 0; v < x_window_size * num_buffs; v++) {
	
	    census_l = *lptr;
	    census_r = *rptr;

	    xor_res = census_l ^ census_r;
	    for (i = 0; i < sizeof(long int); i++) {
		diff += *(count_table + (xor_res & 0x00ff));
		xor_res >> 8;
	    }

	    lptr++;
	    rptr++;
	  } /* for v */
	  
	  lptr += incr;
	  rptr += incr;
	} /* for u */

	if (diff < *(min_array + width * y + left_x)) {
	  *(disparity + width * y + left_x) = (unsigned char) disp; /* - min_disparity;*/
	  *(min_array + width * y + left_x) = diff;
	} /* if */

	ptr_censusl += num_buffs;
	ptr_censusr += num_buffs;
      } /* for left_x */
    } /* for y*/
  } /* for disparity */

#ifdef STANDALONE
  free (count_table);
  free (buff_l); free(buff_r);
  free (census_left); free(census_right);
#endif

  printf("\n");
} /* match_CENSUS_left */

#define BUFLEN 100

#ifndef STANDALONE

void mexFunction(
		 int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  double *left_image;
  double *right_image;
  double *window_size;
  double *census_window_size;
  double *disprange; 
  double *disparity;
  double *scores;
  char *left_right;

  unsigned int left_image_cols, left_image_rows, right_image_rows, right_image_cols;
  int x_win_size, y_win_size, i, j, dispmin, dispmax, status, x_census_win_size, y_census_win_size;
  unsigned char *leftI, *rightI, *leftI_ptr, *rightI_ptr;
  signed char *dispI;
  double *scoresD, *scores_ptr, *disp_ptr;

  /* Check for proper number of arguments */
  if (nrhs != 6) {
    mexErrMsgTxt("[Disparity Scores]= CENSUS(left_image,right_image,left-right,census_win_size,window_size, [min_disparity max_disparity])"); }
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

  census_window_size = mxGetPr(prhs[3]);
  if (mxGetM(prhs[3]) * mxGetN(prhs[3]) > 1) {
	x_census_win_size = (int)census_window_size[0];
	y_census_win_size = (int)census_window_size[1];
  } else {
	x_census_win_size = y_census_win_size = (int)census_window_size[0];
  }

  window_size = mxGetPr(prhs[4]);
  if (mxGetM(prhs[4]) * mxGetN(prhs[4]) > 1) {
	x_win_size = (int)window_size[0];
	y_win_size = (int)window_size[1];
  } else {
	x_win_size = y_win_size = (int)window_size[0];
  }

  disprange = mxGetPr(prhs[5]);
  if (mxGetM(prhs[5]) * mxGetN(prhs[5]) > 1) {
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
  printf("Window size: %d x %d, Census window: %d x %d, disparity: %d - %d\n", x_win_size, y_win_size, x_census_win_size, y_census_win_size, dispmin, dispmax);
  
  if (left_right[0] == 'r')
    CENSUS_RIGHT (leftI, rightI, dispI, scoresD, left_image_cols, left_image_rows, x_census_win_size, y_census_win_size, x_win_size, y_win_size, dispmin, dispmax);

  else if (left_right[0] == 'l')
    CENSUS_LEFT (leftI, rightI, dispI, scoresD, left_image_cols, left_image_rows, x_census_win_size, y_census_win_size, x_win_size, y_win_size, dispmin, dispmax);

  /* Transpose result matrices */
  disp_ptr = disparity;

  for (i = 0; i < left_image_cols; i++) 
    for (j = 0; j < left_image_rows; j++) 
      *(disp_ptr++) = (double) *(dispI + j*left_image_cols + i);

  if (nlhs == 2) { 
    scores_ptr = scores;
    for (i = 0; i < left_image_cols; i++) 
      for (j = 0; j < left_image_rows; j++) 
      *(scores_ptr++) = *(scoresD + j*left_image_cols + i);
  }
} /* mexFunction */

#endif
