#include "utilities_squarepixel.h"


void getmapxycoord(double ra_rad,double dec_rad,double cosdec,
		   double racosdec_min_rad, double decmin_rad,
		   double ra_centre_rad, double inversepixelsize_radmin1,
		   double *xpos, double *ypos)
{
  /*Purpose: convert RA, DEC, and cosdec to x any coordinates on the map. */
  *xpos= ((ra_rad-ra_centre_rad)*cosdec - racosdec_min_rad)*inversepixelsize_radmin1;
  *ypos= (dec_rad - decmin_rad)*inversepixelsize_radmin1;
}

void get_pixelnumbers(double ra_rad[],double dec_rad[],double cosdec[],
		      long int nsamples,double racosdec_min_rad, double decmin_rad,
		      double ra_centre_rad,double pixelsize_rad,
		      long int xsize, long int ysize,long int *pixelnumber)
{
  /*Purpose: Given coordinate (ra_rad, dec_rad) and optionally cosdec, map parameters
    (racosdecmin_rad, decmin_rad, ra_centre_rad, pixelsize_rad, xsize and ysize)
    this subroutine returns pixel number (*pixelnumber). 

    If cosdec is not allocated, then it is calculated on the fly */

  long int sample;
  double xpos,ypos,xpixel,ypixel;
  double inversepixelsize_radmin1=1./pixelsize_rad;

  if (cosdec != NULL)
    {
      for(sample=0;sample<nsamples;sample++)
	{
	  getmapxycoord(ra_rad[sample],dec_rad[sample],cosdec[sample],
			racosdec_min_rad,decmin_rad,ra_centre_rad,
			inversepixelsize_radmin1,&xpos, &ypos);
	  xpixel = trunc(xpos);
	  ypixel = trunc(ypos);
	  
	  pixelnumber[sample]=mappixel_checkandwrap(xpixel,ypixel,xsize,ysize);
	  //	  pixelnumber[sample]=xpixel+xsize*ypixel;
	}
    }
  else /* cos_dec computed on the fly */
    {
      double cos_dec;
      for(sample=0;sample<nsamples;sample++)
	{
	  cos_dec= cos(dec_rad[sample]);
	  getmapxycoord(ra_rad[sample],dec_rad[sample],cos_dec,
			racosdec_min_rad,decmin_rad,ra_centre_rad,
			inversepixelsize_radmin1,&xpos, &ypos);
	  xpixel = trunc(xpos);
	  ypixel = trunc(ypos);

	  pixelnumber[sample]=mappixel_checkandwrap(xpixel,ypixel,xsize,ysize);
	  //	  pixelnumber[sample]=xpixel+xsize*ypixel;
	}
    }
}

