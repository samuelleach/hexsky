#include "ebex_scanning.h"

#define AZITRYLIMIT 250
#define AZITRYRANGE_DEG 25

#define max( x, y) ((x) > (y) ? (x) : (y))
#define min( x, y) ((x) < (y) ? (x) : (y))

void fixupaz(double currentele_rad, double currentLST, double latitude_rad,
	     double startra_deg, double azistart_rad, double *azimuth){
  /* Fix up the azimuth. This is the hacky version */
  /* Want to find the azimuth at which the RA is
     the same as the inital one (startra_deg) given an initial guess azistart_rad in radians.*/
  
  int t,closestindex; 
  double decres,cosdecres,cosL, sinL;//,tempvar1,tempvar2;
  double azitryrange_rad,azitrylimit_overtwo;

  double *azitry,*raresult,*hares;   
  //  azitry   = (double *)(malloc( AZITRYLIMIT*sizeof(double)));   
  azitry   = (double *)(calloc( AZITRYLIMIT,sizeof(double)));   
  raresult = (double *)(calloc( AZITRYLIMIT,sizeof(double)));   
  hares    = (double *)(calloc( AZITRYLIMIT,sizeof(double)));   
   
  cosL=cos(latitude_rad);
  sinL=sin(latitude_rad);

  azitryrange_rad = AZITRYRANGE_DEG*DEG2RAD;
  azitrylimit_overtwo = (double) AZITRYLIMIT /2.;

  for (t=0; t<AZITRYLIMIT; t++)
    {
      azitry[t] = azistart_rad + azitryrange_rad*((double)t-azitrylimit_overtwo)/(azitrylimit_overtwo);
      azel_2_hadec(&azitry[t],&currentele_rad,1, cosL,sinL, &hares[t], &decres,&cosdecres);
      raresult[t] = currentLST*HR2DEG - hares[t]*RAD2DEG;
      range_fast(&raresult[t],360.);
    }

  closestindex = 1;
  for (t = 1; t < AZITRYLIMIT; t++)
    {
      if (!isnan(raresult[t]))
	{
	  /*tempvar1 = raresult[t] - startra_deg;
	  while (tempvar1 < 0.) tempvar1 += 360.;
	  if (tempvar1 > 180.) tempvar1 = 360. - tempvar1;
	  tempvar2 = raresult[closestindex] - startra_deg;
	  while (tempvar2 <= 0.) tempvar2 += 360.; 
	  if (tempvar2 > 180.) tempvar2 = 360. - tempvar2;
	  if (tempvar1 < tempvar2) closestindex = t;*/

	  if(fabs(raresult[t] - startra_deg) < fabs(raresult[closestindex] - startra_deg))
	    closestindex = t;
      } 
    }

  *azimuth = azitry[closestindex];
  range_fast(azimuth,TWOPI);

  free(azitry);free(raresult);free(hares);   
}

void fixupaz_new(double currentele_rad, double currentLST, double latitude_rad,
		 double startra_deg, double azistart_rad, double *azimuth){
  /* Fix up the azimuth.*/
  
  /* Want to find the azimuth at which the RA = startra_deg, given an initial
     guess azistart_rad */
  
  double cosL, sinL;  
  double *azitry;
  azitry=(double *)(calloc(2,sizeof(double)));   
   
  cosL=cos(latitude_rad);
  sinL=sin(latitude_rad);

  rael_2_az(startra_deg*DEG2RAD, currentele_rad, currentLST,cosL,sinL,azitry);

  if(fabs(azitry[1]-azistart_rad) < fabs(azitry[0]-azistart_rad))
    {
      *azimuth=azitry[1];
    } 
  else
    {
      *azimuth=azitry[0];
    }

  free(azitry);
}

void fixupaz_newer(double currentele_rad, double currentLST, double latitude_rad,
		   double startra_deg, double startdec_deg,double azistart_rad, double *azimuth){
  /* Fix up the azimuth.*/
  
  /* Want to find the azimuth at which the RA = startra_deg, given an initial
     guess azistart_rad */

  /* Makes a further check compared to fixupaz_new to see if the dec is coming out right
   compared to startdec_deg. This is for the case when elevation is aligned with declination.*/
  
  double cosL, sinL;  
  double *azitry;
  int select;
  double ha_rad,dec1_rad,dec2_rad,cosdec;
  azitry=(double *)(calloc(2,sizeof(double)));   
   
  cosL=cos(latitude_rad);
  sinL=sin(latitude_rad);

  rael_2_az(startra_deg*DEG2RAD, currentele_rad, currentLST,cosL,sinL,azitry);

  azel_2_hadec(&azitry[0],&currentele_rad,1,cosL,sinL,&ha_rad,&dec1_rad,&cosdec);
  azel_2_hadec(&azitry[1],&currentele_rad,1,cosL,sinL,&ha_rad,&dec2_rad,&cosdec);

  if(fabs(dec1_rad*RAD2DEG-startdec_deg) < fabs(dec2_rad*RAD2DEG-startdec_deg))
    {
      select = 0 ;
    } 
  else
    {
      select = 1 ;
    }

  //  azel_2_hadec(&azitry[1],&currentele_rad,1,cosL,sinL,&ha_rad,&dec_rad,&cosdec);
  //  printf("FIXUPAZ_NEWER: found dec = %f , startdec = %f \n",dec_rad*RAD2DEG,startdec_deg);

  *azimuth=azitry[select];
  free(azitry);
}

