/* Code to determine the sky coverage 
   given a particular scan strategy */

#define _GNU_SOURCE
/* I want to use the NAN test functions, which are gnu defined */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "ebex_parameters.h"
#include "utilities_parameters.h"
#include "utilities_gnuplot.h"
#include "pointing_library.h"
#include "ebex_scanning.h"
#include "ebex_focalplane.h"
#include "ebex_gondola.h"
#include "prandom.h"
#include "reconstructErrors.h"
#include "myPointingRoutine.h"
#include "myFocalPlane.h"
#include "myUtility.h"

#if MPI
#include "mpi.h"
#endif

int main(int argc, char *argv[]) {

  double *boresightAZerr, *boresightELerr, starSig2, gyroSig2;
  int elevationstep,scan;
  long int index, idummy;
  int repointing_index,det_index,ndet,nsample,i,myRank,numProc, iseed = -1001;
  char filename[1024];

  EBEX_PARAMETERS params;
  
  /* Launch MPI (if specified by the compiler with -DMPI */
#if MPI
  MPI_Init(&argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &numProc);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);
#else
  myRank=0;
  numProc=1;
#endif
  
  if (argc == 2) { 
    ebex_parameters_read(argv[1],&params);
  } else {
    printf("Usage: hexsky config.par \nQuitting\n");
#if MPI
    MPI_Abort(MPI_COMM_WORLD, 1);
    return(1);
#else
    exit(-1);
#endif
  }

  /*-------- Check that total scanning time per day is less than one day. -------*/
  float totaltime = params.totalt*params.numberchop*
    params.numberelestep*params.numberscan;   
  if(totaltime > 1.*DAY2SEC){ 
    printf("Daily scanning strategy exceed one day duration by %f percent. \n",
	   (totaltime*SEC2DAY-1.)*100.);
    exit(-1);
  } else {
    printf("Daily scanning strategy below one day duration by %f percent. \n",
	   fabs(totaltime*SEC2DAY-1.)*100.);
  }

  /*---------- Print out inter-sample distance in arcmin. -------------*/
  double intersampledistance= params.maxspeed_deg * DEG2ARCMIN *
    params.timebetweensamples;
  printf("Max distance between samples = %f arcmin, %f arcsec. \n",
	 intersampledistance,intersampledistance*ARCMIN2ARCSEC);
  
  /*------------- Print out inter-elevation step size arcmin. ------------*/
  double elevationstep_estimate=params.targetdecrange/params.numberelestep*DEG2ARCMIN;
  printf("Maximum distance between elevation steps needs to be roughly = %f arcmin\n",
	 elevationstep_estimate);
  printf("in order to cover targetdecrange = %f degree.\n",params.targetdecrange);
  if( elevationstep_estimate> 2.*params.elestepmax_arcmin){
    printf("Warning: targetdecrange is probably too big for chosen elestepmax_arcmin = %f arcmin\n",
	  params.elestepmax_arcmin);
  }
	 
  double latitude_rad = params.latitude_deg * DEG2RAD;
  double cellsize_rad = params.cellsize_arcmin * ARCMIN2RAD; 
  double cellsize_deg = params.cellsize_arcmin * ARCMIN2DEG;
  
  /*-------------- Dump out information in human readable form. ------------ */
  ebex_parameters_writeinfo(params.outfileroot,params);
  
  FILE *gnuplotlogfile;/* Pointers to the print files */  
  sprintf(filename,"%s_%s",params.outfileroot,"gnuplot.script");
  gnuplotlogfile = fopen(filename,"w+"); /* Setup a log file for
					    gnuplot commands used */

  //  starSig2 = 3.76e-10;                           /* in [Radians^2] <=> 4'' - from Greg */
  //  gyroSig2 = 1.90e-12*params.timebetweensamples; /* in [Radians^2/sec] <=> 0.067 deg/sqrt(sec) - from Shaul */

  //  starSig2 = 3.76e-10; /*HARD WIRED FOR THE MOMENT*/
  //  gyroSig2 = 3.8e-10;

  starSig2=pow(params.starcamera_noise*ARCSEC2RAD,2.);                                  /* in [Radians^2] <=> 4'' - from Greg */
  gyroSig2=pow(params.gyro_noise*DEG2RAD,2.)/HR2SEC*params.timebetweensamples;/* in [Radians^2/sec] <=> 0.067 deg/sqrt(hr) - from Shaul */  
  
  printf("1e10 x gyroSig2 %f, 1e10 x starSig2 %f\n",1.e10*gyroSig2,1.e10*starSig2);



  /*---------------- Set up the focalplane elements -----------------*/
  double focalplaneAZ[735],focalplaneEL[735];
  int detectorindex[3]={0,396,594};
  int ndetectors[3];
  int nchannel=1,channel;
  ndetectors[0]=params.noofdetectors;

  if(params.noofdetectors == 1) {
    setupfocalplane_boresight(focalplaneAZ,focalplaneEL);
  } else if(params.noofdetectors == 141) {
    setupfocalplane_410ghz(focalplaneAZ,focalplaneEL);
  } else if(params.noofdetectors == 198) {
    setupfocalplane_250ghz(focalplaneAZ,focalplaneEL);
  } else if(params.noofdetectors == 396) {
    setupfocalplane_150ghz(focalplaneAZ,focalplaneEL);
  } else if(params.noofdetectors == 735) {
    setupfocalplane_horizontal(focalplaneAZ,focalplaneEL);
    ndetectors[0]=396;
    ndetectors[1]=198;
    ndetectors[2]=141;
    nchannel=3;
  } else {
    setupfocalplane_150ghz(focalplaneAZ,focalplaneEL);
  }
  if(params.wantplots && myRank==0)
    gnuplot_plot2d(focalplaneEL,focalplaneAZ,params.noofdetectors,
		   params.outfileroot,"150GHz",params.displayplots);  

  // added part with the high level routines ...

  // set up the focal plane structure

  FPLANE focalPlane;

  setFocalPlane( (void *)&params, &focalPlane, "EBEx");

  // and now the scans primitives ...

  SKYSCAN ebexScan;
  
  /* allocate the structure for the scan params */
  initScanStruct( (void *)&params, &ebexScan, "EBEx");   // this routine will allocate memory to store all the scan patterns

  setSkyScan( (void *)&params, ebexScan.npttrn, 0, ebexScan.npath, &ebexScan, "EBEx");
  
  int firstSample = 0, lastSample = 1000;
  double *ra, *dec, sampRate;

  ra = (double *)calloc( lastSample-firstSample+1, sizeof( double));
  dec = (double *)calloc( lastSample-firstSample+1, sizeof( double));

  sampRate = getSamplingRate( (void *)&params, "EBEx");

  getPointing( firstSample, lastSample, sampRate, ra, dec, ebexScan, "EBEx");  

  free( ra); free( dec); 
  destroyScanStruct( &ebexScan);
  destroyFocalPlaneStruct( &focalPlane);

  exit( 1); // the end of the test section
  
#if MPI
  MPI_Barrier(MPI_COMM_WORLD);
  MPI_Finalize();
#endif
  return(0);
}
