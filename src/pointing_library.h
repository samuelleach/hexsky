#ifndef _pointing_library_H
#define _pointing_library_H

#include "utilities_pointing.h"
#include "utilities_squarepixel.h"
#include "utilities_baselines.h"
#include <stdlib.h>


#define DELTAEL 10.*ARCSEC2RAD
#define DELTAAZ 0.

/* Public functions declarations */

int get_boresight_pointing(long int nrepointings, double repointingAZ[],
			   double repointingEL[],
			   /* Repointing DB.*/
      			   long int nsamplesScan, double scanAZ[],
			   /* Generic scan pattern*/
			   double pendulationAZ[],double pendulationEL[],
			   /* Pendulations, nsamplesScan x nrepointings in length*/
			   double *boresightAZ, double *boresightEL);

int get_boresight_radecbeta(long int nsamples, double boresightAZ[],
			    double boresightEL[],
			    double lst[], double rollPendAngle[],double latitude_rad,
			    /* Precomputed info about LST and pendulation for each sample,
			       and in general all information relating to the orientation
			       of the telescope at each sample.
			    */
			    double *pointingRA, double *pointingDec, double *pointingBeta,
			    double *pointingcosDec);


int get_multi_det_pointing(long int ndetectors, double focalplaneAZ[],
			   double focalplaneEL[],
			   /* Focalplane DB.*/
			   long int nsamples, double boresightAZ[],
			   double boresightEL[],
			   double lst[],double rollPendAngle[], double latitude_rad,
			   /* Precomputed info about LST and in general all
			      information relating to the _orientation_ of the
			      telescope at each sample.
			   */
			   double *pointingRA, double *pointingDec,double *pointingBeta,
			   double *pointingcosDec);

/*Computes a nLast-nInit+1 pointings for a given detector detNum for 
  samples from nInit to nLast.
  If detNum = -1 then you get a pointing of a center of a focal plane, 
  otherwise gets pointing for a selected detector;*/


int interpolate_pointing(long int nsamplesTotal,
			 double centerRA[], double centerDec[],
			 int detnum[], double *detRA, double *detDec);

/*Interpolates the pointing precomputed for the center of the focal plane 
to the pointing of a given detector.
If detRA or detDec NULL then the output overwrites input i.e., centerRA 
and centerDec.
If detNum = -1 but detRA and detDec allocated just copies the input 
vectors to the output.*/

#endif
