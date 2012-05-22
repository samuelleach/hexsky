
#include "myPointingRoutine.h"

int initScanStruct(void *params, SKYSCAN *skyScan, char *expt)

{
  int i, nsamp[2];
  
  skyScan->npttrn = getNumPatterns( params, expt);
  skyScan->npath = getNumScanPaths( params, expt);
  
  skyScan->spath = (SCANPATH *)calloc( skyScan->npath, sizeof( SCANPATH));
  skyScan->pattern = (SPATTERN *)calloc( skyScan->npttrn, sizeof( SPATTERN));
  
  for( i = 0; i < skyScan->npttrn; i++) 
  {
     getNumSampPerPattern( params, i, skyScan->npttrn, nsamp, expt);
	 skyScan->pattern[ i].phi.nel = nsamp[0];
	 skyScan->pattern[ i].theta.nel = nsamp[1];	 

	 skyScan->pattern[ i].phi.tme = (double *)calloc( skyScan->pattern[ i].phi.nel, sizeof( double));
	 skyScan->pattern[ i].phi.cor = (double *)calloc( skyScan->pattern[ i].phi.nel, sizeof( double));
	 skyScan->pattern[ i].phi.vel = (double *)calloc( skyScan->pattern[ i].phi.nel, sizeof( double));

	 skyScan->pattern[ i].theta.tme = (double *)calloc( skyScan->pattern[ i].theta.nel, sizeof( double));
	 skyScan->pattern[ i].theta.cor = (double *)calloc( skyScan->pattern[ i].theta.nel, sizeof( double));
	 skyScan->pattern[ i].theta.vel = (double *)calloc( skyScan->pattern[ i].theta.nel, sizeof( double));
  }
  
  return( 1);
}

int destroyScanStruct( SKYSCAN *skyScan)

{
  int i;
  
  for( i = 0; i < skyScan->npttrn; i++) 
  {
     free( skyScan->pattern[ i].phi.tme);
     free( skyScan->pattern[ i].phi.cor);
     free( skyScan->pattern[ i].phi.vel);

     free( skyScan->pattern[ i].theta.tme);
     free( skyScan->pattern[ i].theta.cor);
     free( skyScan->pattern[ i].theta.vel);
  }


  free( skyScan->spath);
  free( skyScan->pattern);
  
  return( 1);
}

int getNumPatterns( void *inParams, char *expt)

{
  if( strcmp( expt, "EBEx") == 0)
  {
     EBEx_getNumPatterns( inParams);
	 return( 1);
  }
  else
  {
     return( 0);
  }

}

int getNumScanPaths( void *inParams, char *expt)

{

  if( strcmp( expt, "EBEx") == 0)
  {
     EBEx_getNumScanPaths( (EBEX_PARAMETERS *)inParams);
	 return( 1);
  }
  else
  {
     return( 0);
  }

}

int getNumSampPerPattern( void *inParams, int ipttrn, int npttrn, int *nsamp, char *expt)

{

  if( strcmp( expt, "EBEx") == 0)
  {
     EBEx_getNumSampPerPattern( (EBEX_PARAMETERS *)inParams, ipttrn, npttrn, nsamp);
	 return( 1);
  }
  else
  {
     return( 0);
  }

}

int setScanPatterns( void *inParams, int npttrn, SPATTERN *pattern, char *expt)

{

  if( strcmp( expt, "EBEx") == 0)
  {
     EBEx_setScanPatterns( (EBEX_PARAMETERS *)inParams, npttrn, pattern);
	 return( 1);
  }
  else
  {
     return( 0);
  }

}

int setScanPaths( void *inParams, int firstPaths, int npaths, double pathTime, SCANPATH *spath, char *expt)

{

  if( strcmp( expt, "EBEx") == 0)
  {
     EBEx_setScanPaths( (EBEX_PARAMETERS *)inParams, firstPaths, npaths, pathTime, spath);
	 return( 1);
  }
  else
  {
     return( 0);
  }

}

int setSkyScan( void *inParams, int npttrn, int firstPath, int npaths, SKYSCAN *currentSkyScan, char *expt)

{

  if( strcmp( expt, "EBEx") == 0)
  {
	 EBEx_setSkyScan( (EBEX_PARAMETERS *)inParams, npttrn, firstPath, npaths, currentSkyScan);
	 return( 1);
  }
  else
  {
     return( 0);
  }

}

