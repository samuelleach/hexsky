#include "utilities_healpix.h"

/* void healpixMap_Read(HEALPIXMAP *M, char *infile){ */
/*   /\* Purpose: read in a synfast-like Healpix map. *\/ */
/*   long nside; */
/*   char ordering,coordsys; */
/*   int polar,deriv; */


/*   /\*Open file and get fits header information: *\/ */
/*   get_fits_info(infile,&nside,&ordering,&coordsys,&polar,&deriv); */

/*   /\*Initialise map *\/ */
/*   healpixMap_Init(M,nside,ordering,coordsys,polar,deriv); */

/*   /\*Free map *\/ */
/*   //healpixMap_Free(M); */



/*   /\*Read in data *\/ */
/*   long npix,nmap; */
/*   float *data; */
/*   npix = 12*nside*nside; */
/*   nmap=1; */

/*   //  data=input_map(infile,nmap); */
/* } */


void healpixMap_Init(HEALPIXMAP *M, long nside, char ordering, char coordsys,
		     int polar, int deriv)
{
  /* Purpose: initialise a Healpix map.*/
  int nmap=1;
  long npix= 12*nside*nside;
  
  M->nside=nside;
  M->ordering=ordering;
  M->coordsys=coordsys;
  M->polar=polar;
  M->deriv=deriv;

  if(M->polar)
    nmap=3;
  
  M->IQU = (float *)malloc(((size_t)npix*nmap)*sizeof(float));      
  
  if(deriv >= 1)
    M->dIQU = (float *)malloc(((size_t)npix*nmap*2)*sizeof(float));      
  
  if(deriv >= 2)
    M->d2IQU = (float *)malloc(((size_t)npix*nmap*3)*sizeof(float));      
  
}

void healpixMap_Free(HEALPIXMAP *M)
{
  /* Purpose: destroy a Healpix map.*/
  
  free(M->IQU);
  
  if(M->deriv >= 1)
    free(M->dIQU);
  
  if(M->deriv >= 2)
    free(M->d2IQU);
  
}

void get_healpix_pixelnumbers_ring(double ra_rad[],double dec_rad[],
				   long int nsample, long int nside,
				   long int *ipix)
{
  /*Purpose: Given coordinate (ra_rad, dec_rad) and Healpix nside,
    this subroutine returns the Healpix pixel numbers (*ipix)
    for Healpix ring format. */
  
  long int sample;
  double theta;
  
  for(sample=0;sample<nsample;sample++)
    {
      theta = PIBYTWO - dec_rad[sample];
      ang2pix_ring(nside,theta,ra_rad[sample], &ipix[sample]);
    }
}
