/* Code to determine the sky coverage 
   given a particular scan strategy */

/* 070717_16:00:13: before switching to fwrite to write binary output */
/* 070820_09:49:29: before commenting out pop up windows from gnuplot */
/* ===================================================================================== */

#define _GNU_SOURCE
/* I want to use the NAN test functions, which are gnu defined */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "getdata.h" // Dirfile library for output.
#include "utilities_parameters.h"
#include "utilities_pointing.h"
#include "utilities_gnuplot.h"
#include "pointing_library.h"
#include "ebex_parameters.h"
#include "ebex_scanning.h"
#include "ebex_focalplane.h"
#include "ebex_gondola.h"
#include "prandom.h"
#include "reconstructErrors.h"
/*#include "conditionNumber.h"*/
/*#include "utilities_healpix.h"*/
#include <fcntl.h>
/* #include "myFocalPlane.h" */
#if MPI
#include "mpi.h"
#endif


/* ======================================================================================= */
/* ======================================================================================= */
int main(int argc, char *argv[]) {

  double modulated_maxspeed_rad;
  double *boresightAZerr, *boresightELerr, starSig2, gyroSig2;
  int elevationstep;
  long int time_index, idummy, sample, nsample,halfscan,ii;
  int repointing_index,det_index,ndet,i,myRank,numProc, iseed = -1001;
  char filename[1024],file[1024];
  long int sample_num,isn,nsn,ss;
  int file_size, ifile, rtc, nbytes, fd;
  float *az_fpc_out, *el_fpc_out, *lst_out, *roll_pend_out, *beta_out;
  double *radecbeta_out,*rjd_out;
  char fpc_out_file[200];
  char pointing_out_file[200];
  double intersampledistance,elevationstep_estimate,latitude_rad,cellsize_rad,cellsize_deg;
  double focalplaneAZ[728],focalplaneEL[728];
  int detectorindex[3]={0,392,588};
  int ndetectors[3];
  int nchannel=1,channel;

  double np_ra_min, np_ra_max, np_dec_min, np_dec_max;
  double azthrow_deg,deltaDec_deg;

  FILE *gnuplotlogfile;
  FILE *pointingfile, *fp;

  EBEX_PARAMETERS params;
  CIVILTIME ct , startmission;

  np_ra_min  =  1000;
  np_ra_max  = -1000;
  np_dec_min =  1000;
  np_dec_max = -1000;

#if MPI
  /* Launch MPI (if specified by the compiler with -DMPI */
  MPI_Init(&argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &numProc);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);
#else
  myRank=0;
  numProc=1;
#endif

  if (argc == 2)
    { 
      ebex_parameters_read(argv[1],&params);
    }
  else
    {
      printf("Usage: hexsky config.par \nQuitting\n");
#if MPI
      MPI_Abort(MPI_COMM_WORLD, 1);
      return(1);
#else
      exit(-1);
#endif
    }

  struct stat st;
  if(stat(params.output_dir,&st) != 0)
    {
      printf("WARNING: output_dir is not present on this filesytem. Run:\n");      
      printf("mkdir -p %s \n",params.output_dir);      
      exit(-1);
    }

  nsn = (long int)pow(2,params.file_size);
  printf( "*********************************\n");
  printf( "*********************************\n");
  printf( "Number of samples per binary file, nsn = %li\n", nsn);

  az_fpc_out    = (float *)calloc( nsn, sizeof( float));
  el_fpc_out    = (float *)calloc( nsn, sizeof( float));
  lst_out       = (float *)calloc( nsn, sizeof( float));
  rjd_out        = (double *)calloc( nsn, sizeof( double));
  roll_pend_out = (float *)calloc( nsn, sizeof( float)); 
  /* beta_out      = (float *)calloc( nsn, sizeof( float)); */
  radecbeta_out = (double *)calloc( 3*nsn, sizeof( double));
  sample_num = 0;
  ifile = 0;


  /*----------------------------------------------------------------------------*/
  /*-------- Check that total scanning time per day is less than one day -------*/
  /*----------------------------------------------------------------------------*/
  float totaltime = params.totalt*(float)(params.numberchop*params.numberelestep*params.numberscan);   
  if(totaltime > 1.*DAY2SEC)
    { 
      printf("Daily scanning strategy exceed one day duration by %f percent. \n",
	     (totaltime*SEC2DAY-1.)*100.);
      exit(-1);
    }
  else
    {
      printf("Daily scanning strategy below one day duration by %f percent. \n",
	     fabs(totaltime*SEC2DAY-1.)*100.);
    }

  /*-------------------------------------------------------------------*/
  /*---------- Print out inter-sample distance in arcmin. -------------*/
  /*-------------------------------------------------------------------*/
  intersampledistance= params.maxspeed_deg * DEG2ARCMIN * params.timebetweensamples;


  printf("Max distance between samples = %f arcmin, %f arcsec. \n",
	 intersampledistance,intersampledistance*ARCMIN2ARCSEC);
  
  /*------------- Print out inter-elevation step size arcmin. ------------*/
  elevationstep_estimate=params.targetdecrange/params.numberelestep*DEG2ARCMIN;

  printf("Maximum distance between elevation steps needs to be roughly = %f arcmin\n",
	 elevationstep_estimate);
  printf("in order to cover targetdecrange = %f degree.\n",params.targetdecrange);
  if( elevationstep_estimate > 2.*params.elestepmax_arcmin)
    {
      printf("Warning: targetdecrange is probably too big for chosen elestepmax_arcmin = %f arcmin\n",
	     params.elestepmax_arcmin);
    }

  latitude_rad = params.latitude_deg * DEG2RAD;
  cellsize_rad = params.cellsize_arcmin * ARCMIN2RAD; 
  cellsize_deg = params.cellsize_arcmin * ARCMIN2DEG;

  /*-------------- Dump out information in human readable form. ------------ */
  ebex_parameters_writeinfo(params.outfileroot,params);
  
  sprintf(filename,"%s_%s",params.outfileroot,"gnuplot.script");
  gnuplotlogfile = fopen(filename,"w+"); /* Setup a log file for
					    gnuplot commands used */

  starSig2=pow(params.starcamera_noise*ARCSEC2RAD,2.);                        /* in [Radians^2] <=> 4'' - from Greg */
  gyroSig2=pow(params.gyro_noise*DEG2RAD,2.)/HR2SEC*params.timebetweensamples;/* in [Radians^2/sec] <=> 0.067 deg/sqrt(hr) - from Shaul */  
  
  printf("1e10 x gyroSig2 %f, 1e10 x starSig2 %f\n",1.e10*gyroSig2,1.e10*starSig2);

  /*---------------- Set up the focalplane elements -----------------*/
  /*-----------------------------------------------------------------*/
  ndetectors[0]=params.noofdetectors;

  if(params.noofdetectors == 1)
    {
      setupfocalplane_boresight(focalplaneAZ,focalplaneEL);
    }
  else if(params.noofdetectors == 140)
    {
      setupfocalplane_410ghz(focalplaneAZ,focalplaneEL);
    }
  else if(params.noofdetectors == 196)
    {
      setupfocalplane_250ghz(focalplaneAZ,focalplaneEL);
    }
  else if(params.noofdetectors == 392)
    {
      setupfocalplane_150ghz(focalplaneAZ,focalplaneEL);
    }
  else if(params.noofdetectors == 728)
    {
      setupfocalplane_horizontal(focalplaneAZ,focalplaneEL);
      ndetectors[0]=392; ndetectors[1]=196; ndetectors[2]=140; nchannel=3;
    }
  else
    {
      setupfocalplane_150ghz(focalplaneAZ,focalplaneEL);
    }


  /*-----------------------------------------------------------------------------*/
  /*------- Rotate the focal plane and then dump to text file ebex_fpdb.txt -----*/
  /*-----------------------------------------------------------------------------*/
  rotate_focalplane(focalplaneAZ,focalplaneEL,params.noofdetectors,params.focalplane_phi0_deg);