void get_pixelnumbers_and_pixeldisplacements(double ra_rad[],double dec_rad[],double cosdec[],
					long int nsamples,
					double racosdec_min_rad, double decmin_rad,
					double ra_centre_rad,double pixelsize_rad,
					long int xsize, long int ysize,
					long int *pixelnumber,
					double *dx_pix_rad,double *dy_pix_rad)
{
  /*Purpose: Given coordinate (ra_rad, dec_rad, and cosdec), map parameters
    (racosdecmin_rad, decmin_rad, ra_centre_rad, pixelsize_rad, xsize and ysize)
    this subroutine returns pixel number (*pixelnumber) and the pixel displacements,
    measured from the centre of the pixel. */

  long int sample;
  double xpos,ypos,xpixel,ypixel;

  double inversepixelsize_radmin1=1./pixelsize_rad;

  if (cosdec != NULL)
    {
      for(sample=0;sample<nsamples;sample++)
	{
	  getmapxycoord(ra_rad[sample],dec_rad[sample],cosdec[sample],
			racosdec_min_rad,decmin_rad,ra_centre_rad,
			inversepixelsize_radmin1,&xpos, &ypos);
	  xpixel = trunc(xpos);
	  ypixel = trunc(ypos);
	  
	  pixelnumber[sample]=mappixel_checkandwrap(xpixel,ypixel,xsize,ysize);
	  //	  pixelnumber[sample]=xpixel+xsize*ypixel;	  
	  dx_pix_rad[sample]= pixelsize_rad*(0.5 - (xpos-(double)xpixel));
	  dy_pix_rad[sample]= pixelsize_rad*(0.5 - (ypos-(double)ypixel));
	}
    }
  else /* cos_dec computed on the fly */
    {
      double cos_dec;
      for(sample=0;sample<nsamples;sample++)
	{
	  cos_dec= cos(dec_rad[sample]);
	  getmapxycoord(ra_rad[sample],dec_rad[sample],cos_dec,
			racosdec_min_rad,decmin_rad,ra_centre_rad,
			inversepixelsize_radmin1,&xpos, &ypos);
	  xpixel = trunc(xpos);
	  ypixel = trunc(ypos);
	  
	  pixelnumber[sample]=mappixel_checkandwrap(xpixel,ypixel,xsize,ysize);
	  //	  pixelnumber[sample]=xpixel+xsize*ypixel;	  
	  dx_pix_rad[sample]= pixelsize_rad*(0.5 - (xpos-(double)xpixel));
	  dy_pix_rad[sample]= pixelsize_rad*(0.5 - (ypos-(double)ypixel));
	}
    }
}
long int mappixel_checkandwrap(long int xpixel,long int ypixel,long int xsize,long int ysize)
     /*Purpose: check that the pixel lies within the allocated
       map area. If not, then perform a wrap.
     */
{
  if(xpixel >= xsize)
    {
      while(xpixel >= xsize) xpixel -= xsize;
    } 
  if(ypixel >= ysize)
    {
      while(ypixel >= ysize) ypixel -= ysize;
    } 
  if(xpixel <0)
    {
      while(xpixel <0 ) xpixel += xsize;
    } 
  if(ypixel <0)
    {
      while(ypixel <0 ) ypixel += ysize;
    } 
  return(xpixel+xsize*ypixel);
}


void get_pointing_displacement_maps_squarepix(double ra_rad_1[],double dec_rad_1[],double cosdec_1[],
					      double ra_rad_2[],double dec_rad_2[],double cosdec_2[],
					      long int pixel[],long int nsample,
					      float *dx_map_rad,float *dy_map_rad)

     /*Purpose: Work out the pointing displacements and bin them into maps. */

{

  float *dx_point_rad,*dy_point_rad;

  dx_point_rad = baseline_float_init(nsample);
  dy_point_rad = baseline_float_init(nsample);

  get_pointing_displacements(&ra_rad_1[0],&dec_rad_1[0],&cosdec_1[0],
			     &ra_rad_2[0],&dec_rad_2[0],&cosdec_2[0],
			     nsample,&dx_point_rad[0],&dy_point_rad[0]);
  
  binup_float(&dx_point_rad[0],&pixel[0],nsample,&dx_map_rad[0]);
  binup_float(&dy_point_rad[0],&pixel[0],nsample,&dy_map_rad[0]);

  free(dx_point_rad);  free(dy_point_rad);

}


void get_pointing_displacements(double ra_rad_1[],double dec_rad_1[],double cosdec_1[],
				double ra_rad_2[],double dec_rad_2[],double cosdec_2[],
				long int nsamples,float *dx_rad,float *dy_rad)
{
  /*Purpose: to calculate the pointing displacements in Dec and RA.cos(Dec) for two
    sets of pointings. eg Noisy reconstructed and ideal pointings.
  */

  long int sample;
  for(sample=0;sample<nsamples;sample++)
    {
      dx_rad[sample]=ra_rad_1[sample]*cosdec_1[sample]-ra_rad_2[sample]*cosdec_2[sample];
      dy_rad[sample]=dec_rad_1[sample]-dec_rad_2[sample];
    }
}

void get_hit_and_scancrossing_counts(long int pixel[],long int ndetectors,
				     long int numberazisamples,long int npixels,
				     long int hitspersample,long int *scancrossingcount,
				     long int *hitcount)
{
  /*Purpose: takes pixel[] numbers for numberazisamples x ndetectors samples,
    and bins these sample into hit count and scan crossing maps.

*/
  long int azisample,deti;
  long int *halfscanhitcount;
  long int index;
  long int pix;
  
  halfscanhitcount= squarepixel_countmap_init(npixels);
  for (azisample = 0; azisample < numberazisamples; azisample++)
    {
      for (deti=0; deti<ndetectors; deti++)
	{  
	  index=azisample*ndetectors+deti;
	  pix=pixel[index];
	  halfscanhitcount[pix] += hitspersample;//BUGGY LINE.. PROBLEM WITH PIX
	}
    } /* end loop over azimuth scan steps.*/
  
  /*Perform binning of the half scan. */
  binuphalfscan(&halfscanhitcount[0],npixels,&scancrossingcount[0],&hitcount[0]);
    
  free(halfscanhitcount);
} 