int setupscans_triangle(double totalt, double timebetweensamples, double maxspeed,
			double maxaccel,int numberchop, double azisteps_rad[],double speed[],
			long int *numbersamples_halfchop,
			long int *numbersamples, double *scantime, double *turnaroundtime)
{
  /*Purpose: Creates an array, azistep_rad[], which contains the tapered triangle
    chopping function (now an even function starting with the maximum of the chop).
    
    *numbersample_halfchop contains the number of samples from one peak to peak of the chop.
    The motivation here was to know better this number, in order to keep the memory under
    control in the main routine.

    totalt and timebetween samples are in sec
    maxspeed is in deg/sec
    maxaccel is in rad/sec/sec

    speed[] contains the speed of the chop in rad/sec. (Needs fixing).
    *turnaroundtime is in sec (defined as the amount of time with speed< maxspeed
  */

  double time,azthrow_rad,minaz,maxaz,t1,t2,t3,t4,t5,t6,t7;
  long int i,j;
    
  /* define the important times */
    
  t2 = totalt / 4.;
  t5 = 3. * totalt / 4.;
  t3 = maxspeed/ maxaccel + t2;
  t1 = 2*t2 - t3;
  t4 = t5 - (t3 - t2);
  t6 = t5 + (t3 - t2);
  t7 = t6 + 2.*t1;

  /* Now populate the speed array */
  time =0.;
  i=-1;
  *numbersamples_halfchop= -1;
  while (time<totalt){
    i++;
    time = (double)i*timebetweensamples; /* t is the time in seconds. i is the index in the
					    array */
    if ((time<t3-t2)) speed[i] = -maxspeed + maxaccel*(time-(t1-t2));
    if ((time>t3-t2) & (time<t4-t2)) speed[i] = maxspeed;
    if ((time>t4-t2) & (time<t6-t2)) speed[i] = +maxspeed - maxaccel*(time-(t4-t2));
    if ((time>t6-t2 ) & (time<t7-t2 )) speed[i] = -maxspeed;
    if (time>t7-t2) speed[i] = -maxspeed + maxaccel*(time-(t7-t2));    
    if (2.*time<=totalt) *numbersamples_halfchop +=1;
  }
  *numbersamples=i+1;
  *scantime = time;

  /* Now integrate that up */
  for (i=0; i<*numbersamples; i++) {
    azisteps_rad[i] = 0.;
    for (j=1; j<=i; j++) azisteps_rad[i] += speed[j] * timebetweensamples;
  }
    
  /* Determine the azthrow for plotting, as well
     as doubling up the azisteps for a bunch 
     of repeats */
  minaz=1000.;
  maxaz=-1000.;
  for (i=0; i< *numbersamples; i++) {
    if(azisteps_rad[i] > maxaz) maxaz=azisteps_rad[i];
    if(azisteps_rad[i] < minaz) minaz=azisteps_rad[i];
  }
  azthrow_rad = maxaz-minaz;;
  printf("Chop throw [deg] = %f p2p .\n",azthrow_rad*RAD2DEG);
  for (i=0; i< *numbersamples; i++) {
    azisteps_rad[i] =    azisteps_rad[i] -  azthrow_rad/2.;
  }

  for (i=0; i< *numbersamples_halfchop; i++) {
    azisteps_rad[*numbersamples_halfchop+i] = azisteps_rad[*numbersamples_halfchop-i];
  }
  for (i=1; i<numberchop; i++) { 
    for (j=0; j< *numbersamples_halfchop; j++) {
      azisteps_rad[j+i*2* *numbersamples_halfchop] = azisteps_rad[j];
      azisteps_rad[j+(i*2+1)* *numbersamples_halfchop] =
	azisteps_rad[*numbersamples_halfchop-j];
    }
  }

  for (i=1; i<numberchop; i++) {
    for (j=0; j<*numbersamples; j++) {
      speed[j+i*(*numbersamples)] = speed[j];
    }
  }

  *turnaroundtime=0.;
  for (i=0; i< *numbersamples_halfchop*2; i++)
    {
      if(fabs(speed[i]*RAD2DEG) < maxspeed)
	*turnaroundtime += timebetweensamples;
    }
    
  *scantime = timebetweensamples*( numberchop*2*(*numbersamples_halfchop));
  *numbersamples =  numberchop*2*(*numbersamples_halfchop);
  return(0);
}