int getPointing( double firstSample, double lastSample, double sampRate, double *ra, double *dec, SKYSCAN currentSkyScan, char *expt)

     /* calculates pointing vectors ra and dec for a range of samples between firstSample and lastSample *
      * for the scan defined by currentScan - rs 11/10/2006 */

{


  if( strcmp( expt, "EBEx") == 0)
  {
     EBEx_getPointing( firstSample, lastSample, sampRate, ra, dec, currentSkyScan);
     return( 1);
  }
  else
  {
     return( 0);
  }

}

// EBEx specific part below

int EBEx_getNumPatterns( EBEX_PARAMETERS *inParams)

{
   if( (*inParams).dofirstdaydeeper == 1) return( 2);
   else return( 1);
}

int EBEx_getNumScanPaths( EBEX_PARAMETERS *inParams)

{
  return( (*inParams).totaldays*(*inParams).numberscan*(*inParams).numberelestep);
}

int EBEx_getNumSampPerPattern( EBEX_PARAMETERS *inParams, int ipttrn, int npttrn, int *nsamp)

{
   if( npttrn == 2)
   {
     switch( ipttrn)
     {
       case 0: nsamp[0] = (*inParams).numberchop*(int )ceil( ((*inParams).totalt/2.)/(*inParams).timebetweensamples+1); /* phi */
	           nsamp[1] = 2;                                                 /* theta */ 

	   break;
       case 1: nsamp[0] = (*inParams).numberchop*(int )ceil( (*inParams).totalt/(*inParams).timebetweensamples+1);      /* phi */
			   nsamp[1] = 2;                                                 /* theta */

	   break;
	   default: return( 0);
     }
   }
   else
   {
     switch( ipttrn)
     {
       case 0: nsamp[0] = (*inParams).numberchop*(int )ceil( (*inParams).totalt/(*inParams).timebetweensamples+1);      /* phi */
	           nsamp[1] = 2;                                                /* theta */ 

	   break;
	   default: return( 0);
     }   
   }
   return( 1);
}

int EBEx_setScanPatterns( EBEX_PARAMETERS *inParams, int npttrn, SPATTERN *pattern)

{
  int ipttrn = 0, it;
  long idummy;
  double maxspeed_rad = (*inParams).maxspeed_deg, ddummy;

  if( npttrn == 2)
  {
    if((*inParams).wantsinescanning == 0)
    {
      setupscans_triangle((*inParams).totalt/2., (*inParams).timebetweensamples, maxspeed_rad,
			              (*inParams).maxaccel_rad, (*inParams).numberchop*2,
						  pattern[ ipttrn].phi.cor, pattern[ ipttrn].phi.vel,
 			              &idummy, &pattern[ ipttrn].phi.nel, pattern[ ipttrn].phi.tme, &pattern[ ipttrn].dtime);
    } 
	else 
	{
      setupscans_sinusoidal((*inParams).totalt/2., (*inParams).timebetweensamples, maxspeed_rad,
			                (*inParams).numberchop*2, pattern[ ipttrn].phi.cor, pattern[ ipttrn].phi.vel,
			                &idummy, &pattern[ ipttrn].phi.nel, pattern[ ipttrn].phi.tme, &pattern[ ipttrn].dtime);
    }
		
	ipttrn++;
  }

  if( (*inParams).wantsinescanning == 0)
  {
	 setupscans_triangle((*inParams).totalt, (*inParams).timebetweensamples, maxspeed_rad,
						 (*inParams).maxaccel_rad, (*inParams).numberchop, 
			             pattern[ ipttrn].phi.cor, pattern[ ipttrn].phi.vel,
						 &idummy, &(pattern[ ipttrn].phi.nel), &(pattern[ ipttrn].dtime), &ddummy);
  } 
  else 
  {
	 setupscans_sinusoidal((*inParams).totalt, (*inParams).timebetweensamples, maxspeed_rad,
						   (*inParams).numberchop, pattern[ ipttrn].phi.cor, pattern[ ipttrn].phi.vel,
						   &idummy, &pattern[ ipttrn].phi.nel, &(pattern[ ipttrn].dtime), &ddummy);
  }

  for( ipttrn = 0; ipttrn < npttrn; ipttrn++)
  {
    /* phi time values */
    for( it = 0; it < pattern[ ipttrn].phi.nel; it++) pattern[ ipttrn].phi.tme[it] = it*(*inParams).timebetweensamples;

	pattern[ ipttrn].theta.tme[0] = pattern[ ipttrn].phi.tme[0];
	pattern[ ipttrn].theta.tme[1] = pattern[ ipttrn].phi.tme[ pattern[ ipttrn].phi.nel-1];	
	pattern[ ipttrn].theta.cor[0] = pattern[ ipttrn].theta.cor[1] = 0.0;   /* constant elevation scanning */
	pattern[ ipttrn].theta.vel[0] = pattern[ ipttrn].theta.vel[1] = 0.0;
  }
  return( 1);
}

