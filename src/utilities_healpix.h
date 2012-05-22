#ifndef _utilities_healpix_H
#define _utilities_healpix_H

#include <stdlib.h>
#include <stdio.h>
#include "chealpix.h"
#include "utilities_pointing.h"

/* Public function declarations */

#define STOKES_I 0
#define STOKES_Q 1
#define STOKES_U 2
#define I1      0  /* 1st derivative of I wrt theta. */
#define I2      1  /* 1st derivative of I wrt phi. */
#define Q1      2  /* 1st derivative of Q wrt theta. */
#define Q2      3  /* 1st derivative of Q wrt phi. */
#define U1      4  /* 1st derivative of U wrt theta. */
#define U2      5  /* 1st derivative of U wrt phi. */
#define I11     0  /* 2nd derivative of I wrt theta, theta. */
#define I22     1  /* (2nd deriv of I wrt phi, phi)/sin(theta)^2. */
#define U12     2  /* (2nd deriv of U wrt phi, theta)/sin(theta). */
#define Q11     3  /* 2nd derivative of Q wrt theta, theta. */
#define Q22     4  /* (2nd deriv of Q wrt phi, phi)/sin(theta)^2. */
#define Q12     5  /* (2nd deriv of Q wrt phi, theta)/sin(theta). */
#define U11     6  /* 2nd derivative of U wrt theta, theta. */
#define U22     7  /* (2nd deriv of U wrt phi, phi)/sin(theta)^2. */
#define I12     8  /* (2nd deriv of I wrt phi, theta)/sin(theta). */

typedef struct
{
  char ordering;  /* Ordering of maps. 'RING' or 'NEST'. */
  char coordsys;  /* Coordinate system of maps. 'G', 'E', 'C'. */
  char units;     /* Units of maps. */
  long nside;     /* Map nside. Number of pixels = 12.nside^2. Synfast fits NSIDE keyword. */
  int polar;      /* Polarization included. 1 or 0.            Synfast fits POLAR keyword. */
  int deriv;      /* Derivatives included. 0, 1 or 2.          Synfast fits DERIV keyword. */

  float *IQU;    /* Total intensity I map and Stokes Q U maps. */

  float *dIQU;  /* First spatial derivatives of total intensity I
		    map and Stokes Q U maps. */

  float *d2IQU; /* Second spatial derivatives of total intensity I
		    map and Stokes Q U maps. */

} HEALPIXMAP;

void healpixMap_Read(HEALPIXMAP *M, char *infile);
//void healpixMap_Write(HEALPIXMAP M, char *outfile);
void healpixMap_Init(HEALPIXMAP *M, long nside, char ordering, char coordsys,
		     int polar, int deriv);
void healpixMap_Free(HEALPIXMAP *M);
void get_healpix_pixelnumbers_ring(double ra_rad[],double dec_rad[],
				   long int nsample, long int nside,
				   long int *ipix);

//void healpixMap_Allocate_IQU(HEALPIXMAP *M);
//void healpixMap_Allocate_dIQU(HEALPIXMAP *M);
//void healpixMap_Allocate_d2IQU(HEALPIXMAP *M);

#endif
