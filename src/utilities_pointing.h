#ifndef _utilities_pointing_H
#define _utilities_pointing_H

#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#define PI            3.14159265359
#define PIBYTWO       1.5707963268
#define TWOPI         6.28318530718
/* PI/180. */
#define DEG2RAD       1.74532925199e-2
#define DEG2HR        6.66666666667e-2 /* 1/15 */
#define SEC2HR        2.77777777778e-4 /* 1/3600 */
#define HR2SEC        3600.99999999    /* 3600 */
#define SEC2DAY       1.15740740741e-5 /* 1/3600/24 */
#define DAY2SEC       8.64000000000e4  /* 3600*24 */
#define HR2RAD        2.61799387800e-1 /* 15*PI/180 */
#define RAD2HR        3.81971863e0     /* 12/PI */
#define ARCMIN2RAD    2.90888208665e-4 /* DEG2RAD/60. */ //BUGGY??
//#define ARCMIN2RAD    2.90888208665e-4 //BUGGY?
//#define ARCMIN2RAD    2.90888208e-4 //BUGGY
//#define ARCMIN2RAD    2.908882e-4
#define RAD2ARCMIN    3437.74677078    /* 60/DEG2RAD. */
#define RAD2ARCSEC    2.06264806247e+5 /* 60*60/DEG2RAD. */
#define ARCMIN2DEG    1.66666666667e-2 /* 1/60 */
#define DEG2ARCMIN    60.0000000000    /* 60 */
#define ARCMIN2ARCSEC 60.0000000000    /* 60 */
#define ARCSEC2ARCMIN 1.66666666667e-2 /* 1/60 */
#define ARCSEC2RAD    4.8481368111e-6  /* 2PI/360/60/60 */
#define ARCMIN2DEG    1.66666666667e-2 /* 1/60 */
#define RAD2DEG       5.72957795131e1  /* 180./PI */
#define HR2DEG        15.0000000000    /* 15 */
#define FSKY2SQDEG    41252.9612494    /* 360*360/PI */
#define SQDEG2FSKY    2.42406840555e-5 /* PI/360/360 */
#define RJD0          2.45490e6        /* For calculating a reduced Julian day  */

/* Structure definitions */

typedef struct {
  int year;   // e.g. 2009
  int month;  // 1--12
  int day;    // 1--31 
  double secs;// Seconds since the beginning of the day.
} CIVILTIME;

/* Public functions declarations */
void azel_2_hadec(double az[], double el[], int n, double cosL, double sinL,
		  double *ha, double *dec, double *cosdec);
void azel_2_hadecbeta(double az[], double el[], int n, double cosL, double sinL,
		      double *ha, double *dec, double *beta, double *cosdec); 
void azel_2_hadec_multidetector(double az, double el, double daz[], double cosdel[],
				double sindel[],long int n, double cosL, double sinL,
				double *ha, double *dec, double *cosdec); 
void azel_2_hadec_multidetector_new(double az, double el, double cosdaz[], double sindaz[],
				    double cosdel[], double sindel[], long int n,
				    double cosL, double sinL,
				    double *ha, double *dec, double *cosdec); 
int hadec_2_azel(double HA[],double Dec[],int n, double L,double *az, double *el);
void rael_2_az(double RA, double el, double lst, double cosL, double sinL,double *az);
void determinelst(CIVILTIME ct[], double longitude[], int n, double *LST);
void determinelst_new(CIVILTIME ct[], double longitude[], int n, double *LST);
void jdcnv(CIVILTIME ct[], int n, double *jd);
void jdcnv_new(CIVILTIME ct[], int n, double *jd);
void get_rjd(CIVILTIME ct, double sample_times_sec[],long int numbersamples, double *rjd);
void ha2ra(double ha[], double lst[], long int n, double *ra);
void range(double *v, double r);
void range_fast(double *v, double r);

#endif
