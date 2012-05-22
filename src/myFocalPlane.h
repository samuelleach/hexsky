
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


typedef struct
{
  int ndet;
  double *phi;
  double *theta;
  double *beam;

} FRQCHANNEL;

typedef struct
{
  int nchan;
  FRQCHANNEL *chan;

} FPLANE;


// general

int setFocalPlane( void *inParams, FPLANE *focalPlane, char *expt);
int destroyFocalPlaneStruct( FPLANE *focalPlane);

// EBEx specific

int EBEx_setFocalPlane( EBEX_PARAMETERS *inParams, FPLANE *focalPlane);
int setupfocalplane_horizontal_new( int freq, double *focalplaneazsteps, double *focalplaneelsteps);
