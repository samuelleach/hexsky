
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "ebex_parameters.h"
#include "utilities_parameters.h"
#include "utilities_gnuplot.h"
#include "pointing_library.h"
#include "ebex_scanning.h"
#include "ebex_focalplane.h"
#include "ebex_gondola.h"
#include "prandom.h"
#include "reconstructErrors.h"

double getSamplingRate( void *inParams, char *expt);