//  write_focalplane_database(params.focalplane_phi0_deg);

//   if(params.wantplots && myRank==0)
//     gnuplot_plot2d(focalplaneEL,focalplaneAZ,RAD2DEG,RAD2DEG,params.noofdetectors,
//		    params.outfileroot,"focalplane",params.displayplots);  

  /*---------------------------------------------------------------*/
  /*---------------- Set up the chopping function -----------------*/
  /*---------------------------------------------------------------*/
  long int gna,nsamples_estimate;
  gna = (int) ceil(params.totalt/params.timebetweensamples); 
  nsamples_estimate = params.numberchop * gna;

  double *azisteps_rad, *azisteps_rad_i, *azisteps_rad_firstday, *speed_i, *speed_firstday;
  azisteps_rad_i        = (double *)(calloc(nsamples_estimate,sizeof(double)));
  azisteps_rad_firstday = (double *)(calloc(nsamples_estimate,sizeof(double)));
  speed_i               = (double *)(calloc(nsamples_estimate,sizeof(double)));
  speed_firstday        = (double *)(calloc(nsamples_estimate,sizeof(double)));

  long int nsamples_deepfirstday,nsamples_perelevationstep,nhalfscan_perelevationstep;
  double scantime,scantime_deepfirstday;
  long int nsamples_perhalfscan;
  double maxspeed_rad = params.maxspeed_deg * DEG2RAD;
  double turnaroundtime;


  if(params.wantcmbdipolescan)
    {
      setupscans_cmbdipole(params.totalt,params.timebetweensamples,maxspeed_rad,
			   params.maxaccel_rad,&azisteps_rad_i[0],&speed_i[0],
			   &nsamples_perhalfscan,&nsamples_perelevationstep,&scantime);
      azthrow_deg = 360.;
    }
  else
    {
      setupscans_trianglewithstop2(params.totalt,params.timebetweensamples,maxspeed_rad,
				   params.maxaccel_rad,params.stopt,params.numberchop,
				   &azisteps_rad_i[0],&speed_i[0],&nsamples_perhalfscan,
				   &nsamples_perelevationstep,&scantime,&turnaroundtime);
      azthrow_deg = fabs(azisteps_rad_i[0]-azisteps_rad_i[nsamples_perhalfscan])*RAD2DEG;
    }

  printf("Sample rate = %f Hz\n",1./params.timebetweensamples);
  if(params.wantplots && myRank==0)
     plotscans(azisteps_rad_i,speed_i,params.timebetweensamples,nsamples_perelevationstep,
	       params.outfileroot,gnuplotlogfile,params.displayplots);
   
  /*---------------------------------------------------------------------*/
  /*--------------- Setup a deeper scan for the first day ---------------*/
  /*---------------------------------------------------------------------*/
  if (params.dofirstdaydeeper == 1)
    {
      setupscans_trianglewithstop2(params.totalt/2.,params.timebetweensamples,maxspeed_rad,
				   params.maxaccel_rad,params.stopt,params.numberchop*2,
				   &azisteps_rad_firstday[0],&speed_firstday[0],&nsamples_perhalfscan,
				   &nsamples_perelevationstep,&scantime,&turnaroundtime);
       
      if(params.wantplots && myRank==0)
	plotscans(azisteps_rad_firstday,speed_firstday,params.timebetweensamples,
		  nsamples_perelevationstep,params.outfileroot,gnuplotlogfile,params.displayplots);
      
    }
  printf("Turnaround time [s] = %f\n",turnaroundtime);
  
  /*-------------------------------------------------------------------*/
  /*------------ Things related to calibrator scan mode ---------------*/
  /*-------------------------------------------------------------------*/
  if(params.wantcalibratorscan == 1)
    {
      if(params.numberchop != 1)
	{
	  printf("Warning: in calibrator scan mode, must set numberchop = 1\n");
	  exit(-1);
	}
      if(params.numberelestep % 2 != 0)
	{
	  printf("Warning: in calibrator scan mode, must set numberelestep to be an even number.\n");
	  exit(-1);
	}
      scantime=scantime/2.;
      nhalfscan_perelevationstep = 1;
    }
  else
    {
      nhalfscan_perelevationstep = params.numberchop*2;
    }


  /*-------------------------------------------------------------------------*/
  /*------------------- Check and plot the repointing strategy --------------*/
  /*-------------------------------------------------------------------------*/
   if(params.wantplots && myRank == 0)
     checkandplot_missionrepointings(params.startday, params.totaldays,
				     params.startscan,params.numberscan,
				     params,scantime,gnuplotlogfile,params.displayplots);

  double *boresightAZ,*boresightEL,*boresightPHI;
  boresightAZ = (double *)(calloc(nsamples_perhalfscan,sizeof(double)));
  boresightEL = (double *)(calloc(nsamples_perhalfscan,sizeof(double)));
  boresightPHI = (double *)(calloc(nsamples_perhalfscan,sizeof(double)));

  double *sample_times_sec, *lst_rad,*elePend_rad;
  double *aziPend_rad,*rollPend_rad,*twophi_hwp_rad,*rjd,*lon_deg,*lat_deg;
  float *lst_hr;
  sample_times_sec = baseline_double_init(nsamples_perelevationstep);
  lst_rad          = baseline_double_init(nsamples_perelevationstep);
  lst_hr           = baseline_float_init(nsamples_perelevationstep);
  lon_deg          = baseline_double_init(nsamples_perelevationstep);
  lat_deg          = baseline_double_init(nsamples_perelevationstep);
  elePend_rad      = (double *)(calloc(nsamples_perelevationstep,sizeof(double)));
  aziPend_rad      = (double *)(calloc(nsamples_perelevationstep,sizeof(double)));
  rollPend_rad     = (double *)(calloc(nsamples_perelevationstep,sizeof(double)));
  twophi_hwp_rad   = (double *)(calloc(nsamples_perelevationstep,sizeof(double)));
  rjd = (double *)(calloc(nsamples_perelevationstep,sizeof(double)));

  /*----------------------------------------------*/
  /*-------- Set up arrays for maps --------------*/
  /*----------------------------------------------*/
  long int decsize = (int) ((params.decmax - params.decmin) / cellsize_deg); 
  long int rasize = (int) ((params.ramax - params.ramin) / cellsize_deg *
			   cos((params.decmax + params.decmin)*DEG2RAD/2.)); 
  long int npixels= rasize*decsize;
  printf("%li by %li array required for map.\n",rasize, decsize);

  /*----------------------------------------------*/
  /*--------- Allocate memory for maps -----------*/
  /*----------------------------------------------*/
  long int *binnedhitcount, *scancrossingcount;
  binnedhitcount = squarepixel_countmap_init(npixels*nchannel);
  scancrossingcount = squarepixel_countmap_init(npixels*nchannel);
  float *dx_map_rad,*dy_map_rad;
  dx_map_rad = squarepixel_floatmap_init(npixels*nchannel);
  dy_map_rad = squarepixel_floatmap_init(npixels*nchannel);
  float *aTa11_map,*aTa12_map,*aTa13_map,*aTa22_map,*aTa23_map,*aTa33_map,*CN_map;
  aTa11_map = squarepixel_floatmap_init(npixels*nchannel);
  aTa12_map = squarepixel_floatmap_init(npixels*nchannel);
  aTa13_map = squarepixel_floatmap_init(npixels*nchannel);
  aTa22_map = squarepixel_floatmap_init(npixels*nchannel);
  aTa23_map = squarepixel_floatmap_init(npixels*nchannel);
  aTa33_map = squarepixel_floatmap_init(npixels*nchannel);
  CN_map = squarepixel_floatmap_init(npixels*nchannel);
    
  /*-------------------------------------------*/
  /*--------- Set up map parameters -----------*/
  /*-------------------------------------------*/
  double ra_centre_deg=(params.ramax+params.ramin)/2.0;
  double ra_centre_rad=ra_centre_deg*DEG2RAD;
  double racosdec_min_deg=(params.ramin-ra_centre_deg)*cos((params.decmax + params.decmin)*DEG2RAD/2.);
  double racosdec_min_rad=racosdec_min_deg*DEG2RAD;
  double decmin_rad=params.decmin*DEG2RAD;
  double elevationlimit_rad=params.elevationlimit*DEG2RAD;

  /*------------------------------------------------------------*/
  /*------------ Allocate memory for baselines -----------------*/
  /*------------------------------------------------------------*/
  double *dec_rad, *cosdec, *ra_rad, *beta_rad;
  double *dec_recon_rad, *cosdec_recon, *ra_recon_rad,*beta_recon_rad;
  double *dx_pix_rad,*dy_pix_rad,*dx_rad,*dy_rad; 
  dec_rad        = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  ra_rad         = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  cosdec         = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  beta_rad       = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  dec_recon_rad  = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  ra_recon_rad   = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  cosdec_recon   = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  beta_recon_rad = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  dx_pix_rad     = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  dy_pix_rad     = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  dx_rad         = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  dy_rad         = baseline_double_init(params.noofdetectors*nsamples_perhalfscan);
  long int *pixel;
  pixel          = baseline_longint_init(params.noofdetectors*nsamples_perhalfscan);

  /*--------------------------------------------------------------*/
  /*------------------- Set up healpix map -----------------------*/
  /*--------------------------------------------------------------*/
  float *aTa11_hmap,*aTa12_hmap,*aTa13_hmap,*aTa22_hmap,*aTa23_hmap,*aTa33_hmap;
  long *ipix;
  long int nside=1024;
  long int pix_index;
  double theta;
  long int npix=12*nside*nside;
  aTa11_hmap = (float *)calloc( npix*nchannel, sizeof( float));
  aTa12_hmap = (float *)calloc( npix*nchannel, sizeof( float));
  aTa13_hmap = (float *)calloc( npix*nchannel, sizeof( float));
  aTa22_hmap = (float *)calloc( npix*nchannel, sizeof( float));
  aTa23_hmap = (float *)calloc( npix*nchannel, sizeof( float));
  aTa33_hmap = (float *)calloc( npix*nchannel, sizeof( float));
  ipix=baseline_double_init(params.noofdetectors*nsamples_perhalfscan);

  /*-----------------------------------------------------------------------*/
  /*------------- Partition the jobs for MPI (or serial) job --------------*/
  /*-----------------------------------------------------------------------*/
  int *thisday, *thisscan;
  int nscans;  
  thisday  = (int *)(calloc(params.totaldays*params.numberscan,sizeof(int)));
  thisscan = (int *)(calloc(params.totaldays*params.numberscan,sizeof(int)));
  partitionscanrepeats(params.startday, params.totaldays,
		       params.startscan, params.numberscan,
		       numProc,myRank,&thisday[0],&thisscan[0],&nscans);

  /*-----------------------------*/
  /*------- dirfile stuff -------*/
  /*-----------------------------*/
  char df_directory[100]; // The dirfile directory
  int df_error,df_np,df_first_frame,df_last_frame;
  DIRFILE* D;
  sprintf( df_directory, "%s/dirfile", params.output_dir);
  if(params.append_data_to_dirfile)
    {
      D        = gd_open(df_directory, GD_RDWR | GD_CREAT | GD_UNENCODED | GD_VERBOSE);
      df_error = gd_error(D);
    }
  else 
    {
      D        = gd_open(df_directory, GD_RDWR | GD_CREAT | GD_EXCL | GD_UNENCODED | GD_VERBOSE);
      df_error = gd_error(D);

      if(df_error)
	{
	  printf("ERROR: dirfile already exists on disk. Run :\n"); 
	  printf("rm -rf %s\n",df_directory); 
	  printf("or use append_data_to_dirfile=1 in parameter file.\n");
	  exit(-1);
	}
    }

  /* GetData 0.7.2 */
  df_np = gd_add_raw(D,"RA",GD_FLOAT64,1,0);
  df_np = gd_add_raw(D,"DEC",GD_FLOAT64,1,0);
  df_np = gd_add_raw(D,"BETA",GD_FLOAT64,1,0);
  df_np = gd_add_raw(D,"RJD",GD_FLOAT64,1,0);
  df_np = gd_add_raw(D,"AZ",GD_FLOAT32,1,0);
  df_np = gd_add_raw(D,"EL",GD_FLOAT32,1,0);
  df_np = gd_add_raw(D,"LST",GD_FLOAT32,1,0);
  df_np = gd_add_raw(D,"ROLL",GD_FLOAT32,1,0);
  df_np = gd_add_raw(D,"LON",GD_FLOAT32,1,0);
  df_np = gd_add_raw(D,"LAT",GD_FLOAT32,1,0);
  df_first_frame = gd_nframes(D);
   
  /*-------------------------------------------*/
  /*------------- Begin scanning --------------*/
  /*-------------------------------------------*/
  int nrepointings_perday=params.numberscan*params.numberelestep;
  double *repointingAZ_rad, *repointingRA_deg, *repointingEL_rad, *repointingDec_deg;
  repointingAZ_rad  = (double *)(calloc(nrepointings_perday,sizeof(double)));
  repointingRA_deg  = (double *)(calloc(nrepointings_perday,sizeof(double)));
  repointingEL_rad  = (double *)(calloc(nrepointings_perday,sizeof(double)));
  repointingDec_deg = (double *)(calloc(nrepointings_perday,sizeof(double)));

  startmission.year  = params.year;
  startmission.month = params.month;
  startmission.day   = params.startday;
  startmission.secs  = params.starthour*HR2SEC;

  ct.year  = params.year;
  ct.month = params.month;

  sprintf( pointing_out_file, "%s/azel.dat", params.output_dir);
  pointingfile = fopen(pointing_out_file,"w+");

  /* Initialize the random number generator */
  PRNG_initialize( myRank, numProc, iseed);

  printf("Performing scanning.\n");
  /* ****** LOOP OVER DAYS AND SCAN REPEATS ******* */
  for(i=0;i<nscans;i++)
    {
      if(thisday[i] == startmission.day && params.dofirstdaydeeper == 1)
	{ 
	  azisteps_rad  = &azisteps_rad_firstday[0]; 
	}
      else
	{ 
	  azisteps_rad  = &azisteps_rad_i[0]; 
	}
      setuprepointings(thisday[i], 1, thisscan[i], 1,params,scantime,
		       &repointingRA_deg[0],&repointingDec_deg[0],
		       &repointingAZ_rad[0],&repointingEL_rad[0]);

      /*--------------------------*/
      /*CMB dipole scan parameters*/
      /*--------------------------*/
      if(params.wantcmbdipolescan)
	{
	  params.wantcoselmodulatedscanspeed=0;
	  repointingAZ_rad[0]= 0.;
	  repointingEL_rad[0]= params.cmbdipolescan_startel*DEG2RAD;
	  params.numberelestep=1;
	}
	  

      deltaDec_deg= fabs(repointingDec_deg[0]);//-repointingDec_deg[params.numberelestep-1]);
      repointing_index=-1;
      /* ****** LOOP OVER ELEVATION STEPS ******* */
      printf("Doing scan number %i, day %i\n",thisscan[i],thisday[i]);
      for (elevationstep=1; elevationstep<=params.numberelestep; elevationstep++) 
	{ 
	  repointing_index++;

	  if(params.noofdetectors > 1)
	    printf("Sampling elevation step %i, scan number %i, day %i\n",
		   elevationstep,thisscan[i],thisday[i]);

	  if (repointingEL_rad[repointing_index] > elevationlimit_rad)
	    {
	      printf("Warning: elevationlimit exceeded by %f degrees.\n",
		     (repointingEL_rad[repointing_index]-elevationlimit_rad)*RAD2DEG);
	      exit(-1);
	    }

	  if(params.wantcoselmodulatedscanspeed == 1)
	    {
	      modulated_maxspeed_rad = maxspeed_rad/cos(repointingEL_rad[repointing_index]);
	      setupscans_trianglewithstop2(params.totalt,params.timebetweensamples,
					   modulated_maxspeed_rad,
					   params.maxaccel_rad,params.stopt,params.numberchop,
					   &azisteps_rad_i[0],&speed_i[0],&nsamples_perhalfscan,
					   &nsamples_perelevationstep,&scantime,&turnaroundtime);
	    }
	  
	  get_sample_times(thisday[i], 1, thisscan[i], 1, elevationstep,1,
			   startmission.secs,params.timebetweensamples,
			   scantime,params.numberelestep,
			   nsamples_perelevationstep,&sample_times_sec[0]);
	  
	  ct.day=thisday[i];
	  //	  get_lst_rad(ct,startmission,&sample_times_sec[0],nsamples_perelevationstep,
	  //		      params.orbitspeed,params.longitude_start_deg,&lst_rad[0]);
	  //	  get_lst_rad_lon_deg(ct,startmission,&sample_times_sec[0],nsamples_perelevationstep,
	  //			      params.orbitspeed,params.longitude_start_deg,
	  //			      &lst_rad[0],&lon_deg[0],&lat_deg[0]);
	  get_lst_rad_lonlat_deg(ct,startmission,&sample_times_sec[0],nsamples_perelevationstep,
				 params.orbitspeed,params.longitude_start_deg,
				 params.latitude_deg,&lst_rad[0],&lon_deg[0],&lat_deg[0]);
	  for(ss=0;ss<nsamples_perelevationstep;ss++) 
	     lst_hr[ss]=lst_rad[ss]*RAD2HR;

	  get_rjd(ct,&sample_times_sec[0],nsamples_perelevationstep,&rjd[0]);
	  
	  if (params.wantelependulation == 1)
	    get_elePend_rad(&sample_times_sec[0],nsamples_perelevationstep,&elePend_rad[0]);
	  if (params.wantazipendulation == 1)
	    get_aziPend_rad(&sample_times_sec[0],nsamples_perelevationstep,&aziPend_rad[0]);
	  if (params.wantrollpendulation == 1)
	    get_rollPend_rad(&sample_times_sec[0],nsamples_perelevationstep,&rollPend_rad[0]);
	  
	  for(halfscan = 0; halfscan < nhalfscan_perelevationstep; halfscan++)
	    {
	      /* Gets pointings for all samples of one half scan for all detectors.*/
	      if (params.wantcalibratorscan == 1)
		{
		  time_index = nsamples_perhalfscan * ( (elevationstep+1) % 2); 
		}
	      else
		{
		  time_index = nsamples_perhalfscan * halfscan; 
		}

	      get_boresight_pointing(1,&repointingAZ_rad[repointing_index],
				     &repointingEL_rad[repointing_index],
				     nsamples_perhalfscan,&azisteps_rad[time_index],
				     &aziPend_rad[time_index],&elePend_rad[time_index],
				     &boresightAZ[0], &boresightEL[0]);
	      
	      get_boresight_radecbeta(nsamples_perhalfscan,&boresightAZ[0],
				      &boresightEL[0],&lst_rad[time_index],
				      &rollPend_rad[time_index], latitude_rad,
				      &ra_rad[0],&dec_rad[0],&beta_rad[0],&cosdec[0]);

	      /* DIRFILE STUFF */
	      df_last_frame = gd_nframes(D);
	      df_np = gd_putdata(D,"RA", df_last_frame,0, 0,nsamples_perhalfscan, GD_FLOAT64,ra_rad);
	      df_np = gd_putdata(D,"DEC", df_last_frame,0, 0,nsamples_perhalfscan, GD_FLOAT64,dec_rad);
	      df_np = gd_putdata(D,"BETA", df_last_frame,0, 0,nsamples_perhalfscan, GD_FLOAT64,beta_rad);
	      df_np = gd_putdata(D,"AZ", df_last_frame,0, 0,nsamples_perhalfscan, GD_FLOAT64,boresightAZ);
	      df_np = gd_putdata(D,"EL", df_last_frame,0, 0,nsamples_perhalfscan, GD_FLOAT64,boresightEL);
	      df_np = gd_putdata(D,"ROLL", df_last_frame,0, 0,nsamples_perhalfscan, GD_FLOAT64,&rollPend_rad[time_index]);
	      df_np = gd_putdata(D,"RJD", df_last_frame,0, 0,nsamples_perhalfscan, GD_FLOAT64,&rjd[time_index]);
	      df_np = gd_putdata(D,"LST", df_last_frame,0, 0,nsamples_perhalfscan, GD_FLOAT32,&lst_hr[time_index]);
	      df_np = gd_putdata(D,"LON", df_last_frame,0, 0,nsamples_perhalfscan, GD_FLOAT64,&lon_deg[time_index]);
	      df_np = gd_putdata(D,"LAT", df_last_frame,0, 0,nsamples_perhalfscan, GD_FLOAT64,&lat_deg[time_index]);
	       

	      for(isn = 0; isn < nsamples_perhalfscan; isn++)
		{
		  /* MAIN LOOP */
		  az_fpc_out[    sample_num]    = boresightAZ[isn]; // already include az and el of pendulation
		  el_fpc_out[    sample_num]    = boresightEL[isn]; // idem
		  lst_out[       sample_num]    = lst_rad[time_index+isn]*RAD2DEG;
		  rjd_out[        sample_num]    = rjd[time_index+isn];
		  roll_pend_out[ sample_num]    = rollPend_rad[time_index+isn];
		  radecbeta_out[ sample_num*3]  = ra_rad[isn];
		  radecbeta_out[ sample_num*3+1] = dec_rad[isn];
		  radecbeta_out[ sample_num*3+2] = beta_rad[isn];
		  
		  if( (ra_rad[isn]*57.3) > np_ra_max)
		    np_ra_max = ra_rad[isn]*57.3;
		  if( (ra_rad[isn]*57.3) < np_ra_min)
		    np_ra_min = ra_rad[isn]*57.3;
		  if( (dec_rad[isn]*57.3) > np_dec_max)
		    np_dec_max = dec_rad[isn]*57.3;
		  if( (dec_rad[isn]*57.3) < np_dec_min)
		    np_dec_min = dec_rad[isn]*57.3;

		  sample_num++;
		  if (sample_num == nsn){
		    /*  dump az, el, lst, roll_pend and beta*/
			  
			  sprintf( fpc_out_file, "%s/az_fpc_%04d.bin", params.output_dir, ifile);
			  fp = fopen( fpc_out_file, "w");
			  fwrite( az_fpc_out, nsn, sizeof(float), fp);
			  fclose(fp);

			  sprintf( fpc_out_file, "%s/el_fpc_%04d.bin", params.output_dir, ifile);
			  fp = fopen( fpc_out_file, "w");
			  fwrite( el_fpc_out, nsn, sizeof(float), fp);
			  fclose(fp);

			  sprintf( fpc_out_file, "%s/lst_%04d.bin", params.output_dir, ifile);
			  fp = fopen( fpc_out_file, "w");
			  fwrite( lst_out, nsn, sizeof(float), fp);
			  fclose(fp);

			  sprintf( fpc_out_file, "%s/rjd_%04d.bin", params.output_dir, ifile);
			  fp = fopen( fpc_out_file, "w");
			  fwrite( rjd_out, nsn, sizeof(double), fp);
			  fclose(fp);

			  sprintf( fpc_out_file, "%s/roll_pend_%04d.bin", params.output_dir, ifile);
			  fp = fopen( fpc_out_file, "w");
			  fwrite( roll_pend_out, nsn, sizeof(float), fp);
			  fclose(fp);

			  sprintf( fpc_out_file, "%s/radecbeta_%04d.bin", params.output_dir, ifile);
			  fp = fopen( fpc_out_file, "w");
			  fwrite( radecbeta_out, 3*nsn, sizeof(double), fp);
			  fclose(fp);

			  sample_num = 0;
			  ifile = ifile + 1;
		  }
 		} 


		  /*		  for(k=0;k<nsamples_perhalfscan;k++)
				  {
				  fprintf(pointingfile,"%f %f %f %f %f \n",boresightAZ[k],boresightEL[k],
				  ra_rad[k],dec_rad[k],sample_times_sec[index+k]);
				  }*/

		  /* 		  boresightAZerr = (double *)calloc( nsamples_perhalfscan, sizeof( double)); */
		  /* 		  boresightELerr = (double *)calloc( nsamples_perhalfscan, sizeof( double));		   */
		  /* 		  get_reconstruction_errors( -1, nsamples_perhalfscan, */
		  /* 					     starSig2, gyroSig2, boresightAZerr, boresightELerr);		   */
		  /* 		  /\* get full reconstructed pointing with errors *\/ */
		  /* 		  for( idummy = 0; idummy < nsamples_perhalfscan; idummy++) */
		  /* 		    { */
		  /* 		      boresightAZerr[idummy] += boresightAZ[idummy]; */
		  /* 		      boresightELerr[idummy] += boresightEL[idummy]; */
		  /* 		    } */

//		  for(channel=0;channel<nchannel;channel++)
//		    {
//		      det_index = detectorindex[channel];
//		      ndet = ndetectors[channel];
//		      nsample = ndet*nsamples_perhalfscan;
//		      
//		      get_multi_det_pointing(ndet,&focalplaneAZ[det_index],&focalplaneEL[det_index],
//					     nsamples_perhalfscan,&boresightAZ[0], &boresightEL[0],&lst_rad[index],
//					     &rollPend_rad[0], latitude_rad, &ra_rad[0],&dec_rad[0],&beta_rad[0],&cosdec[0]);
//		      get_healpix_pixelnumbers_ring(&ra_rad[0],&dec_rad[0],nsample,nside,&ipix[0]);
//		      /*		      get_hwp_aTa_component_maps(&twophi_hwp_rad[index], nsamples_perhalfscan,
//			&beta_rad[0],ndet,&ipix[0],
//			&aTa11_hmap[channel*npix],&aTa12_hmap[channel*npix],
//			&aTa13_hmap[channel*npix],&aTa22_hmap[channel*npix],
//			&aTa23_hmap[channel*npix],&aTa33_hmap[channel*npix]);*/
//
//		      get_pixelnumbers(&ra_rad[0],&dec_rad[0],&cosdec[0],nsample,racosdec_min_rad,decmin_rad,ra_centre_rad,
//				       cellsize_rad,rasize,decsize,&pixel[0]);
//		      
//		      /*		      get_pixelnumbers_and_pixeldisplacements(&ra_rad[0],&dec_rad[0],
//			&cosdec[0],nsample,racosdec_min_rad,
//			decmin_rad,ra_centre_rad,
//			cellsize_rad,rasize,decsize,&pixel[0],
//			&dx_pix_rad[0],&dy_pix_rad[0]);*/
//		      
//		      /*		      get_multi_det_pointing(ndet,&focalplaneAZ[det_index],&focalplaneEL[det_index],
//			nsamples_perhalfscan,&boresightAZerr[0],
//			&boresightELerr[0],&lst_rad[index],
//			&rollPend_rad[0], latitude_rad,
//			&ra_recon_rad[0],&dec_recon_rad[0],&beta_recon_rad[0],&cosdec_recon[0]);*/
//
//		      get_hit_and_scancrossing_counts(&pixel[0],ndet,nsamples_perhalfscan,npixels,params.hitspersample,
//						      &scancrossingcount[channel*npixels], &binnedhitcount[channel*npixels]);
//		      
//		      /*		      get_pixelnumbers_and_pixeldisplacements(&ra_recon_rad[0],&dec_recon_rad[0],
//			&cosdec_recon[0],nsample,racosdec_min_rad,
//			decmin_rad,ra_centre_rad,
//			cellsize_rad,rasize,decsize,&pixel[0],
//			&dx_pix_rad[0],&dy_pix_rad[0]);*/
//		      
//		      /*		      binup_double(&dx_pix_rad[0],&pixel[0],nsample,&dx_map_rad[channel*npixels]);	      
//			binup_double(&dy_pix_rad[0],&pixel[0],nsample,&dy_map_rad[channel*npixels]);*/
//		      
//
//		      /*		      get_pointing_displacement_maps_squarepix(&ra_recon_rad[0],&dec_recon_rad[0],&cosdec_recon[0],
//			&ra_rad[0],&dec_rad[0],&cosdec[0],
//			&pixel[0],nsample,
//			&dx_map_rad[channel*npixels],&dy_map_rad[channel*npixels]);*/
//
//		      /*		      get_hwp_aTa_component_maps(&twophi_hwp_rad[index], nsamples_perhalfscan,
//			&beta_rad[0],ndet,&pixel[0],
//			&aTa11_map[channel*npixels],&aTa12_map[channel*npixels],
//			&aTa13_map[channel*npixels],&aTa22_map[channel*npixels],
//			&aTa23_map[channel*npixels],&aTa33_map[channel*npixels]);*/
//
//		    }/* end loop over channels */
		    //		  free(boresightAZerr); free(boresightELerr);
	    } /* end half scan (chop) */
	}/* end loop elevation step */
    } /* end scan repeats. */
  fclose(pointingfile);
  /* ***** END SCANNING ******* */
  free(ra_rad);  free(dec_rad);  free(cosdec); free(pixel);
  //  free(ra_recon_rad);  free(dec_recon_rad);  free(cosdec_recon);

  /*-----------------------------*/
  /*------- dirfile stuff -------*/
  /*-----------------------------*/

  printf("Dirfile in %s\n",df_directory); 
  df_last_frame=gd_nframes(D);
  printf("Number of frames in dirfile =  %i\n",df_last_frame);
  df_np=gd_spf(D,"RA");
  printf("Number of samples per frame =  %i\n",df_np);
  df_np=gd_nfragments(D);
  printf("Number of fragments =  %i\n",df_np);
  gd_close(D);
  
  /*Write Healpix map */