void binuphalfscan(long int halfscanhitcount[], int npixels,
		   long int *scancrossingcount, long int *binnedhitcount)
{
  int pixel;
  long int hits;
  
  for(pixel=0;pixel<npixels;pixel++)
    {
      hits=(*(halfscanhitcount + pixel));
      if(hits)
	{
	  (*(binnedhitcount+ pixel)) += hits;
	  (*(scancrossingcount + pixel))++;
	}
    }
}

void binup_double(double data[], long int pixelnumber[], long int nsamples, double *map)
{
  /*Purpose: Given data[] and pixelnumbers[], coadd this data in a map */

  long int sample;
  
  for(sample = 0; sample < nsamples; sample++)
    {
      (*(map + pixelnumber[sample])) += data[sample];
    }
}

void binup_float(float data[], long int pixelnumber[], long int nsamples, float *map)
{
  /*Purpose: Given data[] and pixelnumbers[], coadd this data in a map */

  long int sample;
  
  for(sample = 0; sample < nsamples; sample++)
    {
      (*(map + pixelnumber[sample])) += data[sample];
    }
}

void addcountmaps(long int mapA[], long int *mapB, long int npixels)
{

  /*Purpose: Add two maps together. The sum is returned in mapB.*/
  long int pixel;

  for(pixel=0;pixel<npixels;pixel++)
    {
      mapB[pixel] += mapA[pixel]; 
    }
}

void adddoublemaps(double mapA[], double *mapB, long int npixels)
{

  /*Purpose: Add two double maps together. The sum is returned in mapB.*/
  long int pixel;

  for(pixel=0;pixel<npixels;pixel++)
    {
      mapB[pixel] += mapA[pixel]; 
    }
}

void getlength_vectordoublemap(double mapx[], double mapy[], long int npixels,
			       double *mapl)
     /* Purpose: find the length of the (x,y) vector at each pixel of the map */
{
  long int pixel;

  for(pixel=0;pixel<npixels;pixel++)
    {
      mapl[pixel] = sqrt(mapx[pixel]*mapx[pixel]+mapy[pixel]*mapy[pixel]);
    }

}

void getlength_vectorfloatmap(float mapx[], float mapy[], long int npixels,
			      float *mapl)
     /* Purpose: find the length of the (x,y) vector at each pixel of the map */
{
  long int pixel;

  for(pixel=0;pixel<npixels;pixel++)
    {
      mapl[pixel] = sqrt(mapx[pixel]*mapx[pixel]+mapy[pixel]*mapy[pixel]);
    }

}

void divide_doublemapbycountmap(double *mapA, long int mapB[], long int npixels)
{
  /*Purpose: Divide a map of doubles by a count map, for the purpose of averaging.*/
  long int pixel;
  double temp;

  for(pixel = 0; pixel < npixels; pixel++){
    if(mapB[pixel] != 0)
      {
	temp= (double) mapB[pixel]; 
	mapA[pixel] = mapA[pixel]/temp;
      }
    else 
      {
	mapA[pixel] = 0.;
      }
  }
}

void divide_floatmapbycountmap(float *mapA, long int mapB[], long int npixels)
{
  /*Purpose: Divide a map of doubles by a count map, for the purpose of averaging.*/
  long int pixel;
  float temp;

  for(pixel = 0; pixel < npixels; pixel++){
    if(mapB[pixel] != 0)
      {
	temp= (float) mapB[pixel]; 
	mapA[pixel] = mapA[pixel]/temp;
      }
    else 
      {
	mapA[pixel] = 0.;
      }
  }
}

