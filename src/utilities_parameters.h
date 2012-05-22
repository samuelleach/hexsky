#ifndef _utilities_parameters_H
#define _utilities_parameters_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

/* Public functions declarations */

int scanfileforparami(FILE *f, char *str, int defaultvalue);

float scanfileforparamf(FILE *f, char *str, float defaultvalue);

void scanfileforparamc(FILE *f, char *str, char *defaultvalue, char *string);

#endif
