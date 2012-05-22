
#include "myFocalPlane.h"


int setFocalPlane( void *inParams, FPLANE *focalPlane, char *expt)

{
  if( strcmp( expt, "EBEx") == 0)
    {
      EBEx_setFocalPlane( (EBEX_PARAMETERS *)inParams, focalPlane);
    }
  else
    {
      return( 0);
    }

    
  return( 1);
}

int destroyFocalPlaneStruct( FPLANE *focalPlane)

{
  int ic;

  for( ic = 0; ic < focalPlane->nchan; ic++)
  {
     free( focalPlane->chan[ ic].phi);
     free( focalPlane->chan[ ic].theta);
     free( focalPlane->chan[ ic].beam);
  }  

  free( focalPlane->chan);

  return( 1);
}


int EBEx_setFocalPlane( EBEX_PARAMETERS *inParams, FPLANE *focalPlane)

{

   int ic;

   switch( inParams->noofdetectors) 
   {
     case 1   : 
                focalPlane->nchan = 1;
                focalPlane->chan = (FRQCHANNEL *)calloc( focalPlane->nchan, sizeof( FRQCHANNEL));

                focalPlane->chan[ 0].ndet = inParams->noofdetectors;
                focalPlane->chan[ 0].phi = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));
                focalPlane->chan[ 0].theta = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));
                focalPlane->chan[ 0].beam = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));

                setupfocalplane_boresight( focalPlane->chan[ 0].phi, focalPlane->chan[ 0].theta); 

                break;

     case 140 : 
                focalPlane->nchan = 1;
                focalPlane->chan = (FRQCHANNEL *)calloc( focalPlane->nchan, sizeof( FRQCHANNEL));

                focalPlane->chan[ 0].ndet = inParams->noofdetectors;
                focalPlane->chan[ 0].phi = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));
                focalPlane->chan[ 0].theta = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));
                focalPlane->chan[ 0].beam = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));

                setupfocalplane_410ghz( focalPlane->chan[ 0].phi, focalPlane->chan[ 0].theta);

                break;

     case 196 : 
                focalPlane->nchan = 1;
                focalPlane->chan = (FRQCHANNEL *)calloc( focalPlane->nchan, sizeof( FRQCHANNEL));

	        focalPlane->chan[ 0].ndet = inParams->noofdetectors;
	        focalPlane->chan[ 0].phi = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));
	        focalPlane->chan[ 0].theta = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));
	        focalPlane->chan[ 0].beam = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));

	        setupfocalplane_250ghz( focalPlane->chan[ 0].phi, focalPlane->chan[0].theta);

                break;

     case 728 : 
                focalPlane->nchan = 3;

                int  ndets[3], freq[3];

                ndets[0] = 396; freq[0] = 150;
                ndets[1] = 198; freq[1] = 250;
                ndets[2] = 141; freq[2] = 410;

                focalPlane->chan = (FRQCHANNEL *)calloc( focalPlane->nchan, sizeof( FRQCHANNEL));

                for( ic = 0; ic < focalPlane->nchan; ic++)
	        {
	           focalPlane->chan[ ic].ndet = ndets[ ic];
	           focalPlane->chan[ ic].phi = (double *)calloc( focalPlane->chan[ ic].ndet, sizeof( double));
	           focalPlane->chan[ ic].theta = (double *)calloc( focalPlane->chan[ ic].ndet, sizeof( double));
	           focalPlane->chan[ ic].beam = (double *)calloc( focalPlane->chan[ ic].ndet, sizeof( double));

	           setupfocalplane_horizontal_new( freq[ic], focalPlane->chan[ ic].phi, focalPlane->chan[ ic].theta);
	        }

                break;

      case 392 : default:

	focalPlane->nchan = 1;
                focalPlane->chan = (FRQCHANNEL *)calloc( focalPlane->nchan, sizeof( FRQCHANNEL));

       	        focalPlane->chan[ 0].ndet = inParams->noofdetectors;
	        focalPlane->chan[ 0].phi = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));
	        focalPlane->chan[ 0].theta = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));
	        focalPlane->chan[0].beam = (double *)calloc( focalPlane->chan[ 0].ndet, sizeof( double));

	        setupfocalplane_150ghz( focalPlane->chan[ 0].phi, focalPlane->chan[0].theta);
   }
   return( 1);
      
}

int  setupfocalplane_horizontal_new( int freq, double *focalplaneazsteps, double *focalplaneelsteps)
{

  switch( freq)
  {
    case 150: setupfocalplane_150ghz( focalplaneazsteps, focalplaneelsteps); break;
    case 250: setupfocalplane_250ghz( focalplaneazsteps, focalplaneelsteps); break;
    case 410: setupfocalplane_410ghz( focalplaneazsteps, focalplaneelsteps); break;

    default: return( 0);
  }

  return( 1);
}