void dividebydoublemap(double *mapA, double mapB[], long int npixels)
{
  /*Purpose: Divide a map of doubles by a double map.*/
  long int pixel;

  for(pixel=0;pixel<npixels;pixel++){
    if(mapB[pixel] != 0.)
      {
	mapA[pixel] = mapA[pixel]/mapB[pixel]; 
      }
    else 
      {
	mapA[pixel] = 0.;
      }
  }
}

void get_countmap_stats(long int map[], long int npixels, double cellsize_arcmin,
			double *area_squaredegrees, double *averagecount)
{

  /*Purpose: Get the survey area and average count.*/
  long int pixel;
  long int hitpixels=0;
  double totalhits;

  for(pixel=0;pixel<npixels;pixel++)
    {
      if(map[pixel] != 0)
	{
	  totalhits += (double)map[pixel];
	  hitpixels++;
	}
    }
  *area_squaredegrees= (double)hitpixels*cellsize_arcmin*cellsize_arcmin*
    ARCMIN2DEG*ARCMIN2DEG;
  *averagecount=totalhits/(1.*hitpixels);

  printf("Map area %f deg^2, f_sky %f, average hits per pixel %f\n",
	 *area_squaredegrees,*area_squaredegrees*SQDEG2FSKY,*averagecount);
}

void get_doublemap_stats(double data[], long int hitmap[], long int npixels,
			 double cellsize_arcmin,double *area_squaredegrees,
			 double *averagevalue, double *rms)
{
  /*Purpose: Get the survey area and average value of map data[]. Requires a corresponding 
    mask (or hitmap[]) for performing the average.*/
  long int pixel;
  long int hitpixels=0;
  double total, sumsquare;

  for(pixel=0;pixel<npixels;pixel++)
    {
      if(hitmap[pixel] != 0)
	{
	  total = total + data[pixel] ;
	  sumsquare += data[pixel]*data[pixel] ;
	  hitpixels++ ;
	}
    }
  *area_squaredegrees= (double)hitpixels*cellsize_arcmin*cellsize_arcmin*
    ARCMIN2DEG*ARCMIN2DEG;
  *averagevalue= total/((double)hitpixels);
  *rms = sqrt(sumsquare/(1.*hitpixels)-*averagevalue* *averagevalue); 

  printf("Map area %f deg^2, f_sky %f, average per hit pixel %f, rms %f\n",
	 *area_squaredegrees,*area_squaredegrees*SQDEG2FSKY,(float) *averagevalue,
	 (float) *rms);

}

void get_floatmap_stats(float data[], long int hitmap[], long int npixels,
			double cellsize_arcmin,double *area_squaredegrees,
			double *averagevalue, double *rms)
{
  /*Purpose: Get the survey area and average value of map data[]. Requires a corresponding 
    mask (or hitmap[]) for performing the average.*/
  long int pixel;
  long int hitpixels=0;
  double total, sumsquare;

  for(pixel=0;pixel<npixels;pixel++)
    {
      if(hitmap[pixel] != 0)
	{
	  total = total + data[pixel] ;
	  sumsquare += data[pixel]*data[pixel] ;
	  hitpixels++ ;
	}
    }
  *area_squaredegrees= (double)hitpixels*cellsize_arcmin*cellsize_arcmin*
    ARCMIN2DEG*ARCMIN2DEG;
  *averagevalue= total/((double)hitpixels);
  *rms = sqrt(sumsquare/(1.*hitpixels)-*averagevalue* *averagevalue); 

  printf("Map area %f deg^2, f_sky %f, average per hit pixel %f, rms %f\n",
	 *area_squaredegrees,*area_squaredegrees*SQDEG2FSKY,(float) *averagevalue,
	 (float) *rms);

}


