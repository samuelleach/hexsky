#include "pointing_library.h"

/* Public function definitions */

int get_boresight_pointing(long int nrepointings, double repointingAZ[],
			   double repointingEL[],
			   /* Repointing DB.*/
			   long int nsamplesScan, double scanAZ[],
			   /* Generic scan pattern*/
			   double pendAZ[],double pendEL[],
			   /* Pendulations, nsamplesScan x nrepointings in length*/
			   double *boresightAZ, double *boresightEL)
{

  /* Purpose: Takes the repointings in AZ and EL, a generic scan pattern in AZ,
     the AZ and EL pendulations, and combines to give the AZ and EL pointings.  
  */

  long int scan,sample;
  long int index;
  index=-1;
  for(scan=0; scan<nrepointings;scan++)  /* Loop over repointings*/
    {
      for(sample=0;sample<nsamplesScan;sample++)  /* Loop over samples.*/
	{
	  index++;
	  boresightAZ[index]=repointingAZ[scan]+scanAZ[sample];
	  boresightEL[index]=repointingEL[scan];
	}
    }

  if( pendAZ != NULL)  /* include azimuthal/yaw pendulation */
    {
      for(sample=0; sample <= index;sample++)
	{
	  boresightAZ[sample] = boresightAZ[sample] + pendAZ[sample];
	}
    }
  
   if( pendEL != NULL)  /* include elevation/pitch pendulation */
     {  
      for(sample=0;sample <= index;sample++)
	{
	  boresightEL[sample] = boresightEL[sample] + pendEL[sample];
	}
     }

  return(0);
}


int get_multi_det_pointing(long int ndetectors, double focalplaneAZ[],
			   double focalplaneEL[],
			   /* Focalplane DB.*/
			   
			   long int nsamples, double boresightAZ[],
			   double boresightEL[],
			   
			   double lst[], double rollPendAngle[],double latitude_rad,
			   /* Precomputed info about LST and pendulation for each sample,
			      and in general all information relating to the orientation
			      of the telescope at each sample.
			   */
			   
			   double *pointingRA, double *pointingDec, double *pointingBeta,
			   double *pointingcosDec)
{
  
  /* Modified version of get_multi_det_pointing() : attempting to sort out the orientation
   for the multidetector case : NEEDS FIXING*/

  long int sample;
/*
  double cosdEL[ndetectors], sindEL[ndetectors],EL[ndetectors];
  double ha_rad[ndetectors];
*/
  double *cosdEL, *sindEL, *EL, *ha_rad;
  cosdEL = (double *)(calloc( ndetectors,sizeof(double)));
  sindEL = (double *)(calloc( ndetectors,sizeof(double)));
  EL     = (double *)(calloc( ndetectors,sizeof(double)));
  ha_rad = (double *)(calloc( ndetectors,sizeof(double)));


  double cosL = cos(latitude_rad);
  double sinL = sin(latitude_rad);

  double deltaEL, RA, Dec;
  deltaEL=10.*ARCSEC2RAD;

  if(ndetectors == 1)
    {
      /*First calculate the boresight RA/Dec */  
      double *ha;
      ha=(double *)calloc(nsamples, sizeof(double));  
      azel_2_hadec(&boresightAZ[0],&boresightEL[0],
		   nsamples, cosL,sinL,&ha[0],&pointingDec[0],&pointingcosDec[0]);
      ha2ra(&ha[0],&lst[0],nsamples,&pointingRA[0]);
      free(ha);
      
      /* Now calculate orientation of the boresight.
	 Do this by computing RA/Dec for one more point.*/
      double ELrolled, AZrolled, HA,cosDec;
      
      for(sample=0;sample<nsamples;sample++) /* Loop over samples.*/
	{
	  ELrolled = boresightEL[sample];
	  AZrolled = boresightAZ[sample];
	  
	  /* Small angle expansion for roll pendulations */
	  if( rollPendAngle != NULL)  
	    {
	      ELrolled += deltaEL*(1.-rollPendAngle[ sample]*rollPendAngle[ sample]/2. );
	      AZrolled += deltaEL*rollPendAngle[ sample];
	    } 

	  azel_2_hadec(&AZrolled,&ELrolled,1,cosL,sinL,&HA,&Dec,&cosDec);
	  ha2ra(&HA,&lst[sample],1,&RA);
	  pointingBeta[sample]=PI-
	    atan2((RA-pointingRA[sample])*pointingcosDec[sample],(Dec-pointingDec[sample]));
	}
      //      gnuplot_plot(rollPendAngle, nsamples,RAD2DEG,"output/","Rollangle",1);
      //      gnuplot_plot(pointingBeta,nsamples,RAD2DEG,"output/","beta",1);
      //      exit(-1);
    }
  /*Now the multi detector case. */
  else if(ndetectors > 1)
    {
      long int det;
      long int arrayindex,raindex;
      double *cosdELrolled, *sindELrolled, *focalplaneAZrolled, *RAtemp, *Dectemp;
      cosdELrolled = (double *) calloc( ndetectors, sizeof( double));
      sindELrolled = (double *) calloc( ndetectors, sizeof( double));
      focalplaneAZrolled = (double *) calloc( ndetectors, sizeof( double));
      RAtemp = (double *) calloc( ndetectors*nsamples, sizeof( double));
      Dectemp = (double *) calloc( ndetectors*nsamples, sizeof( double));

      int j;
      for(j=1;j>-1;j--) /*Loop over deltaEL needed for orientations */
	/*j=1 corresponds to a pointing displaced by deltaEL.*/
	{
	  for( det = 0; det < ndetectors; det++)
	    {
	      cosdEL[det]=cos(focalplaneEL[det]+(double)j*deltaEL);
	      sindEL[det]=sin(focalplaneEL[det]+(double)j*deltaEL);
	      EL[det]=focalplaneEL[det]+(double)j*deltaEL;
	    }
	  
	  for(sample = 0; sample < nsamples; sample++) /* Loop over samples.*/
	    {
	      arrayindex = ndetectors*sample;
	      
	      for( det = 0; det < ndetectors; det++)
		{
		  cosdELrolled[ det] = cosdEL[ det];			
		  sindELrolled[ det] = sindEL[ det];
		  focalplaneAZrolled[ det] = focalplaneAZ[ det];

		  if( rollPendAngle != NULL)  /* include roll pendulation */
		    {
		      cosdELrolled[ det] -=			
			sindEL[ det]*focalplaneAZ[ det]*rollPendAngle[ sample];
		      // \approx cos( dEL + dAZ*roll)
		      sindELrolled[ det] +=
			cosdEL[ det]*focalplaneAZ[det]*rollPendAngle[ sample];
		      // \approx sin( dEL + dAZ*roll)
		      focalplaneAZrolled[ det] -= EL[det]*rollPendAngle[ sample]; 
		    }
		}
	      
	      azel_2_hadec_multidetector(boresightAZ[sample],boresightEL[sample],
					 &focalplaneAZrolled[0], &cosdELrolled[0],
					 &sindELrolled[0],ndetectors,cosL,sinL,
					 &ha_rad[0],&pointingDec[arrayindex],
					 &pointingcosDec[arrayindex]);
		  
	      for ( det = 0; det < ndetectors; det++)
		{	      
		  raindex=arrayindex+det;
		  ha2ra(&ha_rad[det],&lst[sample],1,&pointingRA[raindex]);
		
		  if(j == 1)
		    {
		      RAtemp[raindex]=pointingRA[raindex];
		      Dectemp[raindex]=pointingDec[raindex];
		    }
		  else
		    {
		      pointingBeta[raindex]=PI-atan2((RAtemp[raindex]-pointingRA[raindex])*pointingcosDec[raindex],
						     (Dectemp[raindex]-pointingDec[raindex]));
		    }
		}
	    }
	  //	  gnuplot_plot(rollPendAngle, nsamples,RAD2DEG,"output/","Rollangle",1);
	  //	  gnuplot_plot(pointingBeta,nsamples,RAD2DEG,"output/","beta",1);
	  //	  exit(-1);

	}
      free( cosdELrolled); free( sindELrolled); free( focalplaneAZrolled);
      free(RAtemp); free(Dectemp);
    }
  return(0);
}

