#ifndef _utilities_gnuplot_H
#define _utilities_gnuplot_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

/* Public functions declarations */

void gnuplot(char *gnucommand, FILE *gnuplotfile, int displayplot);
void gnuplot_plot(double y[], int n, double scaling, char *outfileroot, char *filename, int displayplot);
void gnuplot_plot2d(double y[], double x[], int n, char *outfileroot, char *filename,
		    int displayplot);
void gnuplot_histogram(long int y[], double maxy, int n, char *outfileroot,char *filename,
		       int displayplot);

#endif
