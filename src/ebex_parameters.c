#include "ebex_parameters.h"

/* Public function definitions */

void ebex_parameters_read(char *filename, EBEX_PARAMETERS *params){
  /* Purpose: Read hexsky parameters from an ascii file.*/

  FILE *fp;
  int i;

  fp = fopen(filename,"r");

/*   (*params).fpc_only = scanfileforparami(fp,"fpc_only",0); */

  (*params).ramin = scanfileforparamf(fp,"ramin",40.);
  (*params).ramax = scanfileforparamf(fp,"ramax",85);
  (*params).decmin = scanfileforparamf(fp,"decmin",-65.);
  (*params).decmax = scanfileforparamf(fp,"decmax",-40.);
  (*params).latitude_deg = scanfileforparamf(fp,"latitude_deg",-77.836);
  (*params).longitude_start_deg = scanfileforparamf(fp,"longitude_start_deg",-166.66);
  (*params).month = scanfileforparami(fp,"month",8);
  (*params).year = scanfileforparami(fp,"year",2006);

  (*params).orbitspeed = scanfileforparamf(fp,"orbitspeed",0.1);
  (*params).startdec_center = scanfileforparamf(fp,"startdec_center",-45);
  (*params).targetdecrange = scanfileforparamf(fp,"targetdecrange",8);
  (*params).cellsize_arcmin = scanfileforparamf(fp,"cellsize_arcmin",8);
  (*params).numberelestep = scanfileforparami(fp,"numberelestep",50);
  (*params).numberchop = scanfileforparami(fp,"numberchop",4);
  (*params).startscan = scanfileforparami(fp,"startscan",1);
  (*params).numberscan = scanfileforparami(fp,"numberscan",8);
  (*params).maxspeed_deg = scanfileforparamf(fp,"maxspeed_deg",1.8);
  (*params).maxaccel_rad = scanfileforparamf(fp,"maxaccel_rad",0.03);
  (*params).totalt = scanfileforparamf(fp,"totalt",51.4);
  (*params).starthour = scanfileforparamf(fp,"starthour",0);
  (*params).startday = scanfileforparami(fp,"startday",1);
  (*params).totaldays = scanfileforparami(fp,"totaldays",14);
  (*params).noofdetectors = scanfileforparami(fp,"noofdetectors",330);
  (*params).elestepmin_arcmin = scanfileforparamf(fp,"elestepmin_arcmin",-4.);
  (*params).elestepmax_arcmin = scanfileforparamf(fp,"elestepmax_arcmin",4.);
  (*params).noofelestepstotry = scanfileforparami(fp,"noofelestepstotry",9);
  (*params).elevationlimit = scanfileforparamf(fp,"elevationlimit",60);
  (*params).timebetweensamples = scanfileforparamf(fp,"timebetweensamples",0.1);
  (*params).gyro_noise = scanfileforparamf(fp,"gyro_noise",4.);
  (*params).starcamera_noise = scanfileforparamf(fp,"starcamera_noise",0.067);
  (*params).focalplane_phi0_deg = scanfileforparamf(fp,"focalplane_phi0_deg",0.0);
  (*params).twof_hwp_hz = scanfileforparamf(fp,"twof_hwp_hz",8.0);
  (*params).cmbdipolescan_startel = scanfileforparamf(fp,"cmbdipolescan_startel",30.);
  (*params).hitspersample = scanfileforparami(fp,"hitspersample",2);
  char daystring[255]; 
  for (i=0; i<(*params).startday+(*params).totaldays; i++)
    {
      sprintf(daystring,"startra_day_%i",i);
      (*params).startra_day[i] = scanfileforparamf(fp,daystring,58.5);
    }
  (*params).dofirstdaydeeper = scanfileforparami(fp,"dofirstdaydeeper",0);
  (*params).wantplots = scanfileforparami(fp,"wantplots",1);
  (*params).displayplots = scanfileforparami(fp,"displayplots",1);
  (*params).wantelependulation = scanfileforparami(fp,"wantelependulation",0);
  (*params).wantazipendulation = scanfileforparami(fp,"wantazipendulation",0);
  (*params).wantrollpendulation = scanfileforparami(fp,"wantrollpendulation",0);
  (*params).wantreconstructionerrors = scanfileforparami(fp,"wantreconstructionerrors",0);
  (*params).wantsinescanning = scanfileforparami(fp,"wantsinescanning",0);
  (*params).wanttrianglescanwithstop = scanfileforparami(fp,"wanttrianglescanwithstop",0);
  (*params).wantcoselmodulatedscanspeed = scanfileforparami(fp,"wantcoselmodulatedscanspeed",0);
  (*params).wantcalibratorscan = scanfileforparami(fp,"wantcalibratorscan",0);
  (*params).wantcmbdipolescan = scanfileforparami(fp,"wantcmbdipolescan",0);
  (*params).stopt = scanfileforparamf(fp,"stopt",2.);
  (*params).file_size = scanfileforparami(fp,"file_size",18);
  (*params).append_data_to_dirfile = scanfileforparami(fp,"append_data_to_dirfile",0);
  scanfileforparamc(fp,"outfileroot","pointing",(*params).outfileroot);
  scanfileforparamc(fp,"output_dir",".",(*params).output_dir);
  fclose(fp);
}


