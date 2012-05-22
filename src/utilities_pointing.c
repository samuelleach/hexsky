#include "utilities_pointing.h"

/* General astronomy related routines */

/* Check out Xephem for some inspiration: */
/* http://www.clearskyinstitute.com/xephem/xephem-3.7.1.tar.gz */
/* In particular the codes mjd.c, misc.c, aa_hadec.c, plmoon.c */


/* Public function definitions */

void azel_2_hadec(double az[], double el[], int n, double cosL, double sinL,
		  double *ha, double *dec, double *cosdec) 
{
  /*Purpose: convert Az, El in radians to HA, Dec in radians and cos(Dec)*/

  double sindec, cosha, sinel,coselcosL;
  int ii;

  for (ii=0; ii<=n-1; ii++) range_fast(&az[ii],TWOPI);

  for (ii=0;ii<=n-1;ii++){ 
    sinel = sin(el[ii]);
    coselcosL= cos(el[ii])*cosL;

    sindec = sinel*sinL + coselcosL*cos(az[ii]);
    dec[ii] = asin(sindec);
    cosdec[ii] = cos(dec[ii]);
    cosha = (sinel - sinL*sindec) / (cosL*cosdec[ii]);

    //    printf("cosha = %f\n",cosha);


    if(cosha > 1.0) cosha=1.0;
    if(cosha < -1.0) cosha= -1.0;

    ha[ii] = acos(cosha);
    if (az[ii] < PI) ha[ii] = TWOPI - ha[ii];

    //    printf("sindec = %f , ha = %f , dec = %f \n",sindec,ha[ii],dec[ii]*RAD2DEG);

    
  }
}

void azel_2_hadecbeta(double az[], double el[], int n, double cosL, double sinL,
		      double *ha, double *dec, double *beta, double *cosdec) 
{
  /*Purpose: convert Az, El in radians to HA, Dec, and orientation beta in radians
    and cos(Dec)*/

  /* ORIENTATION BETA NEEDS TESTING*/

  double sindec, cosha, sinel, cosel;
  double cosA, sinA,A;
  int ii;

  for (ii=0;ii<=n-1;ii++) range_fast(&az[ii],TWOPI);

  for (ii=0;ii<=n-1;ii++){ 
    sinel = sin(el[ii]);
    cosel = cos(el[ii]);

    sindec = sinel*sinL + cosel*cosL*cos(az[ii]);
    dec[ii] = asin(sindec);
    cosdec[ii] = cos(dec[ii]);
    cosha = (sinel - sinL*sindec) / (cosL*cosdec[ii]);

    cosA= (sinL-sindec*sinel)/(cosdec[ii]*cosel);
    sinA= sin(az[ii])*cosL/cosdec[ii];
    A=atan2(sinA,cosA);
    beta[ii]=PI-A;

    if(cosha > 1.0) cosha=1.0;
    if(cosha < -1.0) cosha= -1.0;

    ha[ii] = acos(cosha);
    if (az[ii] < PI) ha[ii] = TWOPI - ha[ii];
  }
}

void azel_2_hadec_multidetector(double az, double el, double daz[], double cosdel[],
				double sindel[],long int n, double cosL, double sinL,
				double *ha, double *dec, double *cosdec) 
{
  /*Purpose: convert Az, El in radians to HA, Dec in radians and cos(Dec).
    cosL is cos(Latitude).*/

  /*Multidetector version: az,el are the boresight pointing; daz, sindel, cosdel
    are precomputed, where daz and del are the positions of
    the detectors on the focal plane.*/

  double sindec, cosha, sinel,cosel,cosaz,sinaz;
  int ii;
  double sinazbore,cosazbore,sinelbore,coselbore,cosdazovercosel,sindazovercosel;

  sinazbore=sin(az);
  cosazbore=cos(az);
  sinelbore=sin(el);
  coselbore=cos(el);

  for (ii=0; ii<n; ii++)
    { 
      cosel = coselbore*cosdel[ii]-sinelbore*sindel[ii];
      sinel = sinelbore*cosdel[ii]+coselbore*sindel[ii];
      cosdazovercosel=cos(daz[ii]/cosel);
      sindazovercosel=sin(daz[ii]/cosel);
      sinaz = sinazbore*cosdazovercosel+cosazbore*sindazovercosel;
      cosaz = cosazbore*cosdazovercosel-sinazbore*sindazovercosel;
      
      sindec = sinel*sinL + cosel*cosL*cosaz;
      dec[ii] = asin(sindec);
      cosdec[ii] = cos(dec[ii]);
      cosha = (sinel - sinL*sindec) / (cosL*cosdec[ii]);
      
      if(cosha > 1.0) cosha=1.0;
      if(cosha < -1.0) cosha= -1.0;
      
      ha[ii] = acos(cosha);
      if (sinaz > 0.) ha[ii] = TWOPI - ha[ii];
    }
}