void plotcountmap(long int count[],int rasize,int decsize,
		  double ramin, double decmin, double racentre,
		  double cellsize,double scaling,FILE *gnuplotlogfile, 
		  char *outfileroot, char *filename,int displayplots)
{
  /* Purpose: plot an rasize x decsize grid of integer values. Log scale.
   Entire map scaled by "scaling".*/

  FILE *prtfhitc;
  int rapixel, decpixel;
  char file[2056];
  long int val;
  double rapos, decpos;
  char gnuplotcommands[1024];

  sprintf(file,"%s_%s.dat",outfileroot,filename);
  
  /* and now plot the count map */
  
  prtfhitc = fopen(file,"w+");  
  for (rapixel = 0; rapixel<rasize; rapixel++) 
    {
      for (decpixel = 0; decpixel<decsize; decpixel++) 
	{
	  val = *(count + rapixel + decpixel*rasize)*scaling;
	  rapos = rapixel * cellsize + ramin;
	  decpos = decpixel * cellsize + decmin;
	  fprintf(prtfhitc,"%f %f %li\n",rapos,decpos,val);
	}
      fprintf(prtfhitc,"\n");
    }
  
  fclose(prtfhitc);
  printf("Done %s\n",file);

  /* print the countmap */

  sprintf(gnuplotcommands,"set pm3d\n");
  sprintf(gnuplotcommands,"%s set logscale cb\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set xlabel font \\\"Times-Roman, 22\\\" \n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set ylabel font \\\"Times-Roman, 22\\\" \n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set cblabel font \\\"Times-Roman, 22\\\" \n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set xtics font \\\"Times-Roman, 19\\\" \n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set ytics font \\\"Times-Roman, 19\\\" \n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set view map\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set hidden\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set size ratio -1\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set xlabel \\\"(RA-%.1f) cos(Dec) [degrees]\\\"\n",
	  gnuplotcommands,racentre);
  //  sprintf(gnuplotcommands,"%s set tics scale 1.5\n",gnuplotcommands);
  //  sprintf(gnuplotcommands,"%s set ticsscale 1.5 0\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set ylabel \\\"Dec [degrees]\\\" -3\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set tics out\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set title \\\"  \\\"\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s splot [%f:%f] [%f:%f]\\\"",gnuplotcommands,
  	  ramin,ramin+(rasize-1)*cellsize,decmin+(decsize-1)*cellsize,decmin);

  sprintf(gnuplotcommands,"%s%s",gnuplotcommands,file);
  sprintf(gnuplotcommands,"%s\\\" notitle",gnuplotcommands);
  
  gnuplot(gnuplotcommands,gnuplotlogfile,displayplots);
  
}

void plotmap(float value[],int rasize,int decsize,
	     double ramin, double decmin, double racentre, 
	     double cellsize,double scaling,
	     FILE *gnuplotlogfile, char *outfileroot, char *filename, int displayplots)
{
  /* Purpose: plot an rasize x decsize grid of floats.*/

  FILE *prtfhitc;
  int rapixel, decpixel;
  float val;
  char file[2056];
  float rapos, decpos;
  char gnuplotcommands[1024];

  sprintf(file,"%s_%s.dat",outfileroot,filename);

  /* and now plot the map */

  prtfhitc = fopen(file,"w+");  
  for (rapixel = 0; rapixel<rasize; rapixel++)
    {
      for (decpixel = 0; decpixel<decsize; decpixel++) 
	{
	  val = *(value + rapixel + decpixel*rasize)*scaling;
	  rapos = rapixel * cellsize + ramin;
	  decpos = decpixel * cellsize + decmin;
	  fprintf(prtfhitc,"%f %f %f\n",rapos,decpos,val);
	}
      fprintf(prtfhitc,"\n");
    }
  
  fclose(prtfhitc);
  printf("Done %s\n",file);
  
  /* print the map */

  sprintf(gnuplotcommands,"set pm3d\n");
  //  sprintf(gnuplotcommands,"%s set palette defined (-3 \"blue\", 0 \"white\", 1 \"red\")\n",gnuplotcommands);
  //  sprintf(gnuplotcommands,"%s set palette gray\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set pointsize 0.01\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set view map\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set hidden\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set size ratio -1\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set xlabel \\\"(RA-%f)cos(Dec) [degrees]\\\"\n",
	  gnuplotcommands,racentre);
  sprintf(gnuplotcommands,"%s set ylabel \\\"Dec [degrees]\\\"\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set tics out\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s splot [%f:%f] [%f:%f]\\\"",gnuplotcommands,
  	  ramin,ramin+(rasize-1)*cellsize,decmin+(decsize-1)*cellsize,decmin);

  //  sprintf(gnuplotcommands,"%s splot\\\"",gnuplotcommands);
  sprintf(gnuplotcommands,"%s%s",gnuplotcommands,file);
  sprintf(gnuplotcommands,"%s\\\"",gnuplotcommands);
  
  gnuplot(gnuplotcommands,gnuplotlogfile,displayplots);

}