int EBEx_setScanPaths( EBEX_PARAMETERS *inParams, int firstPath, int npaths, double pathTime, SCANPATH *spath)

{
  double *dvdummy, *ra, *dec;
  int is, ntruePaths;
  
  dvdummy = (double *)calloc( npaths, sizeof( double));
  ra = (double *)calloc( npaths, sizeof( double));
  dec = (double *)calloc( npaths, sizeof( double));

  ntruePaths = npaths/(*inParams).numberelestep;

  setuprepointings( (*inParams).startday, (*inParams).totaldays, firstPath, ntruePaths,
		            *inParams, pathTime, dvdummy, dvdummy, ra, dec);

  for( is = 0; is < npaths-firstPath; is++)
    {
      spath[is].phi = ra[ is]; spath[is].theta = dec[ is];
    }

  free( dvdummy); free( ra); free( dec);

  return( 1);
}

int EBEx_setSkyScan( EBEX_PARAMETERS *inParams, int npttrn, int firstPath, int npaths, SKYSCAN *currentSkyScan)

{
   int is, js, ipttrn, ipaths, jpaths, firstPathNow;

   EBEx_setScanPatterns( inParams, npttrn, currentSkyScan->pattern);
   
   if( (*inParams).dofirstdaydeeper == 1)
   {
      ipttrn = 0;
	  ipaths = (*inParams).numberscan*(*inParams).numberelestep;

	  if( firstPath < ipaths)
	  {
	     ipaths = min( npaths, ipaths-firstPath);
         EBEx_setScanPaths( inParams, firstPath, ipaths, currentSkyScan->pattern[0].dtime, currentSkyScan->spath);

	     currentSkyScan->dtime = ipaths*currentSkyScan->pattern[0].dtime;
	     for( is = 0; is < ipaths; is++) currentSkyScan->spath[ is].type = 0;
      }

	  jpaths = currentSkyScan->npath;
	  
	  if( firstPath < jpaths)
	  {
	    ipttrn = 1;

		firstPathNow  = max( firstPath, ipaths);

        EBEx_setScanPaths( inParams, firstPathNow, min( npaths-firstPathNow, jpaths-firstPathNow), currentSkyScan->pattern[0].dtime, currentSkyScan->spath);	
	  
	    currentSkyScan->itime = (*inParams).startday;
	    currentSkyScan->dtime += min( npaths-firstPathNow, jpaths-firstPathNow)*currentSkyScan->pattern[0].dtime;
	  
	    for( is = ipaths; is < jpaths; is++) currentSkyScan->spath[ is].type = 1;
	  }
   }
   else
   {
      ipttrn = 0;

      jpaths = currentSkyScan->npath;
	  
      if( firstPath < jpaths)
       {

          EBEx_setScanPaths( inParams, firstPath, min( npaths, jpaths), currentSkyScan->pattern[0].dtime, currentSkyScan->spath);
	  
	  currentSkyScan->itime = (*inParams).startday;
	  currentSkyScan->dtime += min( jpaths, npaths)*currentSkyScan->pattern[0].dtime;
	  
	  for( is = ipaths; is < min( npaths, jpaths); is++) currentSkyScan->spath[ is].type = ipttrn;
       }
	  	  
   }
   return( 1);
}

int EBEx_getPointing( double firstSample, double lastSample, double sampRate, double *ra, double *dec, SKYSCAN currentSkyScan)

     /* calculates pointing vectors ra and dec for a range of samples between firstSample and lastSample *
      * for the scan defined by currentScan - rs 11/10/2006 */

{
  return( 1);
}
