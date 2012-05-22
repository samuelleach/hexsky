#ifndef _conditionNumber_H
#define _conditionNumber_H

#include <math.h>
#include "utilities_pointing.h"
#include "utilities_baselines.h"
#include "utilities_squarepixel.h"
#include <gsl/gsl_linalg.h>

void get_hwp_aTa_matrix_elements(double two_phi[],long int nsample,
				 double beta[],long int ndet,
				 float *aTa11, float *aTa12, float *aTa13,
				 float *aTa22, float *aTa23, float *aTa33);
void get_hwp_angle(double t[], double twof_hwp_hz, long int n, double *twophi_hwp);
void get_hwp_angle2(CIVILTIME ct, double t[], double twof_hwp_hz, long int n,
		    double *twophi_hwp);
void get_hwp_aTa_component_maps(double twophi_hwp_rad[], long int nsample,
				double beta_rad[], long int ndet, long int pixel[],
				float *aTa11_map,float *aTa12_map,float *aTa13_map,
				float *aTa22_map,float *aTa23_map,float *aTa33_map);

void get_conditionnumber_map(float aTa11_map[], float aTa12_map[], float aTa13_map[],
			     float aTa22_map[], float aTa23_map[], float aTa33_map[],
			     long int npixels, float *CN_map);


#endif
