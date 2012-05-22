#include "ebex_gondola.h"

/* Public function definitions */
void get_elePend_rad(double time[], long int nsamples, double *Pend_rad)
{
  /* Purpose: given a time (in seconds), this routine returns an elevation
     pendulation in arcminutes from "ideal" */ 

  /* period ; amplitude
     23 seconds  1'   maxipol
     2 min      1-3'  daytime
     6 min      3-4'  daytime
     6 min      5-9'  nighttime
     15 min     24'   maxima 
     All are assumed to be sinusodial, and start at t=0
  */

  /* I will use the following
     period amp
     23 sec 1'
     2min   3'
     6min   9'
     15min  24'
  */

  /* Note from SML: Should consider using  1' and 5' at 2 and 6 minutes to be consistent
   with the azimuthal pendulations. From table, p.16 of DaytimePointing.pdf*/

  /* period1 = TWOPI * time / 23.;
     period2 = TWOPI * time /(2.*60.);
     period3 = TWOPI * time /(6.*60.);
     period4 = TWOPI * time /(15.*60.);*/

  double period1,period2,period3,period4,value,tpt;//,arcmin2rad;
  long int sample;

  //  arcmin2rad = 2.90888e-4;
  for(sample=0 ; sample<nsamples; sample++)
    {       
      tpt = time[sample] * TWOPI;
      period1 = tpt*4.3478261e-2;
      period2 = tpt*8.3333333e-3;
      period3 = tpt*2.7777778e-3;
      period4 = tpt*1.1111111e-3;
      value = cos(period1) + 3.*cos(period2) + 9.*cos(period3) + 24.*cos(period4);
      Pend_rad[sample] = value * ARCMIN2RAD;  /* BUGGY ??!!*/
  }
}

void get_aziPend_rad(double time[], long int nsamples, double *aziPend_rad)
{
  /* Purpose: given a time (in seconds), this routine returns an azimuthal
     pendulation in arcminutes from "ideal" */ 

  /* I will use the following
     period amp
     2min   4'
     6min   6'
  */
  /* Taken from P.16 of DaytimePointing.pdf */

  double period1,period2,value,twopitime;//,arcmin2rad;
  long int sample;

  for(sample=0 ; sample<nsamples; sample++)
    {
      twopitime = TWOPI * time[sample];
      period1 = twopitime*8.3333333e-3;
      period2 = twopitime*2.7777778e-3;
      value = 4.e0*cos(period1) + 6.e0*cos(period2);
      aziPend_rad[sample] = value*ARCMIN2RAD;
    }
}


void get_rollPend_rad(double time[], long int nsamples, double *rollPend_rad)
{
/* Purpose: given a time (in seconds), this routine returns a roll
   pendulation in radians */ 

  /* I will use the following
     period amp
     2min   TW0PI * 0.002
     6min   TW0PI * 0.005
  */
  
  /* NB: THESE ROLL PENDULATION PARAMETERS ARE COMPLETELY ARBITRARY. */
  
  double period1,period2,twopitime;
  long int sample;
  
  for(sample=0 ; sample<nsamples; sample++)
    {
      twopitime = time[sample] * TWOPI;
      period1 = twopitime*8.333333333e-3;
      period2 = twopitime*2.777777778e-3;
      rollPend_rad[sample] =  TWOPI*0.002*cos(period1) + TWOPI*0.005*sin(period2);
    }
}

//double longitude_circumpolar(int elapseddays, double time, double orbitspeed,
//			     double start_longitude_deg) {
double longitude_circumpolar(double elapseddays, double orbitspeed,double start_longitude_deg) {
  double currentlong_deg;

  //  currentlong_deg = start_longitude_deg + 360. * orbitspeed * ((double)elapseddays + time * SEC2DAY);
  currentlong_deg = start_longitude_deg + 360. * orbitspeed * elapseddays;

  while (currentlong_deg > 180.) currentlong_deg -= 360.; 
  while (currentlong_deg < -180.) currentlong_deg += 360.; 

  return(currentlong_deg);
}    