int setupscans_trianglewithstop2(double totalt, double timebetweensamples, double maxspeed,
				double maxaccel, double stopt,int numberchop,
				double azisteps_rad[], double speed[],
				long int *numbersamples_halfchop,
				long int *numbersamples, double *scantime, double *turnaroundtime)
{
  /*Purpose: Creates an array, azistep_rad[], which contains the tapered triangle
    chopping function with a stop.
    
    *numbersample_halfchop contains the number of samples from one peak to peak of the chop.

    totalt and timebetweensamples are in sec
    maxaccel is in rad/sec/sec
    stopt is in sec.
    maxspeed is in rad/sec.

    speed[] contains the speed of the chop in rad/sec. (Needs fixing).
    *turnaroundtime is in sec (defined as the amount of time with speed<maxspeed
  */

  double azthrow_rad,minaz,maxaz;
  double wturn,dt,maxspeed_degpersec;
  long int i,j,index,nturn,nscan,nstop;

  /* turnt (which excludes the stopping time) is in sec. */
  double turnt;

  turnt = maxspeed/maxaccel ;
  wturn = TWOPI/turnt;
  dt= timebetweensamples;
  maxspeed_degpersec=maxspeed*RAD2DEG;
  
  nstop = (long)floor(stopt/2./dt);
  nturn = (long)floor(turnt/dt);
  nscan = (long)floor((totalt/2./dt)) - 2*nstop - 2*nturn;

  index= -1;
  for (i=0; i<nstop; i++) 
    {
      index++;
      speed[index]=0.;
    }
  for (i=0; i<nturn; i++) 
    {
      index++;
      speed[index]= maxspeed_degpersec/2. -
	(maxspeed_degpersec/2.)*cos(wturn*dt/2.* (double) i);
    }
  for (i=0; i<nscan; i++) 
    {
      index++;
      speed[index]= maxspeed_degpersec;
    }
  for (i=0; i<nturn; i++) 
    {
      index++;
      speed[index]= maxspeed_degpersec/2. +
	(maxspeed_degpersec/2.)*cos(wturn*dt/2.* (double) i);
    }
  for (i=0; i<nstop; i++) 
    {
      index++;
      speed[index]=0.;
    }
  *numbersamples_halfchop=index+1;

  /*Now fill up the second half of the scanning period */
  for (i=0; i < *numbersamples_halfchop; i++) 
    {
      index++;
      speed[index]=-speed[i];
    }
  
  *numbersamples=  *numbersamples_halfchop *2;
  
  /*Convert speed to rad/sec */
  for (i=0; i < *numbersamples; i++) 
    {
      speed[i]=speed[i]*DEG2RAD;
    }


  /* Now integrate that up */
  for (i=0; i<*numbersamples; i++) {
    azisteps_rad[i] = 0.;
    for (j=1; j<=i; j++) azisteps_rad[i] += speed[j] * timebetweensamples;
  }

  /* Determine the azthrow for plotting, as well
     as doubling up the azisteps for a bunch 
     of repeats */
  minaz=1000.;
  maxaz=-1000.;
  for (i=0; i< *numbersamples; i++) {
    if(azisteps_rad[i] > maxaz) maxaz=azisteps_rad[i];
    if(azisteps_rad[i] < minaz) minaz=azisteps_rad[i];
  }
  azthrow_rad = maxaz-minaz;;
  printf("Chop throw [deg] = %f p2p .\n",azthrow_rad*RAD2DEG);
  for (i=0; i< *numbersamples; i++) {
    azisteps_rad[i] =    azisteps_rad[i] -  azthrow_rad/2.;
  }

  /*Add in the chop repeats*/
  for (i=0; i< *numbersamples_halfchop; i++) {
    azisteps_rad[*numbersamples_halfchop+i] = azisteps_rad[*numbersamples_halfchop-i];
  }
  for (i=1; i<numberchop; i++) { 
    for (j=0; j< *numbersamples_halfchop; j++) {
      azisteps_rad[j+i*2* *numbersamples_halfchop] = azisteps_rad[j];
      azisteps_rad[j+(i*2+1)* *numbersamples_halfchop] =
	azisteps_rad[*numbersamples_halfchop-j];
    }
  }

  for (i=1; i<numberchop; i++) {
    for (j=0; j<*numbersamples; j++) {
      speed[j+i*(*numbersamples)] = speed[j];
    }
  }

  *turnaroundtime=0.;
  for (i=0; i< *numbersamples_halfchop*2; i++)
    {
      if(fabs(speed[i]*RAD2DEG) < maxspeed)
	*turnaroundtime += timebetweensamples;
    }

  *scantime = timebetweensamples*( numberchop*2*(*numbersamples_halfchop));
  *numbersamples =  numberchop*2*(*numbersamples_halfchop);
  return(0);
}

int setupscans_cmbdipole(double totalt, double timebetweensamples, double maxspeed,
			 double maxaccel, double azisteps_rad[], double speed[],
			 long int *numbersamples_halfchop,
			 long int *numbersamples, double *scantime)
{
  /*Purpose: Creates an array, azistep_rad[], which contains the CMB dipole scan (rotation of
    the gondola)
    
    *numbersample_halfchop contains the number of samples from one peak to peak of the chop.

    totalt and timebetweensamples are in sec
    maxspeed is in rad/sec.

    speed[] contains the speed of the chop in rad/sec. (Needs fixing).
  */

  double dt,maxspeed_degpersec;
  long int i,j,index,nscan;

  dt = timebetweensamples;
  maxspeed_degpersec=maxspeed*RAD2DEG;
  
  nscan = (long)floor((totalt/2./dt));

  index= -1;
  for (i=0; i<nscan; i++) 
    {
      index++;
      speed[index]= maxspeed_degpersec;//Later can simulate the acceleration
    }
  *numbersamples_halfchop=index+1;

  /*Now fill up the second half of the scanning period */
  for (i=0; i < *numbersamples_halfchop; i++) 
    {
      index++;
      speed[index]= maxspeed_degpersec;
    }
  
  *numbersamples=  *numbersamples_halfchop *2;
  
  /*Convert speed to rad/sec */
  for (i=0; i < *numbersamples; i++) 
    {
      speed[i]=speed[i]*DEG2RAD;
    }


  /* Now integrate that up */
//  for (i=0; i<*numbersamples; i++) {
//    azisteps_rad[i] = 0.;
//    for (j=1; j<=i; j++) azisteps_rad[i] += speed[j] * timebetweensamples;
//  }
  azisteps_rad[0] = 0.;
  for (i=1; i<*numbersamples-1; i++) {
    azisteps_rad[i] = azisteps_rad[i-1] + speed[i] * timebetweensamples;
  }

  *scantime = timebetweensamples * *numbersamples;
  return(0);
}

