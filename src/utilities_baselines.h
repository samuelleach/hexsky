#ifndef _utilities_baselines_H
#define _utilities_baselines_H

#include <stdio.h>
#include <stdlib.h> //Needed for NULL definition


/* Public functions declarations */

void *multidetectorbaseline_double_init(long int ndetectors, long int nsamples);
void *multidetectorbaseline_float_init(long int ndetectors, long int nsamples);
void *multidetectorbaseline_longint_init(long int ndetectors, long int nsamples);
void *baseline_double_init(long int nsamples);
void *baseline_float_init(long int nsamples);
void *baseline_longint_init(long int nsamples);

#endif
