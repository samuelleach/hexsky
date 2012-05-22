
#include "prandom.h"

#define max( x, y) ((x) > (y) ? (x) : (y))
#define min( x, y) ((x) < (y) ? (x) : (y))
#define sgn( x)    ((x) < (0) ? (-1) : (1))

int get_reconstruction_errors( int opt, int n, double starSigma2, double gyroSigma2, double *errorsAZ, double *errorsEL);
