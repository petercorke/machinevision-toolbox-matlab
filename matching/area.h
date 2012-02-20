void match_SAD_right (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *scores, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void match_SSD_right (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *max_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void match_NCC_right (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *max_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void match_ZSAD_right (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void match_ZSSD_right (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void match_ZNCC_right (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void rank_transform (unsigned char *image, int x_window_size, int y_window_size, int width, int height, unsigned char *rank_tx);

void CENSUS_RIGHT (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_census_win_size, int y_census_win_size, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void match_SAD_left (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *scores, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void match_SSD_left (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *max_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void match_NCC_left (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *max_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void match_ZSAD_left (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void match_ZSSD_left (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void match_ZNCC_left (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void CENSUS_LEFT (unsigned char *left_image, unsigned char *right_image, signed char *disparity, double *min_array, int width, int height, int x_census_win_size, int y_census_win_size, int x_window_size, int y_window_size, int min_disparity, int max_disparity);

void left_right (signed char *left_disp, signed char *right_disp, signed char *left_disp_valid, signed char *right_disp_valid, int width, int height, int x_border, int y_border);
