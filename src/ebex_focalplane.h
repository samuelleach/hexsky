#ifndef _ebex_focalplane_H
#define _ebex_focalplane_H

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "utilities_pointing.h"


/* Public function declarations */
 
void setupfocalplane_boresight(double *focalplaneAZ, double *focalplaneEL);
void setupfocalplane_decagon(double *focalplaneAZ, double *focalplaneEL);
void setupfocalplane_ebex(double *focalplaneAZ, double *focalplaneEL);
double hwp_angle(double tf);
int ebex_waferrownumber2index(int wafer, int row, int number);
void setupfocalplane_ebexwafers(int wafers[], int nwafers,double *focalplaneAZ,
				double *focalplaneEL);
void setupfocalplane_150ghz(double *focalplaneAZ, double *focalplaneEL);
void setupfocalplane_250ghz(double *focalplaneAZ, double *focalplaneEL);
void setupfocalplane_410ghz(double *focalplaneAZ, double *focalplaneEL);
void setupfocalplane_horizontal(double *focalplaneAZ, double *focalplaneEL);
void focalplane_cart2pol(double *focalplaneAZ, double *focalplaneEL,int ndetectors);
void focalplane_pol2cart(double *focalplaneR, double *focalplanePHI,int ndetectors);
void rotate_focalplane(double *focalplaneAZ, double *focalplaneEL,int ndetectors,
		       double PHI0_deg);
void shift_focalplane(double *focalplaneAZ, double *focalplaneEL,int ndetectors,
		      double XO_mm, double Y0_mm);
void write_focalplane_database(double PHI0_deg);


#endif
