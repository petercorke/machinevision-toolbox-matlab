typedef unsigned char pixel;

struct pgm {
  int width;
  int height;
  int max_grey;
  pixel *bitmap;		/* bitmap of grey values */
  double *means;
}; /* pgm */

int read_pgm (FILE *fp, struct pgm *image);
void write_pgm_ascii (FILE *outfile, struct pgm *image);
void write_pgm_binary (FILE *outfile, struct pgm *image);