int get_boresight_radecbeta(long int nsamples, double boresightAZ[],
			    double boresightEL[],
			    
			    double lst[], double rollPendAngle[],double latitude_rad,
			    /* Precomputed info about LST and pendulation for each sample,
			       and in general all information relating to the orientation
			       of the telescope at each sample.
			    */
			    double *pointingRA, double *pointingDec, double *pointingBeta,
			    double *pointingcosDec)
{
  long int sample;

  double cosL = cos(latitude_rad);
  double sinL = sin(latitude_rad);
  
  /*First calculate the boresight RA/Dec */  
  double  *ha;
  ha=(double *)calloc(nsamples, sizeof(double));  

  azel_2_hadec(&boresightAZ[0],&boresightEL[0],
	       nsamples, cosL,sinL,&ha[0],&pointingDec[0],&pointingcosDec[0]);
  ha2ra(&ha[0],&lst[0],nsamples,&pointingRA[0]);
  
  /* Now calculate orientation of the boresight.
     Requires to compute RA/Dec for one more point.*/
  double *displacedEL, *displacedAZ, *displacedcosDec, *displacedRA, *displacedDec ;
  displacedEL=(double *)calloc(nsamples, sizeof(double));  
  displacedAZ=(double *)calloc(nsamples, sizeof(double));  
  displacedcosDec=(double *)calloc(nsamples, sizeof(double));  
  displacedRA=(double *)calloc(nsamples, sizeof(double));  
  displacedDec=(double *)calloc(nsamples, sizeof(double));  
  
  if( rollPendAngle != NULL)  
    {
      for(sample=0;sample<nsamples;sample++) /* Loop over samples.*/
	{
	  displacedEL[sample] = boresightEL[sample] +
	    DELTAEL*(1.-rollPendAngle[ sample]*rollPendAngle[ sample]/2. );
	  displacedAZ[sample] = boresightAZ[sample] +
	    DELTAEL*rollPendAngle[ sample];
	}
    }
  else
    {
      for(sample=0;sample<nsamples;sample++) /* Loop over samples.*/
	{
	  displacedEL[sample] = boresightEL[sample] + DELTAEL;
	  displacedAZ[sample] = boresightAZ[sample];
	}
    }

  azel_2_hadec(&displacedAZ[0],&displacedEL[0],nsamples,cosL,sinL,&ha[0],
	       &displacedDec[0],&displacedcosDec[0]);
  free(displacedAZ); free(displacedEL); free(displacedcosDec);

  ha2ra(&ha[0],&lst[0],nsamples,&displacedRA[0]);
  free(ha);
  
  for(sample=0;sample<nsamples;sample++) /* Loop over samples.*/
    {
      pointingBeta[sample]=PI-atan2((displacedRA[sample]-pointingRA[sample])*pointingcosDec[sample],
      				    displacedDec[sample]-pointingDec[sample]);
    }
  free(displacedRA); free(displacedDec);
  return(0);
}