int setupscans_sinusoidal(double totalt, double timebetweensamples,
			  double maxspeed,int numberchop, double azisteps_rad[],
			  double speed[],long int *numbersamples_perhalfchop,
			  long int *numbersamples, double *scantime, double *turnaroundtime)
     /*Purpose: Creates an array, azistep_rad[], which contains a sinusoidal
       chopping function (now an even function starting with the maximum of the chop).
       totalt (period) and timebetween samples are in sec.
       maxspeed is in rad/sec.

       speed[] contains the speed of the chop in rad/sec.
       *numbersample_halfchop contains the number of samples from one peak to peak of
       the chop.
       *turnaroundtime is in sec (defined as the amount of time with speed<maxspeed)
  */
{
  long int index,i, j;
  double time=0.;
  double omega = TWOPI/totalt;
  double amplitude = maxspeed/omega;
  double minaz,maxaz,azthrow_rad;

  index=-1;
  while(time < totalt/2.)
    {
      index++;
      time += timebetweensamples;
      azisteps_rad[index]=-amplitude*cos(omega*time);
      speed[index]= omega*amplitude*sin(omega*time);
    }
  *numbersamples_perhalfchop=index+1;
  for (i=0; i< *numbersamples_perhalfchop; i++)
    {
      azisteps_rad[*numbersamples_perhalfchop+i] = azisteps_rad[*numbersamples_perhalfchop-1-i];
      speed[*numbersamples_perhalfchop+i] = -speed[*numbersamples_perhalfchop-1-i];
    }

  for (i=1; i<numberchop; i++) 
    { 
      index = *numbersamples_perhalfchop*2*i ;
      for (j = 0; j < *numbersamples_perhalfchop*2; j++) 
	{
	  azisteps_rad[index+j] = azisteps_rad[j];
	  speed[index+j]   = speed[j];
	}
    }
  
  *turnaroundtime=0.;
  for (i=0; i< *numbersamples_perhalfchop*2; i++)
    {
      if(fabs(speed[i]*RAD2DEG) < maxspeed) *turnaroundtime += timebetweensamples;
    }

  *numbersamples=*numbersamples_perhalfchop*2*numberchop;
  *scantime = (*numbersamples_perhalfchop*2*numberchop-1)*timebetweensamples;
  
  printf("turnaround time = %f\n",*turnaroundtime);

  for (i=0; i< *numbersamples; i++) {
    if(azisteps_rad[i] > maxaz) maxaz=azisteps_rad[i];
    if(azisteps_rad[i] < minaz) minaz=azisteps_rad[i];
  }
  azthrow_rad = maxaz-minaz;;
  printf("Chop throw [deg] = %f p2p .\n",azthrow_rad*RAD2DEG);

  return(0);
}

void plotscans(double azisteps_rad[], double speed[], double timebetweensamples,
	       long int numberazistep, char *outfileroot, FILE *gnuplotlogfile,
	       int displayplot){

  FILE *prtft;
  char TimeScan[254],gnuplotcommands[1024];
  int i;

  /* Now plot the scans! */    
  sprintf(TimeScan,"%s%s",outfileroot,"_timescan.dat");
  prtft = fopen(TimeScan,"w+"); /* overwrites old files */
  fprintf(prtft,"# Chop data. Time (sec), azimuth (degrees).\n");
  for (i=0; i<numberazistep; i++) {
    fprintf(prtft,"%f %f\n",i*timebetweensamples,azisteps_rad[i]*RAD2DEG);
  }
  fprintf(prtft,"# Speed data. Time (sec), speed (degrees/sec).\n");
  for (i=0; i<numberazistep; i++) {
    fprintf(prtft,"%f %f\n",i*timebetweensamples, speed[i]*RAD2DEG);
  }
  fclose(prtft);
  /* Make plot of chopping function */
  sprintf(gnuplotcommands,"set xlabel \\\"Time (seconds)\\\"\n");
  sprintf(gnuplotcommands,"%s plot\\\"",gnuplotcommands);
  sprintf(gnuplotcommands,"%s%s",gnuplotcommands,TimeScan);
  sprintf(gnuplotcommands,"%s\\\" with dots",gnuplotcommands);
  gnuplot(gnuplotcommands,gnuplotlogfile,displayplot);

}