void plot_phasemap(double dx[], double dy[], int rasize,int decsize,
		   double ramin, double decmin, double racentre, 
		   double cellsize,
		   FILE *gnuplotlogfile, char *outfileroot, char *filename, int displayplots)
{
  /* Purpose: plot an rasize x decsize grid of doubles size[], along with vector (dx,dy)
     */

  FILE *prtfhitc;
  int rapixel, decpixel;
  long int pixel;
  float val;
  char file[2056];
  float rapos, decpos;
  char gnuplotcommands[1024];

  sprintf(file,"%s_%s.dat",outfileroot,filename);

  /* and now plot the map */

  prtfhitc = fopen(file,"w+");  
  for (rapixel = 0; rapixel<rasize; rapixel++)
    {
      for (decpixel = 0; decpixel<decsize; decpixel++) 
	{
	  pixel =rapixel + decpixel*rasize;
	  val = atan2(*(dy + pixel),*(dx + pixel))*RAD2DEG;
	  rapos = rapixel * cellsize + ramin;
	  decpos = decpixel * cellsize + decmin;
	  fprintf(prtfhitc,"%f %f %f\n",rapos,decpos,val);
	}
      fprintf(prtfhitc,"\n");
    }
  
  fclose(prtfhitc);
  printf("Done %s\n",file);
  
  /* print the map */

  sprintf(gnuplotcommands,"set pm3d\n");
  //  sprintf(gnuplotcommands,"%s set palette defined (-3 \"blue\", 0 \"white\", 1 \"red\")\n",
  //  sprintf(gnuplotcommands,"%s set palette defined (-180 \\\"blue\\\", -90 \\\"green\\\", 0 \\\"white\\\", 90 \\\"red\\\", 180 \\\"blue\\\")\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set palette defined (-180 \\\"dark-green\\\", -135 \\\"green\\\", -90 \\\"cyan\\\", -45 \\\"blue\\\", 0 \\\"white\\\", 45 \\\"magenta\\\", 90 \\\"red\\\", 135 \\\"yellow\\\", 180 \\\"dark-green\\\")\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set pointsize 0.01\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set view map\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set hidden\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set size ratio -1\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set xlabel \\\"(RA-%f)cos(Dec) [degrees]\\\"\n",gnuplotcommands,racentre);
  sprintf(gnuplotcommands,"%s set ylabel \\\"Dec [degrees]\\\"\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s set tics out\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s splot [%f:%f] [%f:%f] [-180:180]\\\"",gnuplotcommands,
  	  ramin,ramin+(rasize-1)*cellsize,decmin+(decsize-1)*cellsize,decmin);
  sprintf(gnuplotcommands,"%s%s",gnuplotcommands,file);
  sprintf(gnuplotcommands,"%s\\\"",gnuplotcommands);
  
  gnuplot(gnuplotcommands,gnuplotlogfile,displayplots);

}