void azel_2_hadec_multidetector_new(double az, double el, double cosdaz[], double sindaz[],
				    double cosdel[], double sindel[], long int n,
				    double cosL, double sinL,
				    double *ha, double *dec, double *cosdec) 
{
  /*Purpose: convert Az, El in radians to HA, Dec in radians and cos(Dec).
    cosL is cos(Latitude).*/

  /*Multidetector version: az,el are the boresight pointing; daz, sindel, cosdel
    are precomputed, where daz and del are the positions of
    the detectors on the focal plane.*/

  double sindec, cosha, sinel,cosel,cosaz,sinaz;
  int ii;
  double sinazbore,cosazbore,sinelbore,coselbore;//,cosdazovercosel,sindazovercosel;

  sinazbore=sin(az);
  cosazbore=cos(az);
  sinelbore=sin(el);
  coselbore=cos(el);

  for (ii=0; ii<n; ii++)
    { 
      sinel = sinelbore*cosdel[ii]*cosdaz[ii] + coselbore*sindel[ii];
      cosel = sqrt(1.-sinel*sinel);

      cosaz = coselbore*cosazbore*cosdaz[ii]*cosdel[ii] -
	sinazbore*cosdel[ii]*sindaz[ii] -
	cosazbore*sinelbore*sindel[ii];
      cosaz = cosaz/cosel;

      sinaz = coselbore*sinazbore*cosdaz[ii]*cosdel[ii] +
	cosazbore*cosdel[ii]*sindaz[ii] -
	sinazbore*sinelbore*sindel[ii];
      sinaz = sinaz/cosel;
      
      sindec = sinel*sinL + cosel*cosL*cosaz;
      dec[ii] = asin(sindec);
      cosdec[ii] = cos(dec[ii]);
      cosha = (sinel - sinL*sindec) / (cosL*cosdec[ii]);
      
      if(cosha > 1.0) cosha=1.0;
      if(cosha < -1.0) cosha= -1.0;
      
      ha[ii] = acos(cosha);
      if (sinaz > 0.) ha[ii] = TWOPI - ha[ii];
    }
}

int hadec_2_azel(double HA[],double Dec[],int n,double L,double *az, double *el)
{
  /*Purpose: convert HA, Dec in radians to  Az, El in radians */

  double sina,cosaz,cosL,sinL;
  int ii;
  
  cosL=cos(L); sinL=sin(L);


  for (ii=0;ii<=n-1;ii++){ 
    sina = sin(Dec[ii]) * sinL + cos(Dec[ii]) * cosL * cos(HA[ii]);
    el[ii] = asin(sina);
    
    cosaz = (sin(Dec[ii]) - sinL * sin(el[ii])) / (cosL*cos(el[ii]));
    
    if (sin(HA[ii]) > 0) {
      az[ii] = TWOPI - acos(cosaz);
    } else {
      az[ii] = acos(cosaz);
    }
  }
  return (0);
}

void rael_2_az(double RA, double el, double lst, double cosL, double sinL,
	       double *az) 
     /*Purpose: Given a target RA and current elevation in radians, LST in hours,
       work out the two possible azimuth solutions in radians.

       LST = GST + long/15. */
{     
     int ii;
     double ha,cc,bb,aa,sinel,cosha,delta;
     double *sin_dec,*cos_dec,*azimuth;
     sin_dec=(double *)(calloc(2,sizeof(double)));   
     cos_dec=(double *)(calloc(2,sizeof(double)));   
     azimuth=(double *)(calloc(2,sizeof(double)));   

     ha = lst*HR2RAD - RA;     
     sinel=sin(el);
     cosha=cos(ha);

     cc = sinel*sinel-cosha*cosha*cosL*cosL;
     bb = -2.*sinel*sinL;
     aa = sinL*sinL + cosha*cosha*cosL*cosL;
     delta = bb*bb - 4.*aa*cc;

     if (delta < 0.0) delta = 0.;
     
     sin_dec[0] = (-bb - sqrt(delta))/(2.*aa) ;
     sin_dec[1] = (-bb + sqrt(delta))/(2.*aa) ; 

     for (ii=0;ii<2;ii++)
       {
	 if (sin_dec[ii] <= 1.) cos_dec[ii] = sqrt(1.-sin_dec[ii]*sin_dec[ii]);
       }

     for (ii=0;ii<2;ii++)
       {
	 azimuth[ii] = PI + atan2(cos_dec[ii]*sin(ha),(-sin_dec[ii]*cosL+cos_dec[ii]*cosha*sinL));
	 range_fast(&azimuth[ii],TWOPI);
       }
     az[0]=azimuth[0];
     az[1]=azimuth[1];

     free(sin_dec); free(cos_dec);free(azimuth);
}