void findelevationstepanddecrange(double elestepmin_arcmin, double elestepmax_arcmin,
				  int noofelestepstotry,int numberelestep,
				  double azistart_rad,double elestart_rad,
				  double latitude_rad,
				  double startra_deg,double startdec_deg,
				  double targetdecrange_deg,
				  double orbitspeed, double longitude_start_deg,
				  CIVILTIME ct, CIVILTIME startmission,double scantime,				  
				  double *elestep_arcmin, double *decrange_deg,
				  double *maxelevation_deg){
  
  double error;//SML fix
  double azifixed,currentele,currentLST,currentlong_deg,elapseddays,D0;
  int noofstepstaken,noofbigsteps,i,y,z,bigger,smaller;//,error;
  long int select;
  double dec_rad_1,dec_rad_2,ha_rad_2,cosdec_2;
  double biggestdec_distance,elestep_rad,tstart, cosL, sinL;
  double *elesteparray,*dec_travelled,*distancetravelled;
  //  elesteparray = (double *)(calloc( 30,sizeof(double)));
  //  dec_travelled = (double *)(calloc( 30,sizeof(double)));
  //  distancetravelled = (double *)(calloc( 30,sizeof(double)));
  elesteparray = (double *)(calloc( 100,sizeof(double))); //SML
  dec_travelled = (double *)(calloc( 100,sizeof(double)));//SML
  distancetravelled = (double *)(calloc( 100,sizeof(double)));//SML

  cosL=cos(latitude_rad);
  sinL=sin(latitude_rad);
  dec_rad_1 = startdec_deg*DEG2RAD;
  
  select=0;
  //  noofbigsteps = 10;  
  if (numberelestep < 10)
    {
      noofbigsteps = numberelestep;
    }
  else
    {
      noofbigsteps = 10;
    }

  for (i=0; i<noofelestepstotry; i++)
    {
      elesteparray[i] = elestepmin_arcmin + 
	(double) i*(elestepmax_arcmin - elestepmin_arcmin)/((double) noofelestepstotry-1.);
    }
  
  tstart= ct.secs;
  D0 = (double)(ct.day - startmission.day);
  for (z=0; z<noofelestepstotry; z++) {
    elestep_rad = elesteparray[z] * ARCMIN2RAD;
    for (y=1; y<noofbigsteps; y++) {
      /* ie take noofbigsteps through the noofelesteps and determine the dec for each.
	 Then we have a reasonable estimate of the declination coverage for this scan. */
      
      noofstepstaken = (int) floor((double) numberelestep / (double) noofbigsteps * (double) y);
      currentele = elestart_rad+ (double)noofstepstaken * elestep_rad;
      
      ct.secs = tstart+ noofstepstaken*scantime;
      elapseddays = D0 + (ct.secs - startmission.secs)*SEC2DAY;
      currentlong_deg = longitude_circumpolar(elapseddays,orbitspeed,longitude_start_deg);
      determinelst(&ct,&currentlong_deg,1,&currentLST);

      fixupaz(currentele,currentLST,latitude_rad,startra_deg,azistart_rad,&azifixed);
      //      fixupaz_new(currentele,currentLST,latitude_rad,startra_deg,azistart_rad,&azifixed);
      //            fixupaz_newer(currentele,currentLST,latitude_rad,startra_deg,startdec_deg,azistart_rad,&azifixed);

      azel_2_hadec(&azifixed,&currentele,1,cosL,sinL,&ha_rad_2, &dec_rad_2,&cosdec_2);
      dec_travelled[y] = (dec_rad_1-dec_rad_2) * RAD2DEG;
//      printf("currentele = %f , noofstepstaken = %i , dec_1 = %f deg. dec_2 = %f deg\n",currentele*RAD2DEG,noofstepstaken,dec_rad_1*RAD2DEG,dec_rad_2*RAD2DEG);
      
      azistart_rad = azifixed;
    }

    /* Now check which is the biggest dec_distance */
    biggestdec_distance = 0.;
    for (y=0; y<noofbigsteps; y++)
      {
	if (fabs(dec_travelled[y]) > biggestdec_distance) biggestdec_distance = dec_travelled[y];
      }
    distancetravelled[z] = biggestdec_distance;
    printf("distance travelled = %f deg. Elevationstep = %f arcmin\n",
	   distancetravelled[z],elesteparray[z]);

  }
  
  bigger = 0;
  smaller = 0;
  for (z=0; z<noofelestepstotry; z++) {
    if (fabs(distancetravelled[z]) > targetdecrange_deg) bigger = z+1;
    if (fabs(distancetravelled[z]) < targetdecrange_deg) smaller = z+1;
  }
  if (bigger*smaller > 0) {
    //    error = 100;
    error = 100.;
    for (z=0; z<noofelestepstotry; z++) {
      if (fabs(fabs(distancetravelled[z]) - targetdecrange_deg) < error) {
	//	error = (int) fabs(fabs(distancetravelled[z]) - targetdecrange_deg);
	error = fabs(fabs(distancetravelled[z]) - targetdecrange_deg);
	select = z;
      }
    }
    printf("Have a value around %f; number %f. Selecting\n",
	   targetdecrange_deg,elesteparray[select]);
    elestep_rad = elesteparray[select] * ARCMIN2RAD;
  } else {
    if (smaller > 0) {
      /* all smaller. Pick the biggest */
      //      error = 0;
      error = 0.;
      for (z=0; z<noofelestepstotry; z++) {
	if (fabs(distancetravelled[z]) > error) {
	  //	  error = (int) fabs(distancetravelled[z]);
	  error = fabs(distancetravelled[z]);
	  select = z;
	}
      }
      printf("Warning: decrange < targetdecrange = %f deg. Setting elevationstep = %f arcmin\n",
	     targetdecrange_deg,elesteparray[select]);
    }
    if (bigger > 0) {
      /* all bigger. Pick the smallest */
      //      error = 1000;
      error = 1000.;
      for (z=0; z<noofelestepstotry; z++) {
	if (fabs(distancetravelled[z] < error)) {
	  //	  error = (int)fabs(distancetravelled[z]);
	  error = fabs(distancetravelled[z]);
	  select = z;
	}
      }
      printf("Warning: decrange > targetdecrange %f deg. Setting elevationstep = %f arcmin\n",
	     targetdecrange_deg,elesteparray[select]);
    }
  }
  
  printf(" decrange_deg  = %f \n",decrange_deg);

  
  *elestep_arcmin = elesteparray[select];
  *decrange_deg   = distancetravelled[select];
  *maxelevation_deg = max(elestart_rad*RAD2DEG,elestart_rad*RAD2DEG+
			  (double)(numberelestep-1) * *elestep_arcmin*ARCMIN2DEG );
  
  free(elesteparray);free(dec_travelled);free(distancetravelled);

}

