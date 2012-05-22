#ifndef _ebex_scanning_H
#define _ebex_scanning_H

#define _GNU_SOURCE

#include "ebex_parameters.h"
#include "ebex_gondola.h"
#include "utilities_pointing.h"
#include "utilities_parameters.h"
#include "utilities_gnuplot.h"
#include <math.h>
#include <stdio.h>

/* Public function declarations */
void fixupaz(double currentele_rad,double currentLST, double latitude_rad,
	     double startra_deg,double azistart_rad,double *azimuth);

void fixupaz_new(double currentele_rad,double currentLST, double latitude_rad,
		 double startra_deg,double azistart_rad,double *azimuth);

void fixupaz_newer(double currentele_rad,double currentLST, double latitude_rad,
		   double startra_deg, double startdec_deg,double azistart_rad,double *azimuth);

int setupscans_triangle(double totalt, double timebetweensamples, double maxspeed,
			double maxaccel,
			int numberchop, double azisteps_rad[], double speed[], 
			long int *numbersamples_halfchop,
			long int *numbersamples, double *scantime, double *turnaroundtime);

int setupscans_trianglewithstop2(double totalt, double timebetweensamples, double maxspeed,
				double maxaccel, double stopt,int numberchop, double azisteps_rad[], double speed[],
				long int *numbersamples_halfchop,
				long int *numbersamples, double *scantime, double *turnaroundtime);
int setupscans_cmbdipole(double totalt, double timebetweensamples, double maxspeed,
			 double maxaccel, double azisteps_rad[], double speed[],
			 long int *numbersamples_halfchop,
			 long int *numbersamples, double *scantime);
int setupscans_sinusoidal(double totalt, double timebetweensamples,
			  double maxspeed,int numberchop, double azisteps_rad[],
			  double speed[],long int *numbersamples_halfchop,
			  long int *numbersamples, double *scantime, double *turnaroundtime);

void plotscans(double azisteps_rad[], double speed[], double timebetweensamples,
	       long int numberazisteps, char *outfileroot, FILE *gnuplotlogfile,
	       int displayplot);

void findelevationstepanddecrange(double elestepmin_arcmin, double elestepmax_arcmin,
				  int noofelestepstotry,int numberelestep,
				  double azistart_rad,double elestart_rad,
				  double latitude_rad,
				  double startra_deg,double startdec_deg,
				  double targetdecrange_deg,
				  double orbitspeed, double longitude_start_deg,
				  CIVILTIME ct,CIVILTIME startmission, double scantime,				  
				  double *elestep_arcmin,double *decrange_deg,
				  double *maxelevation_deg);

void setuprepointings(int firstday, int totaldays, int firstscan, int totalscans,
		      EBEX_PARAMETERS params,double scantime,
		      double *lut_rastart_deg, double *lut_decstart_deg,
		      double *lut_azistart_rad, double *lut_elestart_rad);

void checkandplot_missionrepointings(int firstday, int totaldays,
				     int firstscan, int totalscans,
				     EBEX_PARAMETERS params,
				     double scantime,
				     FILE *gnuplotlogfile, int displayplot);

void get_sample_times(int firstday, int totaldays,int firstscan, int totalscans,
		      int firstelevationstep, int totalelevationsteps,
		      double starttime,
		      double timebweteensamples,double scantime,
		      double numberelestep,long int numberazisamples, 
		      double *sample_times_sec);

void get_lst_rad(CIVILTIME ct, CIVILTIME startmission, double sample_times_sec[],
		 long int numberazisamples,double orbitspeed, double longitude_start_rad,
		 double *lst_rad);

void get_lst_rad_lon_deg(CIVILTIME ct, CIVILTIME startmission, double sample_times_sec[],
			 long int numberazisamples,double orbitspeed, double longitude_start_rad,
			 double *lst_rad, double *lon_deg);

void get_lst_rad_lonlat_deg(CIVILTIME ct, CIVILTIME startmission, double sample_times_sec[],
			    long int numberazisamples,double orbitspeed, double longitude_start_rad,
			    double latitude_deg,
			    double *lst_rad, double *lon_deg, double *lat_deg);

void plotrepointings(double lut_azistart_rad[], double lut_elestart_rad[],
		     double lut_rastart_deg[], double lut_decstart_deg[] ,
		     EBEX_PARAMETERS params,FILE *gnuplotlogfile, int displayplot);

void partitionscanrepeats(int startday, int numberdays,
			  int startscan, int numberscansperday,
			  int numProc, int myRank,
			  int *day, int *scan, int *numberscans);

#endif
