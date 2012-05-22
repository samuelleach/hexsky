#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "healpixObj.h"
#define _GNU_SOURCE

int main(int argc, char *argv[]) {

  //  char fname[300];
  float *Map;
  int nmaps=12;
  int npix=12*1024*1024;
  Map = (float *)calloc( nmaps*npix, sizeof( float));

  printf("hello world \n");

  //  healpixMap_Read(&M,"input/temp.fits");
  
  //  sprintf(fname,"%s","/home/leach/ebexscanning_devel/input/r00502_lensedmap.fits");
  printf("hello world \n");
  //  read_tqu_map("/home/leach/ebexscanning_devel/input/r00502_lensedmap.fits",npix,Map);
  read_tqu_map("/home/leach/ebexscanning_devel/input/test.fits",npix,Map);

  return(1);
}
