#ifndef _ebex_parameters_H
#define _ebex_parameters_H

#include <stdio.h>
#include "utilities_parameters.h"
#include "utilities_pointing.h"

typedef struct {
  float ramin, ramax, decmin, decmax, latitude_deg, longitude_start_deg, orbitspeed,
    startdec_center, targetdecrange,cellsize_arcmin,maxspeed_deg,
    maxaccel_rad,totalt, elestepmin_arcmin,elestepmax_arcmin,
    elevationlimit,timebetweensamples,starcamera_noise,gyro_noise,
    focalplane_phi0_deg,twof_hwp_hz,stopt,starthour,cmbdipolescan_startel;
  double startra_day[60];
    /* int fpc_only, month,year,numberelestep,numberchop,startscan,numberscan,startday,totaldays, */
  int month,year,numberelestep,numberchop,startscan,numberscan,startday,totaldays,
    noofdetectors,noofelestepstotry,dofirstdaydeeper,
    readlut,writelut,wantplots,displayplots,wantelependulation,wantrollpendulation,
    wantazipendulation,wantreconstructionerrors,wantsinescanning,
    wanttrianglescanwithstop,wantcoselmodulatedscanspeed,wantcalibratorscan,
    wantcmbdipolescan,hitspersample,file_size,append_data_to_dirfile;
  char outfileroot[512], output_dir[200];
} EBEX_PARAMETERS;

void ebex_parameters_read(char *filename, EBEX_PARAMETERS *params);
void ebex_parameters_writeinfo(char *filename, EBEX_PARAMETERS params);

#endif