void plotsubhitcountmap(long int binnedhitcount[],long int binnedsub[],
			int rasize, int decsize,
			float ramin, float decmin,float racellsize, float deccellsize,
			FILE *gnuplotlogfile, int displayplots){

  char thisfilename[254];
  FILE *prtfhitc;
  int rapixel, decpixel;
  long int val,val2;
  double rapos, decpos;
  char gnuplotcommands[1024];

  sprintf(thisfilename,"subhitcountmap.dat");
  prtfhitc = fopen(thisfilename,"w+");  
  for (rapixel = 0; rapixel<3*rasize; rapixel++) {
    for (decpixel = 0; decpixel<3*decsize; decpixel++) {
      val = *(binnedsub + rapixel + decpixel*3*rasize);
      val2 = *(binnedhitcount + rapixel/3 + decpixel/3*rasize);
      rapos = rapixel * racellsize/3. + ramin;
      decpos = decpixel * deccellsize/3. + decmin;
      fprintf(prtfhitc,"%f %f %li %li\n",rapos,decpos,val,val2);
    }
    fprintf(prtfhitc,"\n");
  }
  
  fclose(prtfhitc);
  printf("Done subhitcountmap.dat\n");

    sprintf(gnuplotcommands,"set pm3d\n");
    sprintf(gnuplotcommands,"%s set pointsize 0.01\n",gnuplotcommands);
    sprintf(gnuplotcommands,"%s set logscale cb\n",gnuplotcommands);
    sprintf(gnuplotcommands,"%s set view map\n",gnuplotcommands);
    sprintf(gnuplotcommands,"%s set hidden\n",gnuplotcommands);
    sprintf(gnuplotcommands,"%s set size ratio -1\n",gnuplotcommands);
    sprintf(gnuplotcommands,"%s set xlabel \\\"RA [degrees]\\\"\n",gnuplotcommands);
    sprintf(gnuplotcommands,"%s set ylabel \\\"Dec [degrees]\\\"\n",gnuplotcommands);
    sprintf(gnuplotcommands,"%s set logscale z\n",gnuplotcommands);
    sprintf(gnuplotcommands,"%s splot\\\"",gnuplotcommands);
    sprintf(thisfilename,"subhitcountmap.dat");
    sprintf(gnuplotcommands,"%s%s",gnuplotcommands,thisfilename);
    sprintf(gnuplotcommands,"%s\\\"",gnuplotcommands);

    gnuplot(gnuplotcommands,gnuplotlogfile,displayplots);  
}

void *squarepixel_countmap_init(long int npixels){
  
  void *map;

  if (npixels == 0) return NULL;
  map=calloc(npixels, sizeof(long int));

  if (map == NULL) {
    printf("Can't allocate memory for this map.\n");
    exit(-1);
  }
  return map;
}

void *squarepixel_doublemap_init(long int npixels){
  
  void *map;

  if (npixels == 0) return NULL;
  map=calloc(npixels, sizeof(double));

  if (map == NULL) {
    printf("Can't allocate memory for this map.\n");
    exit(-1);
  }
  return map;
}

void *squarepixel_floatmap_init(long int npixels){
  
  void *map;

  if (npixels == 0) return NULL;
  map=calloc(npixels, sizeof(float));

  if (map == NULL) {
    printf("Can't allocate memory for this map.\n");
    exit(-1);
  }
  return map;
}

void collect_countmaps(long int hitcounts[], long int npixels)
     /* Purpose: Add up all the hitcounts[] from an MPI job, returning the total
	back into hitcounts[].
	
	If running a non-MPI job, then hitcounts is returned unaltered.
     */
{
  
#if MPI
  long int *hitcounts_total;
  hitcounts_total = squarepixel_countmap_init(npixels);  
  MPI_Barrier(MPI_COMM_WORLD);
  MPI_Reduce(&hitcounts[0], &hitcounts_total[0],
	     npixels, MPI_LONG, MPI_SUM, 0, MPI_COMM_WORLD);
  
  hitcounts=&hitcounts_total[0];
  free(hitcounts_total);    
#endif

}

void collect_doublemaps(double data[], long int npixels)
     /* Purpose: Add up all the data[] from an MPI job, returning the total
	back into data[].
	
	If running a non-MPI job, then data[] is returned unaltered.
     */
{
  
#if MPI
  double *data_total;
  data_total = squarepixel_doublemap_init(npixels);  
  MPI_Barrier(MPI_COMM_WORLD);
  MPI_Reduce(&data[0], &data_total[0],
	     npixels, MPI_LONG, MPI_SUM, 0, MPI_COMM_WORLD);

  data=&data_total[0];
  free(data_total);    
#endif

}

void collect_floatmaps(float data[], long int npixels)
     /* Purpose: Add up all the data[] from an MPI job, returning the total
	back into data[].
	
	If running a non-MPI job, then data[] is returned unaltered.
     */
{
  
#if MPI
  float *data_total;
  data_total = squarepixel_doublemap_init(npixels);  
  MPI_Barrier(MPI_COMM_WORLD);
  MPI_Reduce(&data[0], &data_total[0],
	     npixels, MPI_LONG, MPI_SUM, 0, MPI_COMM_WORLD);

  data=&data_total[0];
  free(data_total);    
#endif

}




