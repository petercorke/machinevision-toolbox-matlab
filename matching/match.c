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
/********************************************************************************

Filename: 	match.c

Author: 	J. E. Banks

Program to test various area based matching techniques.

********************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "pgm.h"
#include "area.h"

#define DEFAULT_WINDOW_SIZE   11
#define DEFAULT_TX_WINDOW_SIZE 5
#define DEFAULT_MAX_DISPARITY 100
#define DEFAULT_MIN_DISPARITY 0
#define MIN_ALLOWED_DISPARITY -128
#define MAX_ALLOWED_DISPARITY 127

#define ZERO_DENOM 255

enum match_type {SAD, SSD, NCC, ZSAD, ZSSD, ZNCC, RANK, CENSUS};

struct DISP {
int height;
int width;
int max_grey;
signed char *bitmap;
};

/*******************************************************************************/
int main(int argc, char* argv[]) 
{
  int max_disparity = DEFAULT_MAX_DISPARITY, min_disparity = DEFAULT_MIN_DISPARITY, 
    x_window_size = DEFAULT_WINDOW_SIZE, y_window_size = DEFAULT_WINDOW_SIZE, 
    x_tx_win_size = DEFAULT_TX_WINDOW_SIZE, y_tx_win_size = DEFAULT_TX_WINDOW_SIZE, i,
    border_x, border_y;
  double *scores;
  char basefile[50], outname[50];
  FILE *leftfp, *rightfp, *outfile, *lrfile;
  struct pgm left_image, right_image, disp1;
  struct DISP disparity, left_disparity, lr_valid_left, lr_valid_right;
  pixel *right_rank, *left_rank;
  int offset = 0, lr = 0;
  enum match_type match = SAD;

  if (argc < 2) {
    perror ("Usage: match [-d min_disparity max_disparity] [-m SAD | SSD | NCC | ZSAD | ZSSD | ZNCC | RANK | CENSUS] [-w x_window_size y_window_size] [-t x_tx_win_size y_tx_win_size] [-lr] <base-file> <outputfile>");
    return (1);
  }

  /* process optional args */
  for (i = 1; i < argc - 2; i++) {
    if (strcasecmp (argv[i], "-w") == 0) {
      x_window_size = atoi (argv[++i]);   
      y_window_size = atoi (argv[++i]);  

    } else if (strcasecmp (argv[i], "-t") == 0) {
      x_tx_win_size = atoi (argv[++i]);   
      y_tx_win_size = atoi (argv[++i]);

    } else if (strcasecmp (argv[i], "-o") == 0) { 
      offset = atoi (argv[++i]);

    } else if (strcasecmp (argv[i], "-lr") == 0) {
      lr = 1;
 
    } else if (strcasecmp (argv[i], "-d") == 0) { 
      min_disparity = atoi (argv[++i]);  
      if (min_disparity < MIN_ALLOWED_DISPARITY)
	min_disparity = MIN_ALLOWED_DISPARITY;
      max_disparity = atoi (argv[++i]);
      if (max_disparity > MAX_ALLOWED_DISPARITY)
	max_disparity = MAX_ALLOWED_DISPARITY;

    } else if (strcasecmp (argv[i], "-m") == 0) {
      i++;
      if (strcasecmp (argv[i], "SAD") == 0)
	match = SAD;

      else if (strcasecmp (argv[i], "SSD") == 0) 
	match = SSD;
      
      else if (strcasecmp (argv[i], "NCC") == 0)
	match = NCC;   
  
      else if (strcasecmp (argv[i], "ZSAD") == 0)
	match = ZSAD;

      else if (strcasecmp (argv[i], "ZSSD") == 0) 
	match = ZSSD;
      
      else if (strcasecmp (argv[i], "ZNCC") == 0)
	match = ZNCC;   
  
      else if (strcasecmp (argv[i], "RANK") == 0)
	match = RANK;       

      else if (strcasecmp (argv[i], "CENSUS") == 0)
	match = CENSUS;   

      else {
	perror ("Usage: match [-d max_disparity] [-m SAD | SSD | NCC | ZSAD | ZSSD | ZNCC | RANK] [-w x_window_size y_window_size] [-t x_tx_win_size y_tx_win_size] <base-file> <outputfile>");
	return (1);
      }

    } else { 
      perror ("Usage: match [-d max_disparity] [-m SAD | SSD | NCC | ZSAD | ZSSD | ZNCC | RANK] [-w x_window_size y_window_size] [-t x_tx_win_size y-tx_win_size] <base-file> <outputfile>");
      return (1);
    } /* if */
  } /* for */

  /* Open left image file */
  strcpy (basefile, argv[i]);
  if ((leftfp = fopen (strcat (basefile, "-l.pgm"), "r")) == NULL) {
    perror ("Cannot open file for reading");
    return (2);
  }

  /* Open right image file */
  strcpy (basefile, argv[i]);
  if ((rightfp = fopen (strcat (basefile, "-r.pgm"), "r")) == NULL) {
    perror ("Cannot open file for reading");
    return (2);
  } 

  /* Open output file for writing */
  strcpy (outname, argv[i+1]);
  if ((outfile = fopen (strcat (outname, ".pgm"), "w")) == NULL) {
    perror ("Cannot open file for writing");
    return (3);
  }

  /* Open output file for writing */
  strcpy (outname, argv[i+1]);
  if ((lrfile = fopen (strcat (outname, "_lr.pgm"), "w")) == NULL) {
    perror ("Cannot open file for writing");
    return (3);
  }

  if ((read_pgm (leftfp, &left_image) == 0) && (read_pgm (rightfp, &right_image) == 0)) {
    
    if ((left_image.width != right_image.width) || (left_image.height != right_image.height)) {
      perror ("Images different sizes");
      return (4);
    }
	
    disparity.width = left_image.width;
    disparity.height = left_image.height;
    disparity.max_grey = left_image.max_grey;
    if ((disparity.bitmap = (signed char*) calloc (disparity.width * disparity.height, 1)) == NULL) {
      perror ("Not enough memory");
      return (5);
    }
    if ((scores = (double*) calloc (disparity.width * disparity.height, sizeof(double))) == NULL) {
      perror ("Not enough memory");
      return (5);
    }

    if (lr) { 
      lr_valid_left.width = lr_valid_right.width = left_disparity.width = left_image.width;
      lr_valid_left.height = lr_valid_right.height = left_disparity.height = left_image.height;
      lr_valid_left.max_grey = lr_valid_right.max_grey = left_disparity.max_grey = left_image.max_grey;
      if ((left_disparity.bitmap = (signed char*) calloc (left_disparity.width * left_disparity.height, 1)) == NULL) {
	perror ("Not enough memory");
	return (5);
      }
      if ((lr_valid_right.bitmap = (signed char*) calloc (lr_valid_right.width * lr_valid_right.height, 1)) == NULL) {
	perror ("Not enough memory");
	return (5);
      }
      if ((lr_valid_left.bitmap = (signed char*) calloc (lr_valid_left.width * lr_valid_left.height, 1)) == NULL) {
	perror ("Not enough memory");
	return (5);
      }
    } /* left_right */

    switch (match) {
    case (SAD):  
      puts ("SAD");
      match_SAD_right (left_image.bitmap, right_image.bitmap, disparity.bitmap, scores, left_image.width,
		       left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
      if (lr) {
	match_SAD_left (left_image.bitmap, right_image.bitmap, left_disparity.bitmap, scores, left_image.width, 
			left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
	border_x = x_window_size / 2;
	border_y = y_window_size / 2;
	left_right (left_disparity.bitmap, disparity.bitmap, lr_valid_left.bitmap, lr_valid_right.bitmap,
		    left_image.width, left_image.height, border_x, border_y);
      }
      break;

    case (SSD): 
      puts ("SSD");
      match_SSD_right (left_image.bitmap, right_image.bitmap, disparity.bitmap, scores, left_image.width,
		       left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
      if (lr) {
	match_SAD_left (left_image.bitmap, right_image.bitmap, left_disparity.bitmap, scores, left_image.width, 
			left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
	border_x = x_window_size / 2;
	border_y = y_window_size / 2;
	left_right (left_disparity.bitmap, disparity.bitmap, lr_valid_left.bitmap, lr_valid_right.bitmap,
		    left_image.width, left_image.height, border_x, border_y);
      }
      break;

    case (NCC):
      puts ("NCC");
      match_NCC_right (left_image.bitmap, right_image.bitmap, disparity.bitmap, scores, left_image.width,
		       left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
      if (lr) {
	match_SAD_left (left_image.bitmap, right_image.bitmap, left_disparity.bitmap, scores, left_image.width, 
			left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
	border_x = x_window_size / 2;
	border_y = y_window_size / 2;
	left_right (left_disparity.bitmap, disparity.bitmap, lr_valid_left.bitmap, lr_valid_right.bitmap,
		    left_image.width, left_image.height, border_x, border_y);
      }
      break;

    case(ZSAD):
      puts ("ZSAD");
      match_ZSAD_right (left_image.bitmap, right_image.bitmap, disparity.bitmap, scores, left_image.width,
		       left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
      if (lr) {
	match_SAD_left (left_image.bitmap, right_image.bitmap, left_disparity.bitmap, scores, left_image.width, 
			left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
	border_x = x_window_size / 2;
	border_y = y_window_size / 2;
	left_right (left_disparity.bitmap, disparity.bitmap, lr_valid_left.bitmap, lr_valid_right.bitmap,
		    left_image.width, left_image.height, border_x, border_y);
      }
      break;

    case (ZSSD): 
      puts ("ZSSD");
      match_ZSSD_right (left_image.bitmap, right_image.bitmap, disparity.bitmap, scores, left_image.width,
		       left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
      if (lr) {
	match_SAD_left (left_image.bitmap, right_image.bitmap, left_disparity.bitmap, scores, left_image.width, 
			left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
	border_x = x_window_size / 2;
	border_y = y_window_size / 2;
	left_right (left_disparity.bitmap, disparity.bitmap, lr_valid_left.bitmap, lr_valid_right.bitmap,
		    left_image.width, left_image.height, border_x, border_y);
      }
      break;

    case (ZNCC):
      puts ("ZNCC");
      match_ZNCC_right (left_image.bitmap, right_image.bitmap, disparity.bitmap, scores, left_image.width,
		       left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
      if (lr) {
	match_SAD_left (left_image.bitmap, right_image.bitmap, left_disparity.bitmap, scores, left_image.width, 
			left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
	border_x = x_window_size / 2;
	border_y = y_window_size / 2;
	left_right (left_disparity.bitmap, disparity.bitmap, lr_valid_left.bitmap, lr_valid_right.bitmap,
		    left_image.width, left_image.height, border_x, border_y);
      }
      break;

    case (RANK): 
      puts ("RANK");
      if (((right_rank = (pixel*) calloc (disparity.width * disparity.height, 1)) == NULL) ||
		   ((left_rank = (pixel*) calloc (disparity.width * disparity.height, 1)) == NULL)) {
         perror ("Not enough memory");
	 return (5);
      }
      rank_transform (right_image.bitmap, x_tx_win_size, y_tx_win_size, right_image.width, right_image.height, right_rank);
      rank_transform (left_image.bitmap, x_tx_win_size, y_tx_win_size, left_image.width, left_image.height, left_rank);

      match_SAD_right (left_rank, right_rank, disparity.bitmap, scores, left_image.width,
		       left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
      if (lr) {
	match_SAD_left (left_rank, right_rank, left_disparity.bitmap, scores, left_image.width, 
			left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
	border_x = x_window_size / 2 + x_tx_win_size / 2;
	border_y = y_window_size / 2 + y_tx_win_size / 2;
	left_right (left_disparity.bitmap, disparity.bitmap, lr_valid_left.bitmap, lr_valid_right.bitmap,
		    left_image.width, left_image.height, border_x, border_y);
      }
      free (right_rank);
      free (left_rank);
      break; 

    case (CENSUS): 
      puts ("CENSUS");
      CENSUS_RIGHT (left_image.bitmap, right_image.bitmap, disparity.bitmap, scores, left_image.width, 
		    left_image.height, x_tx_win_size, y_tx_win_size, x_window_size, y_window_size, min_disparity, max_disparity);
      if (lr) {
	match_SAD_left (left_rank, right_rank, left_disparity.bitmap, scores, left_image.width, 
			left_image.height, x_window_size, y_window_size, min_disparity, max_disparity);
	border_x = x_window_size / 2 + x_tx_win_size / 2;
	border_y = y_window_size / 2 + y_tx_win_size / 2;
	left_right (left_disparity.bitmap, disparity.bitmap, lr_valid_left.bitmap, lr_valid_right.bitmap,
		    left_image.width, left_image.height, border_x, border_y);
      }
      break;
    } /* switch */

    /* Copy disparity to unsigned char and write to file */
    disp1.width = disparity.width;
    disp1.height = disparity.height;
    disp1.max_grey = disparity.max_grey;
    disp1.bitmap = (unsigned char*) calloc (disp1.width*disp1.height,sizeof(unsigned char));
    for (i=0; i<disp1.height*disp1.width; i++)
	*(disp1.bitmap+i) = *(disparity.bitmap+i) + min_disparity;
    write_pgm_binary (outfile, &disp1);

    /* Copy lr information to unsigned char and write to file */
    disp1.width = lr_valid_right.width;
    disp1.height = lr_valid_right.height;
    disp1.max_grey = lr_valid_right.max_grey;
    for (i = 0; i < disp1.height*disp1.width; i++)
	*(disp1.bitmap+i) = *(lr_valid_right.bitmap+i) * 255;
    write_pgm_binary (lrfile, &disp1);

    free (left_image.bitmap);
    free (right_image.bitmap);
    free (disparity.bitmap);
    free (disp1.bitmap);
    free (scores);
    if (lr) {
      free (left_disparity.bitmap);
      free (lr_valid_left.bitmap);
      free (lr_valid_right.bitmap);
    }
  } /* if */
				
  fclose (leftfp);
  fclose (rightfp);
  fclose (outfile);
  fclose (lrfile);

  return (0);
} /* main */