void setuprepointings(int firstday, int totaldays,int firstscan, int totalscans,
		      EBEX_PARAMETERS params,double scantime,
		      double *lut_rastart_deg, double *lut_decstart_deg,
		      double *lut_azistart_rad, double *lut_elestart_rad){
  
  int day,scannumber,j,index,finalday,finalscan;
  double startra_deg,currentlong_deg,startha_rad,latitude_rad;
  double azistart_rad,elestart_rad,currentLST,startdec_rad,elapseddays;
  double *ele,*dec,*maxele;
  double elestep_arcmin,decrange_deg,elestep_rad,startha_deg,maxelevation_deg;
  double starttime,currentele,startdec_deg;
  CIVILTIME ct, startmission;

  startmission.year  = params.year;
  startmission.month = params.month;
  startmission.day   = params.startday;
  startmission.secs  = params.starthour*HR2SEC;

  ct.month = params.month;
  ct.year = params.year;
  finalday= firstday+totaldays-1;
  finalscan= firstscan+totalscans-1;
  latitude_rad = params.latitude_deg*DEG2RAD;

  if(finalday==firstday)
    {
      if(finalscan==firstscan)
	{
	  printf("Calculating repointings for scan %i, day %i.\n",firstscan,firstday);
	}
      else 
	{
	  printf("Calculating repointings for scans %i to %i, day %i.\n",firstscan,finalscan,firstday);
	}
    }
  else
    {
      if(finalscan==firstscan)
	{
	  printf("Calculating repointings for scan %i, days %i to %i.\n",firstscan,firstday,finalday);
	}
      else
	{
	  printf("Calculating repointings for scans %i to %i, days %i to %i.\n",firstscan,finalscan,firstday,finalday);
	}      
    }	
  
  index=-1;
  for (day=firstday; day<=finalday; day++)
    {        
      ct.day=day;
      startra_deg = params.startra_day[ct.day];
      /* ****** LOOP OVER SCAN REPEATS ******* */
      for (scannumber=firstscan-1; scannumber<finalscan; scannumber++)
	{  
	  ct.secs= (double) (scannumber * params.numberelestep) * scantime ; /* in seconds */	  
	  elapseddays= (double) (ct.day-startmission.day) + ct.secs*SEC2DAY    ;
	  currentlong_deg = longitude_circumpolar(elapseddays,params.orbitspeed,params.longitude_start_deg);

	  ct.secs +=  startmission.secs  ; 
	  determinelst(&ct,&currentlong_deg,1,&currentLST);
	  
	  startha_rad = currentLST*HR2RAD - startra_deg*DEG2RAD;
	  range_fast(&startha_rad,TWOPI);
	  
	  startdec_deg=params.startdec_center;	  
	  startdec_rad=startdec_deg*DEG2RAD;   
	  hadec_2_azel(&startha_rad,&startdec_rad,1,latitude_rad,&azistart_rad,&elestart_rad);
	  
	  /******** FIND ELEVATION STEP  *************/
	  ele=&elestep_arcmin;
	  dec=&decrange_deg;
	  maxele=&maxelevation_deg;
	  findelevationstepanddecrange(params.elestepmin_arcmin, params.elestepmax_arcmin,
				       params.noofelestepstotry, params.numberelestep,
				       azistart_rad, elestart_rad, latitude_rad,
				       startra_deg,startdec_deg,
				       params.targetdecrange,
				       params.orbitspeed,params.longitude_start_deg,
				       ct,startmission,scantime, ele,dec,maxele);
	  elestep_rad =  elestep_arcmin * ARCMIN2RAD; 
	  /******** ELEVATION STEP FOUND *************/

	  /* Fix up the startdec_deg so that when the elevation is determined in a 
	     moment, gets the correct start ele */      
	  if(maxelevation_deg < params.elevationlimit)
	    {
	      startdec_deg = params.startdec_center + 0.5 * decrange_deg;
	      printf("startdec = %f, decrange = %f \n",startdec_deg,decrange_deg);
	    } 
	  else
	    {
	      printf("Warning: elevation limit exceeded: elevation = %f during day %i, scan %i \n"
		     ,maxelevation_deg,day,scannumber+1);
	      exit(-1);
	    }
	  
	  startha_deg = currentLST*HR2DEG - startra_deg;
	  range_fast(&startha_deg,360.);

	  startha_rad=startha_deg*DEG2RAD;
	  startdec_rad=startdec_deg*DEG2RAD; 
	  hadec_2_azel(&startha_rad,&startdec_rad,1,latitude_rad,&azistart_rad,&elestart_rad);
	  
	  /* Initial scan point is azistart_rad, elestart_rad in radians */
	  /* ****** LOOP OVER ELEVATION STEPS ******* */
	  starttime= ct.secs; 
	  for (j=0; j<params.numberelestep; j++)
	    { 
	      index += 1;
	      currentele  = elestart_rad + (double)j * elestep_rad;
	      ct.secs = starttime + (double)j * scantime;
	      elapseddays= (double) (ct.day-startmission.day) +(ct.secs -startmission.secs)*SEC2DAY;
	      currentlong_deg = longitude_circumpolar(elapseddays,  params.orbitspeed,
						      params.longitude_start_deg);
	      determinelst(&ct,&currentlong_deg,1,&currentLST);
	      //	      printf("LST %f deg \n",currentLST*15.);

	      /* Want to find the azimuth at which the RA is the same as the initial one (startra_deg) */
	      //	      fixupaz_new(currentele,currentLST,latitude_rad,startra_deg,azistart_rad,&azistart_rad);
	      //	      fixupaz_newer(currentele,currentLST,latitude_rad,startra_deg,startdec_deg,azistart_rad,&azistart_rad);

	      //problem here for the case where elevation is aligned with RA// SML	      
	      fixupaz(currentele,currentLST,latitude_rad,startra_deg,azistart_rad,&azistart_rad);

	      if(currentele > params.elevationlimit*DEG2RAD)
		{
		  printf("Warning : elevation limit exceeded: elevation = %f \n",
			 params.elevationlimit*DEG2RAD);
		  exit(-1);
		}
	      
	      lut_elestart_rad[index] = currentele;
	      lut_azistart_rad[index] = azistart_rad;
	      lut_rastart_deg[ index] = startra_deg; // FIX THIS (always the same value)
	      lut_decstart_deg[index] = startdec_deg;// FIX THIS (always the same value)
	      //	      printf("startra %f , startdec %f\n",lut_rastart_deg[index],lut_decstart_deg[index]);
	    } /* end loop over elevation steps. */
	} /* end loop over scannumber - evelation/RA reset. */
    } /* end loop over day. */

  printf("Using elevation step of %f arcmin.\n",elestep_rad*RAD2ARCMIN);

}

