#ifndef _ebex_gondola_H
#define _ebex_gondola_H

#include "utilities_pointing.h"
#include <math.h>

/* Public function declarations */
void get_elePend_rad(double time[], long int nsamples, double *elePend_rad);
void get_aziPend_rad(double time[], long int nsamples, double *aziPend_rad);
void get_rollPend_rad(double time[], long int nsamples, double *rollPend_rad);
//double longitude_circumpolar(int elapseddays, double time, double orbitspeed,
//			     double start_longitude_deg);
double longitude_circumpolar(double elapseddays, double orbitspeed,
			     double start_longitude_deg);

#endif
