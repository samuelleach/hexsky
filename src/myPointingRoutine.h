
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

#if MPI
#include "mpi.h"
#endif

typedef struct
{
   long nel;      /* # of vector elements */
   double *tme;   /* times of the data points */
   double *cor;   /* path coordinate */
   double *vel;   /* corresponding velocity component */
} PATTCOORD;

typedef struct
{
   int type;      /* pattern id */
   double itime;  /* initial time */
   double dtime;  /* duration time */
   double phi;    /* path position */
   double theta;  /* path position */
   double psi;    /* path orientation */
} SCANPATH;

typedef struct
{
   double dtime;     /* pattern time */
   PATTCOORD phi;    /* the azimuthal spherical coordinate of the pattern */
   PATTCOORD theta;  /* the polar speherical coordinate of the scan pattern */
} SPATTERN;

typedef struct
{
   double itime;       /* initial time of the sky scan */
   double dtime;       /* duration of the sky scan */
   int npttrn;         /* # of distinct scan patterns */
   SPATTERN *pattern;  /* scan pattern description */
   int npath;          /* # of scan paths in the full scan */
   SCANPATH *spath;    /* scan path definition */
} SKYSCAN;

// general

int initScanStruct(void *params, SKYSCAN *skyScan, char *expt);
int destroyScanStruct( SKYSCAN *skyScan);

int getNumPatterns( void *inParams, char *expt);
int getNumScanPaths( void *inParams, char *expt);
int getNumSampPerPattern( void *inParams, int ipttrn, int npttrn, int *nsamp, char *expt);
int setScanPatterns( void *inParams, int npttrn, SPATTERN *pattern, char *expt);
int setScanPaths( void *inParams, int firstPath, int npaths, double pathTime, SCANPATH *path, char *expt);
int setSkyScan( void *inParams, int npttrn, int firstPath, int npaths, SKYSCAN *currentSkyScan, char *expt);
int getPointing( double firstSample, double lastSample, double sampRate, double *ra, double *dec, SKYSCAN currentSkyScan, char *expt);

// EBEx specific to be moved somewhere else

int EBEx_getNumPatterns( EBEX_PARAMETERS *inParams);
int EBEx_getNumScanPaths( EBEX_PARAMETERS *inParams);
int EBEx_getNumSampPerPattern( EBEX_PARAMETERS *inParams, int ipttrn, int npttrn, int *nsamp);
int EBEx_setScanPatterns( EBEX_PARAMETERS *inParams, int npttrn, SPATTERN *pattern);
int EBEx_setScanPaths( EBEX_PARAMETERS *inParams, int firstPath, int npaths, double pathTime, SCANPATH *path);
int EBEx_setSkyScan( EBEX_PARAMETERS *inParams, int npttrn, int firstPath, int npaths, SKYSCAN *currentSkyScan);
int EBEx_getPointing( double firstSample, double lastSample, double sampRate, double *ra, double *dec, SKYSCAN currentSkyScan);