void checkandplot_missionrepointings(int firstday, int totaldays,
				     int firstscan, int totalscans,
				     EBEX_PARAMETERS params,
				     double scantime,
				     FILE *gnuplotlogfile, int displayplot)
/* Purpose: Wrapper routine to setuprepointings(). Plots and outputs
   the repointing strategy in az and el.
*/
{
  int nrepointings_perday=params.numberscan*params.numberelestep;
  long int nrepointings_mission=params.totaldays*nrepointings_perday;
  double *repointingAZ_rad, *repointingEL_rad, *repointingRA_deg, *repointingDec_deg;
  repointingAZ_rad = (double *)(calloc( nrepointings_mission,sizeof(double)));
  repointingEL_rad = (double *)(calloc( nrepointings_mission,sizeof(double)));
  repointingRA_deg = (double *)(calloc( nrepointings_mission,sizeof(double)));
  repointingDec_deg = (double *)(calloc( nrepointings_mission,sizeof(double)));

  setuprepointings(params.startday, params.totaldays, params.startscan,
		   params.numberscan,params,scantime,
		   &repointingRA_deg[0],&repointingDec_deg[0],
		   &repointingAZ_rad[0],&repointingEL_rad[0]);
  plotrepointings(repointingAZ_rad,repointingEL_rad,
		  repointingRA_deg,repointingDec_deg,params,gnuplotlogfile,
		  params.displayplots);

  free(repointingAZ_rad); free(repointingEL_rad);
  free(repointingRA_deg); free(repointingDec_deg);
}

void get_sample_times(int firstday, int totaldays,int firstscan, int totalscans,
		      int firstelevationstep, int totalelevationsteps,
		      double starttime,
		      double timebetweensamples, double scantime,
		      double numberelestep,long int numberazisamples, 
		      double *sample_times_sec)
  /* Purpose: calculate the local time for each sample in seconds measured
     since the beginning of the day. starttime is an offset in seconds. */
{

  long int scannumber,ii,index;
  int finalday,finalscan,finalelevationstep,jj,day;

  finalday= firstday+totaldays-1;
  finalscan= firstscan+totalscans-1;
  finalelevationstep= firstelevationstep+totalelevationsteps-1;

  index=-1;
  /* ****** LOOP OVER DAYS ******* */
  for (day=firstday; day<=finalday; day++) {        
    /* ****** LOOP OVER SCAN REPEATS ******* */
    for (scannumber=firstscan-1; scannumber<finalscan; scannumber++) {  
      /* ****** LOOP OVER ELEVATION STEPS ******* */
      for (jj=firstelevationstep-1; jj<finalelevationstep; jj++) { 
	/* ****** LOOP OVER AZIMUTH SCAN STEPS ******* */
	for (ii=0; ii<numberazisamples; ii++) {
	  index++;
	  sample_times_sec[index] =  starttime + (double)ii*timebetweensamples +
	    (double)jj*scantime + (double)(scannumber*numberelestep)*scantime; /* seconds */ 
	  if(sample_times_sec[index] - starttime > DAY2SEC)
	    {
	      printf("get_sample_times() Warning: exceed number of seconds in 1 day.\n");
	      exit(-1);
	    }
	}
      }
    }
  }  
}

void get_lst_rad(CIVILTIME ct, CIVILTIME startmission, double sample_times_sec[],
		 long int numbersamples, double orbitspeed,double longitude_start_deg,
		 double *lst_rad)
/* Purpose: convert the civil time to local sidereal time. */
{
  long int sample;
  double D0,elapseddays,currentlong,currentLST;

  D0 = (double) (ct.day - startmission.day);

  for (sample=0; sample<numbersamples; sample++)
    {
      ct.secs=sample_times_sec[sample];
      elapseddays = D0 + (ct.secs - startmission.secs)*SEC2DAY;
      currentlong = longitude_circumpolar(elapseddays,orbitspeed, longitude_start_deg);
      determinelst(&ct,&currentlong,1,&currentLST);
      currentLST *= HR2RAD;
      lst_rad[sample]=currentLST;
    }
}

void get_lst_rad_lon_deg(CIVILTIME ct, CIVILTIME startmission, double sample_times_sec[],
			 long int numbersamples, double orbitspeed,double longitude_start_deg,
			 double *lst_rad,double *lon_deg)
/* Purpose: convert the civil time to local sidereal time. */
{
  long int sample;
  double D0,elapseddays,currentlong,currentLST;

  D0 = (double) (ct.day - startmission.day);

  for (sample=0; sample<numbersamples; sample++)
    {
      ct.secs         = sample_times_sec[sample];
      elapseddays     = D0 + (ct.secs - startmission.secs)*SEC2DAY;
      currentlong     = longitude_circumpolar(elapseddays,orbitspeed, longitude_start_deg);
      determinelst(&ct,&currentlong,1,&currentLST);
      currentLST      *= HR2RAD;
      lst_rad[sample] = currentLST;
      lon_deg[sample] = currentlong;
    }
}

