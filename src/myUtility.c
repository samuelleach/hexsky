
#include "myUtility.h"

// specific

double EBEx_getSamplingRate( EBEX_PARAMETERS *inParams)

{
  return( inParams->timebetweensamples);
}

// general

double getSamplingRate( void *inParams, char *expt)

{
  if( strcmp( expt, "EBEx") == 0)
  {
     return( EBEx_getSamplingRate( (EBEX_PARAMETERS *)inParams));
  }
  else
  {
    return( 0);
  }
}