void ebex_parameters_writeinfo(char *fileroot, EBEX_PARAMETERS params){

  FILE *infofp;
  int i;
  float latitude_rad, cellsize_deg,maxspeed_rad,elevationlimit_rad;

  char filename[1024];
  sprintf(filename,"%s%s",fileroot,"_parameters.dat");
  infofp = fopen(filename,"w");

  latitude_rad = params.latitude_deg * DEG2RAD;
  cellsize_deg= params.cellsize_arcmin * ARCMIN2DEG; /* now in degrees */
  maxspeed_rad = params.maxspeed_deg * DEG2RAD;
  elevationlimit_rad = params.elevationlimit * DEG2RAD;

  fprintf(infofp,"Info file for the scan\n");
  fprintf(infofp,"Noof pixels : %i\n",params.noofdetectors);
  fprintf(infofp,"Number of chop repeats: %i\n",params.numberchop);
  fprintf(infofp,"Number of elevation steps to take: %i\n",params.numberelestep);
  fprintf(infofp,"Elevation steps are between %f and %f; %i tried\n",
	  params.elestepmin_arcmin,params.elestepmax_arcmin,params.noofelestepstotry);
  fprintf(infofp,"Target declination range %f\n",params.targetdecrange);
  fprintf(infofp,"Around a dec of %f\n",params.startdec_center);
  fprintf(infofp,"Max acceleration %f rad per sec per sec\n",params.maxaccel_rad);
  fprintf(infofp,"Max speed        %f rad per sec\n",maxspeed_rad);
  fprintf(infofp,"Total time for one scan %f sec\n",params.totalt);
  fprintf(infofp,"cellsize is %f by %f degrees\n",cellsize_deg,cellsize_deg);
  fprintf(infofp,"Latitude %f (rad)\n",latitude_rad);
  fprintf(infofp,"Starting longtitude %f (deg)\n",params.longitude_start_deg);
  fprintf(infofp,"Orbit speed %f (orbits per day)\n",params.orbitspeed);
  fprintf(infofp,"Total scan is %i days\n",params.totaldays);
  fprintf(infofp,"Elevation limit (degrees) %f\n",elevationlimit_rad*RAD2DEG);
  for (i=0; i<params.totaldays; i++) 
    fprintf(infofp,"Day %i, starting ra is %f\n",i,params.startra_day[i]);
  fprintf(infofp,"First day deeper (1=true) %i\n",params.dofirstdaydeeper);

  fclose(infofp);
}
