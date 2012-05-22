#include "conditionNumber.h"
#include <gsl/gsl_linalg.h>

#define MAX_CONDITION_NUMBER 2.3

void get_hwp_aTa_matrix_elements(double two_phi[],long int nsample,
				 double beta[],long int ndet,
				 float *aTa11, float *aTa12, float *aTa13,
				 float *aTa22, float *aTa23, float *aTa33)
     /*
       
     
     */     
{
  long int sample, det, index;
  double two_alpha,cos2alpha,sin2alpha;

  index=-1;
  for (sample=0;sample<nsample;sample++)
    {
      for (det=0;det<ndet;det++)
	{
	  index++;
	  two_alpha=2.*(beta[index]+two_phi[sample]);
	  cos2alpha=cos(two_alpha);
	  sin2alpha=sin(two_alpha);
	  
	  aTa11[index]=1.;
	  aTa12[index]=cos2alpha;
	  aTa13[index]=sin2alpha;
	  aTa22[index]=cos2alpha*cos2alpha;
	  aTa23[index]=cos2alpha*sin2alpha;
	  aTa33[index]=sin2alpha*sin2alpha;
	}
    }
}

void get_hwp_angle(double t[], double twof_hwp_hz, long int n, double *twophi_hwp)
{
  /*Purpose: returns twice the half wave plate angle, 2f_hwp x t  */
  long int i;
  double twoft;
  for (i=0;i<n;i++)
    {
      twoft=twof_hwp_hz*t[i];
      twophi_hwp[i]=TWOPI*(twoft-floor(twoft));
    }
}

void get_hwp_angle2(CIVILTIME ct, double t[], double twof_hwp_hz, long int n, double *twophi_hwp)
{
  /*Purpose: returns twice the half wave plate angle, 2f_hwp x t  */
  long int i;
  double twoft;
  for (i=0;i<n;i++)
    {
      twoft=  twof_hwp_hz*(t[i]+86400.*ct.day);
      twophi_hwp[i]=TWOPI*(twoft-floor(twoft));
    }
}


void get_hwp_aTa_component_maps(double twophi_hwp_rad[], long int nsample,
				double beta_rad[], long int ndet, long int pixel[],
				float *aTa11_map,float *aTa12_map,float *aTa13_map,
				float *aTa22_map,float *aTa23_map,float *aTa33_map)
{
  /*Purpose: evaluate the aTa matrix components and bin them into square pixel maps.*/

  float *aTa11,*aTa12,*aTa13,*aTa22,*aTa23,*aTa33;

  aTa11 = multidetectorbaseline_float_init(ndet,nsample);
  aTa12 = multidetectorbaseline_float_init(ndet,nsample);
  aTa13 = multidetectorbaseline_float_init(ndet,nsample);
  aTa22 = multidetectorbaseline_float_init(ndet,nsample);
  aTa23 = multidetectorbaseline_float_init(ndet,nsample);
  aTa33 = multidetectorbaseline_float_init(ndet,nsample);
   
  get_hwp_aTa_matrix_elements(&twophi_hwp_rad[0],nsample,&beta_rad[0], ndet,
			      &aTa11[0], &aTa12[0], &aTa13[0],&aTa22[0],
			      &aTa23[0], &aTa33[0]);
  
  binup_float(&aTa11[0],&pixel[0],nsample*ndet,&aTa11_map[0]);
  binup_float(&aTa12[0],&pixel[0],nsample*ndet,&aTa12_map[0]);
  binup_float(&aTa13[0],&pixel[0],nsample*ndet,&aTa13_map[0]);
  binup_float(&aTa22[0],&pixel[0],nsample*ndet,&aTa22_map[0]);
  binup_float(&aTa23[0],&pixel[0],nsample*ndet,&aTa23_map[0]);
  binup_float(&aTa33[0],&pixel[0],nsample*ndet,&aTa33_map[0]);

  free(aTa11);  free(aTa12);  free(aTa13);
  free(aTa22);  free(aTa23);  free(aTa33);
}


void get_conditionnumber_map(float aTa11_map[], float aTa12_map[], float aTa13_map[],
			     float aTa22_map[], float aTa23_map[], float aTa33_map[],
			     long int npixels, float *CN_map)
{

  long int pixel;
  int status,i;
  double min_s,max_s,temp,cond;

  /*---------- Collect up aTa maps. -------------*/
  collect_floatmaps(&aTa11_map[0],npixels);
  collect_floatmaps(&aTa12_map[0],npixels);
  collect_floatmaps(&aTa13_map[0],npixels);
  collect_floatmaps(&aTa22_map[0],npixels);
  collect_floatmaps(&aTa23_map[0],npixels);
  collect_floatmaps(&aTa33_map[0],npixels);

  gsl_matrix * A = gsl_matrix_alloc(3,3);
  gsl_matrix * V = gsl_matrix_alloc(3,3);
  gsl_vector * S = gsl_vector_alloc(3);
  gsl_vector * work = gsl_vector_alloc(3);

  for (pixel = 0; pixel < npixels; pixel++)
    {
      gsl_matrix_set(A, 0, 0, aTa11_map[pixel]);
      gsl_matrix_set(A, 0, 1, aTa12_map[pixel]);
      gsl_matrix_set(A, 0, 2, aTa13_map[pixel]);
      gsl_matrix_set(A, 1, 1, aTa22_map[pixel]);
      gsl_matrix_set(A, 1, 2, aTa23_map[pixel]);
      gsl_matrix_set(A, 2, 2, aTa33_map[pixel]);
      gsl_matrix_set(A, 1, 0, aTa12_map[pixel]);
      gsl_matrix_set(A, 2, 0, aTa13_map[pixel]);
      gsl_matrix_set(A, 2, 1, aTa23_map[pixel]);
      
      status=gsl_linalg_SV_decomp ( A, V, S, work);

      if(status == 1)
	{
	  cond=0.;
	}
      else
	{
	  min_s=1e10;
	  max_s=-1e10;
	  for (i = 0; i< 3; i++)
	    {
	      temp= gsl_vector_get (S, i);
	      if (temp > max_s) max_s=temp;
	      if (temp < min_s) min_s=temp;
	    }
	  cond=max_s/min_s;
	  if (cond > MAX_CONDITION_NUMBER) cond = MAX_CONDITION_NUMBER;
	} 
      CN_map[pixel] = cond;
    }
}