void determinelst(CIVILTIME ct[], double longitude[],int n, double *LST){
  /*Purpose: convert civil time to local sidereal time in hours*/

  /* Determine the LST given a bunch of parameters. Follows
     the algorithms given in Duffet Smith's book "Practical 
     astronomy with your calculator".
     Returns LST in hours. 
  */ 

   /*
    longitude is measured in degrees east of Greenwich.
    */ 
    
  /* 
     This is code IS NOT GENERAL.
     It does not take account of years1 < 1582 
     DO NOT USE THIS FOR GENERAL WORK 
  */

  double *jd;/* the Julian Day */
  jd = (double *)(calloc(n,sizeof(double)));
  double *j;

  j= &jd[0];
  jdcnv(ct,n,j);

  int ii;
  double T0, T;
  double GST; /* Greenwich Sideral Time */

  for (ii=0; ii<n; ii++){ 
    /* determine the GST from UT (where UT in seconds is actually secs) */

    T = (j[ii] - 2451545.)*2.737850787e-5;  /*jd2000 = 2451545*/
    T0 = 6.697374558 + (2400.051336 * T) + ( 0.000025862*T*T);
    range_fast(&T0,24.);
    
    GST = T0 + 1.002737909 * ct[ii].secs * SEC2HR; /* UT = secs[ii] / 3600. */
    range_fast(&GST,24.);
    
    LST[ii] = GST + longitude[ii] * DEG2HR;     
    range_fast(&LST[ii],24.);/*Wrap 0 < LST <= 2pi */

  }
  free(jd);
}

void determinelst_new(CIVILTIME ct[], double longitude[],int n, double *LST){
  /*Purpose: convert civil time to local sidereal time in hours*/

   /*
    longitude is measured in degrees east of Greenwich.
    */ 

  double *jd;/* the Julian Day */
  double *j;
  int ii;
  double t0,t,theta;

  jd = (double *)(calloc(n,sizeof(double)));
  j= &jd[0];
  jdcnv_new(ct,n,j);

  for (ii=0;ii < n;ii++)
    { 
      t0 = jd[ii] - 2451545.0;
      t = t0/36525;
      theta = 280.46061837+ (360.98564736629 * t0) + t*t*(0.000387933 - t/38710000.0 );
      LST[ii] = ( theta + longitude[ii])/15.0;
      range_fast(&LST[ii],24.);/*Wrap 0 < LST <= 24 */
    }
  free(jd);
}

void jdcnv(CIVILTIME ct[], int n, double *jd){
  /* Purpose : Convert day, month , year to Julian day */
  /* Notice that we are not scaling the number of seconds into day here.*/

  int ii;
  double A, B, C, bigD;

  for (ii=0;ii<n;ii++){ 
    if (ct[ii].month < 3)
      {
	ct[ii].year--;
	ct[ii].month += 12;
      }
    A = trunc(ct[ii].year*0.01);
    B = 2. - A + trunc(A*0.25);
    C = trunc(365.25 * ct[ii].year);
    bigD = trunc(30.6001 * (ct[ii].month + 1.));
    jd[ii] = B + C + bigD + ct[ii].day + 1720994.5;
  }
}

void jdcnv_new(CIVILTIME ct[], int n, double *jd){
  /* Purpose : Convert day, month , year to Julian day */
  /* Notice that we are not scaling the number of seconds into day here.*/

  /* Adapted from IDL astrolib jdcnv.pro*/

  int ii,L;
  
  for (ii=0; ii<n; ii++)
    { 
      L = floor(ct[ii].month-14)/12;// In leap years, -1 for Jan, Feb, else 0;
      jd[ii] = ct[ii].day - 32075 + 1461*(ct[ii].year+4800+L)/4 + 
	367*(ct[ii].month - 2-L*12)/12 - 3*((ct[ii].year+4900+L)/100)/4;
      jd[ii] = (double)jd[ii] + (ct[ii].secs/24.0/3600) - 0.5;      
    }
}

void get_rjd(CIVILTIME ct, double sample_times_sec[],long int numbersamples,double *rjd)
/* Purpose: wrapper routine to convert the civil time to a reduced julian day. */
  /* jd = rjd + 2.45000e6    a la WMAP*/
  /* jd = rjd + 2.45490e6    a la EBEX ?*/
  
{
  long int sample;
  double jd0;

  jdcnv(&ct, 1, &jd0);
  jd0=jd0-RJD0;
  for (sample=0; sample<numbersamples; sample++)
    {
      rjd[sample]=jd0+sample_times_sec[sample]*SEC2DAY;
    }
}

void range (double *v, double r){
  /* Purpose: returns  0 <= *v < r.  */
  *v -= r*floor(*v/r);
}

void ha2ra(double ha[], double lst[], long int n, double *ra)
{
  /*Purpose: given HA and lst, both in radians, converts to RA, in radians. */
  long int sample;

  for(sample = 0 ; sample < n ; sample++)
    {
      ra[sample] = lst[sample] - ha[sample];
      range_fast(&ra[sample],TWOPI);
    }
}

void range_fast(double *v, double r)
{
  /* Purpose: returns  0 <= *v < r */
  while(*v > r) *v -= r;
  while(*v < 0) *v += r;
}