//  char coordsys='C';
//  char nest=0;
//  for(channel=0;channel<nchannel;channel++)
//    {
//      sprintf(file,"%s%i%s","aTa11_channel_",channel+1,".fits");
//      write_healpix_map(&aTa11_hmap[channel*npix], nside, file, nest, &coordsys);
//      sprintf(file,"%s%i%s","aTa12_channel_",channel+1,".fits");
//      write_healpix_map(&aTa12_hmap[channel*npix], nside, file, nest, &coordsys);
//      sprintf(file,"%s%i%s","aTa13_channel_",channel+1,".fits");
//      write_healpix_map(&aTa13_hmap[channel*npix], nside, file, nest, &coordsys);
//      sprintf(file,"%s%i%s","aTa22_channel_",channel+1,".fits");
//      write_healpix_map(&aTa22_hmap[channel*npix], nside, file, nest, &coordsys);
//      sprintf(file,"%s%i%s","aTa23_channel_",channel+1,".fits");
//      write_healpix_map(&aTa23_hmap[channel*npix], nside, file, nest, &coordsys);
//      sprintf(file,"%s%i%s","aTa33_channel_",channel+1,".fits");
//      write_healpix_map(&aTa33_hmap[channel*npix], nside, file, nest, &coordsys);
//    }
//
//
//  /*------------ Collect up hit maps and plot. ----------------*/
//  collect_countmaps(&binnedhitcount[0],npixels*nchannel);
//  //  collect_countmaps(&scancrossingcount[0],npixels*nchannel);
//  if(myRank == 0)
//    {
//      double area_squaredegrees,averagecount;
//      for(channel=0;channel<nchannel;channel++)
//	{
//	  printf("Channel = %i\n",channel+1);
//	  get_countmap_stats(&binnedhitcount[channel*npixels],npixels,params.cellsize_arcmin,
//			     &area_squaredegrees, &averagecount);
//	  //	  get_countmap_stats(&scancrossingcount[channel*npixels],npixels,params.cellsize_arcmin,
//	  //			     &area_squaredegrees, &averagecount);
//	  if(params.wantplots ) 
//	    {
//	      sprintf(file,"%s%i","hitcountmap_channel",channel+1);
//	      plotcountmap(&binnedhitcount[channel*npixels],rasize, decsize,
//			   racosdec_min_deg,params.decmin,
//			   ra_centre_deg,cellsize_deg,1.,gnuplotlogfile,
//			   params.outfileroot,file,params.displayplots);
//	      /*       sprintf(file,"%s%i","scancrossing_channel",channel+1); */
//	      /*       plotcountmap(&scancrossingcount[channel*npixels],rasize, decsize, */
//	      /* 		   racosdec_min_deg,params.decmin, */
//	      /* 		   ra_centre_deg,cellsize_deg,1.,gnuplotlogfile, */
//	      /* 		   params.outfileroot,file,params.displayplots); */
//	  
//	    }
//	}
//    }
//
//  /*-------------- Get the condition number map -------------*/
//  /*  get_conditionnumber_map(&aTa11_map[0], &aTa12_map[0], &aTa13_map[0],
//      &aTa22_map[0], &aTa23_map[0], &aTa33_map[0],
//      npixels*nchannel, &CN_map[0]);  
//      if(myRank == 0)
//      {
//      double average_CN,rms_CN, area_squaredegrees;
//      for(channel=0;channel<nchannel;channel++)
//      {
//      get_floatmap_stats(&CN_map[channel*npixels],&binnedhitcount[channel*npixels],
//      npixels,params.cellsize_arcmin, &area_squaredegrees,
//      &average_CN,&rms_CN);      
//      if(params.wantplots ) 
//      {
//      sprintf(file,"%s%i","condition_number_",channel+1);
//      plotmap(&CN_map[channel*npixels],rasize, decsize,
//      racosdec_min_deg,params.decmin,ra_centre_deg,
//      cellsize_deg,1.,gnuplotlogfile,
//      params.outfileroot,file,params.displayplots);
//      }
//      }
//      }
//  */
//
//  /*-------------- Get displacement length map -------------*/
//  collect_floatmaps(&dx_map_rad[0],npixels*nchannel);
//  collect_floatmaps(&dy_map_rad[0],npixels*nchannel);
//  
//  divide_floatmapbycountmap(&dx_map_rad[0],&binnedhitcount[0],npixels*nchannel);
//  divide_floatmapbycountmap(&dy_map_rad[0],&binnedhitcount[0],npixels*nchannel); 
//
//  float *dtheta_map_rad;
//  if(myRank == 0)
//    {
//      double averagedisplacement_rad,theta_disp_rms_rad,area_squaredegrees;
//      dtheta_map_rad = squarepixel_floatmap_init(npixels*nchannel);
//      for(channel=0;channel<nchannel;channel++)
//	{
//	  getlength_vectorfloatmap(&dx_map_rad[0],&dy_map_rad[0],
//				   npixels*nchannel,&dtheta_map_rad[0]);
//	  get_floatmap_stats(&dtheta_map_rad[0],&binnedhitcount[channel*npixels],
//			     npixels,params.cellsize_arcmin, &area_squaredegrees,
//			     &averagedisplacement_rad,&theta_disp_rms_rad);      
//	  printf("Average displacement and rms = %f , %f arcsec\n",
//		 averagedisplacement_rad*RAD2ARCSEC,theta_disp_rms_rad*RAD2ARCSEC);
//
//	  /*	  sprintf(file,"%s%i","dtheta_arcsec_channel",channel+1);
//	    plotmap(&dtheta_map_rad[channel*npixels],rasize, decsize,
//	    racosdec_min_deg,params.decmin,ra_centre_deg,
//	    cellsize_deg,RAD2ARCSEC,gnuplotlogfile,
//	    params.outfileroot,file,params.displayplots);*/
//	  /*       sprintf(file,"%s%i","deflectionangle_degree_channel",channel+1); */
//	  /*       plot_phasemap( &dx_map_rad[channel*npixels],&dy_map_rad[channel*npixels], */
//	  /* 		     rasize, decsize,racosdec_min_deg,params.decmin,ra_centre_deg, */
//	  /* 		     cellsize_deg,gnuplotlogfile,params.outfileroot,file,params.displayplots); */
//	}
//    }

  fclose(gnuplotlogfile);

  sprintf( fpc_out_file, "%s/hexsky_pointing_log.txt", params.output_dir);
  fp = fopen( fpc_out_file, "w");
  fprintf( fp, "timebetweensamples = %lf\n", params.timebetweensamples);
  fprintf( fp, "nsn = %li\n", nsn);
  fprintf( fp, "nfiles = %i\n", ifile);
  fprintf( fp, "ra_min = %lf\n", np_ra_min);
  fprintf( fp, "ra_max = %lf\n", np_ra_max);
  fprintf( fp, "dec_min = %lf\n", np_dec_min);
  fprintf( fp, "dec_max = %lf\n", np_dec_max);
  fprintf( fp, "azthrow = %lf\n", (float)azthrow_deg);
  fprintf( fp, "deltaDec = %lf\n", (float)deltaDec_deg);
  fprintf( fp, "turnaroundtime = %lf\n", turnaroundtime);
  fclose(fp);

  sprintf( fpc_out_file, "%s_hexsky_log.txt", params.outfileroot);
  fp = fopen( fpc_out_file, "w");
  fprintf( fp, "df_first_frame = %li\n", df_first_frame);
  fprintf( fp, "df_last_frame = %li\n", df_last_frame-1);
  fclose(fp);

  printf( "np_ra_min, np_ra_max   : %lf, %lf\n", np_ra_min, np_ra_max);
  printf( "np_dec_min, np_dec_max : %lf, %lf\n", np_dec_min, np_dec_max);

#if MPI
  MPI_Barrier(MPI_COMM_WORLD);
  MPI_Finalize();
#endif
  return(0);
}