void get_lst_rad_lonlat_deg(CIVILTIME ct, CIVILTIME startmission, double sample_times_sec[],
			    long int numbersamples, double orbitspeed,double longitude_start_deg,
			    double latitude_deg,
			    double *lst_rad,double *lon_deg,double *lat_deg)
/* Purpose: convert the civil time to local sidereal time. */
{
  long int sample;
  double D0,elapseddays,currentlong,currentLST;

  D0 = (double) (ct.day - startmission.day);

  for (sample=0; sample<numbersamples; sample++)
    {
      ct.secs         = sample_times_sec[sample];
      elapseddays     = D0 + (ct.secs - startmission.secs)*SEC2DAY;
      currentlong     = longitude_circumpolar(elapseddays,orbitspeed, longitude_start_deg);
      determinelst(&ct,&currentlong,1,&currentLST);
      currentLST      *= HR2RAD;
      lst_rad[sample] = currentLST;
      lon_deg[sample] = currentlong;
      lat_deg[sample] = latitude_deg;
    }
}

void plotrepointings(double lut_azistart_rad[], double lut_elestart_rad[],
		     double lut_rastart_deg[], double lut_decstart_deg[] ,
		     EBEX_PARAMETERS params,FILE *gnuplotlogfile, int displayplot){

  int nrepointings=params.numberelestep*params.numberscan*params.totaldays;
  int i,index;
  FILE *prtft;
  char file1[254],gnuplotcommands[1024];
  double offset;

  /*  Now plot the repointings    */
  sprintf(file1,"%s%s",params.outfileroot,"_azel_repointings.dat");
  prtft = fopen(file1,"w+"); /*overwrites old files*/
  
  fprintf(prtft,"# Repointings information. Azimuth, elevation (degrees).\n");
  for (i=0; i<nrepointings; i++)
    {
      if(i<nrepointings)
	{
	  index=i;
	  offset=0.;
	}
      else
	{
	  index=i-nrepointings;
	  offset=360.;
	}
      
      fprintf(prtft,"%f %f\n",offset+lut_azistart_rad[index]*RAD2DEG,
	      lut_elestart_rad[index]*RAD2DEG);
    }

  fclose(prtft);
  /* Make plot of repointings in AZ/el coordinates. */
  sprintf(gnuplotcommands,"set xlabel \\\"azimuth (deg)\\\"\n");
  sprintf(gnuplotcommands,"%s set ylabel \\\"elevation (deg)\\\"\n",gnuplotcommands);
  sprintf(gnuplotcommands,"%s plot \\\"",gnuplotcommands);
  sprintf(gnuplotcommands,"%s%s",gnuplotcommands,file1);
  sprintf(gnuplotcommands,"%s\\\" with dots",gnuplotcommands);
  gnuplot(gnuplotcommands,gnuplotlogfile, displayplot);


/*    sprintf(file2,"%s%s",params.outfileroot,"_radec_repointings.dat"); */
/*   prtft = fopen(file2,"w+"); /\* overwrites old files *\/ */
/*   for (i=0; i<nrepointings; i++) { */
/*     fprintf(prtft,"%f %f\n",lut_rastart_deg[i],lut_decstart_deg[i]); */
/*   } */
/*   fclose(prtft); */
/*   /\* Make plot of repointings in RA/Dec coordinates. *\/ */
/*   sprintf(gnuplotcommands,"set xlabel \\\"RA (deg)\\\"\n"); */
/*   sprintf(gnuplotcommands,"%s set ylabel \\\"Dec (deg)\\\"\n",gnuplotcommands); */
/*   sprintf(gnuplotcommands,"%s plot\\\"",gnuplotcommands); */
/*   sprintf(gnuplotcommands,"%s%s",gnuplotcommands,file2); */
/*   sprintf(gnuplotcommands,"%s\\\"",gnuplotcommands); */
/*   gnuplot(gnuplotcommands,gnuplotlogfile); */
}

void partitionscanrepeats(int startday, int numberdays,
			  int startscan, int numberscansperday,
			  int numProc, int myRank,
			  int *day, int *scan, int *numberscans){
  /*Purpose: Shares out the scan repeats between numProc processors.
   myRank should run from 0 to numProc-1.*/

  int i,j,index,iShift, nscanstotal,nscansperprocessor;
  int *days, *scans;
  days  = (int *)(calloc( numberdays*numberscansperday,sizeof(int)));
  scans =  (int *)(calloc( numberdays*numberscansperday,sizeof(int)));

  if(myRank+1 > numProc){
    printf("myRank %i is too big compared to numProc = %i\n",myRank,numProc);
    exit(-1);
  }
  
  index=-1;
  for(i=startday;i<startday+numberdays;i++){
    for(j=startscan;j<startscan+numberscansperday;j++){
      index++;
      days[index]=i;
      scans[index]=j;
    }
  }
  nscanstotal=index+1;

  nscansperprocessor = nscanstotal / numProc;  
  iShift = myRank*nscansperprocessor;

  if( myRank+nscansperprocessor*numProc < nscanstotal) {
    iShift += myRank;
	nscansperprocessor++;
  } else
    iShift += nscanstotal-nscansperprocessor*numProc;

  for(i=0;i<nscansperprocessor;i++){
      day[i]=days[iShift+i];
      scan[i]=scans[iShift+i];
      if(numProc > 1)
	printf("day %i, scan %i, total %i, handled by proc %i out of %i.\n",
	       day[i],scan[i],index,myRank+1,numProc);
  }
  
  free(days); free(scans);
  *numberscans=nscansperprocessor;   
}
