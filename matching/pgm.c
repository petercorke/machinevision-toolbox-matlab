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
/*
Functions for reading and writing pgm files.

Reading doesn't handle comments, need to delete them first.

Author: Jasmine Banks
Date:   8/97
 */

#include <stdio.h>
#include "pgm.h"

int read_num (FILE *fp) {
  char c;
  int num, finished=0;

  do {
    c = getc (fp);
    if (c == '#')
      while ((c = getc(fp)) != '\n');

    else if ((c >= '0') && (c <= '9')) {
      ungetc (c, fp);
      fscanf (fp, "%d", &num);
      finished = 1;
    } 
  } while (!finished);
  return num;
}/* read_num */

/********************************************************************************
Reads a binary pgm file into the image struct                               
Doesn't deal with comment lines as yet                                      
********************************************************************************/
int read_pgm (FILE *fp, struct pgm *image) {
  int read_num (FILE* fp);
  char str[2];
  int i;

  fscanf (fp, "%c", str);
  fscanf (fp, "%c", (str+1));
  
  if ((str[0] == 'P') && (str[1] == '5')) {
	  
    image->width = read_num (fp);
    image->height = read_num (fp);
    image->max_grey = read_num (fp);

    if ((image->bitmap = (pixel*) calloc (image->width * image->height, 1)) == NULL) {
      perror ("Not enough memory");
      return (2);
    } /* if */

    fgetc (fp);	/* Read single whitespace char */
    
    for (i = 0; i < image->width * image->height; i++)
      fscanf (fp, "%c", (image->bitmap + i));
  } else {
    perror ("Not a pgm file");
    return (1);
  }
  return (0);
} /* read_pgm */


void write_pgm_ascii (FILE *outfile, struct pgm *image) {
  int i, j;

  fprintf (outfile, "P2\n");
  fprintf (outfile, "%u %u\n", image->width, image->height);
  fprintf (outfile, "%u\n", image->max_grey);
  
  for (i = 0; i < image->height; i++) {
    for (j = 0; j < image->width; j++)
      fprintf (outfile, "%u ", *(image->bitmap + i * image->width + j));
    fprintf (outfile, "\n");
  } /* for i */
} /* output_disparity */

void write_pgm_binary (FILE *outfile, struct pgm *image) {
  int i, j;

  fprintf (outfile, "P5\n");
  fprintf (outfile, "%u %u\n", image->width, image->height);
  fprintf (outfile, "%u\n", image->max_grey);
  
  for (i = 0; i < image->height; i++) 
    for (j = 0; j < image->width; j++)
      fprintf (outfile, "%c", *(image->bitmap + i * image->width + j));
} /* output_disparity */

