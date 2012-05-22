#ifndef _utilities_squarepixel_H
#define _utilities_squarepixel_H

#include <math.h>
#include <string.h>
#include "utilities_gnuplot.h"
#include "utilities_pointing.h"
#include "utilities_baselines.h"
#if MPI
#include "mpi.h"
#endif

void getmapxycoord(double ra_rad,double dec_rad,double cosdec,
		   double racosdec_min_rad, double decmin_rad,
		   double ra_centre_rad,double inversepixelsize_rad,
		   double *xpos, double *ypos);
void get_pixelnumbers(double ra_rad[],double dec_rad[],double cosdec[],
		      long int nsamples,
		      double racosdec_min_rad, double decmin_rad,
		      double ra_centre_rad,double pixelsize_rad,
		      long int xsize, long int ysize,
		      long int *pixelnumber);
void get_pixelnumbers_and_pixeldisplacements(double ra_rad[],double dec_rad[],double cosdec[],
					long int nsamples,
					double racosdec_min_rad, double decmin_rad,
					double ra_centre_rad,double pixelsize_rad,
					long int xsize, long int ysize,
					long int *pixelnumber,
					double *dx_pix_rad,double *dy_pix_rad);
long int mappixel_checkandwrap(long int xpixel,long int ypixel,
			       long int xsize,long int ysize);
void get_pointing_displacement_maps_squarepix(double ra_rad_1[],double dec_rad_1[],double cosdec_1[],
					      double ra_rad_2[],double dec_rad_2[],double cosdec_2[],
					      long int pixel[],long int nsample,
					      float *dx_map_rad,float *dy_map_rad);
void get_pointing_displacements(double ra_rad_1[],double dec_rad_1[],double cosdec_1[],
				double ra_rad_2[],double dec_rad_2[],double cosdec_2[],
				long int nsamples,float *dx_rad,float *dy_rad);
void get_hit_and_scancrossing_counts(long int pixel[],long int ndetectors,
				     long int numberazisamples,long int npixels,
				     long int hitspersample,long int *scancrossingcount,
				     long int *hitcount);
void binuphalfscan(long int halfscanhitcount[],int npixels, long int *scancrossingcount,
		   long int *binnedhitcount);
void binup_double(double data[], long int pixelnumber[],long int nsamples, double *map);
void binup_float(float data[], long int pixelnumber[], long int nsamples, float *map);
void addcountmaps(long int mapA[], long int *mapB, long int npixels);
void adddoublemaps(double mapA[], double *mapB, long int npixels);
void getlength_vectordoublemap(double mapx[], double mapy[], long int npixels, double *mapl);
void getlength_vectorfloatmap(float mapx[], float mapy[], long int npixels,float *mapl);
void divide_doublemapbycountmap(double *mapA, long int mapB[], long int npixels);
void divide_floatmapbycountmap(float *mapA, long int mapB[], long int npixels);
void dividebydoublemap(double *mapA, double mapB[], long int npixels);
void get_countmap_stats(long int map[], long int npixels, double cellsize_arcmin,
			double *area_squaredegrees, double *averagecount);
void get_doublemap_stats(double data[], long int hitmap[], long int npixels,
			 double cellsize_arcmin,double *area_squaredegrees,
			 double *averagevalue, double *rms);
void get_floatmap_stats(float data[], long int hitmap[], long int npixels,
			double cellsize_arcmin,double *area_squaredegrees,
			double *averagevalue, double *rms);
void plotcountmap(long int count[],int rasize, int decsize,
		  double ramin, double decmin, double racentre,
		  double cellsize, double scaling,FILE *gnuplotlogfile,
		  char *outfileroot, char *filename, int displayplots);
void plotmap(float value[],int rasize,int decsize,
	     double ramin, double decmin, double racentre, 
	     double cellsize_deg, double scaling,
	     FILE *gnuplotlogfile, char *outfileroot, char *filename, int displayplots);
void plot_phasemap(double dx[], double dy[], int rasize,int decsize,
		   double ramin, double decmin, double racentre, 
		   double cellsize_deg,FILE *gnuplotlogfile, char *outfileroot,
		   char *filename, int displayplots);
void plotsubhitcountmap(long int binnedhitcount[], long int binnedsub[], 
			int rasize, int decsize,
			float ramin, float decmin,float racellsize, float deccellsize,
			FILE *gnuplotlogfile, int displayplots);
void *squarepixel_countmap_init(long int npixels);
void *squarepixel_doublemap_init(long int npixels);
void *squarepixel_floatmap_init(long int npixels);
void collect_countmaps(long int hitcounts[], long int npixels);
void collect_doublemaps(double data[], long int npixels);
void collect_floatmaps(float data[], long int npixels);

#endif
