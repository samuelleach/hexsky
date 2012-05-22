#include "ebex_focalplane.h"

/* Subroutines relating to the EBEX focal plane.
   Focalplane model based on the files from the EBEX wiki:
     
   Decagon_wafer_focal_plane_layout.pdf
   Detector_layout.pdf

   - Detector spacing 12' from Shaul Hanany (email to SML 24/08/06).
   
   - Detector spacing is (8 arcmin / 6.6mm ) * 6.63mm (email MM to CH 28/07/07)

   Further info:

   - Focalplane boresight is Wafer 7, row 8, detector 7.
   
   - For wafers 1--6, rows 11--14 and detectors 1--4 and 8--11 of row 10
     are outside the nominal 0.9 Strehl ratio radius.

   - From Shaul to SML and MZ (02/06/06):  
     
   "The number of 726 [for the 150GHz channel] is correct if we use a multiplexing factor
   of x12. If we use a multiplexing factor of 16 the number is 792 (the 'sensitivity'
   spec-sheet is a little outdated and says 796). Using a mux-ing factor of x12
   is more conservative because the technology for x16 has not yet been demonstrated."
  
   Right now the model here uses 2x396=*792* detectors for the 150GHz. 

   - From Hannes to SML (22/12/06):

   "In Clay's original design, there were 141 bolos, but we lost one due to the
   alignment marker [at row 7, detector 1] which brings the total per wafer to 140."


   - From Clay to SML (15/06/07)

   "Along with the detector taken out by the alignment mark (detector 7,1),
   I've also removed from my list the detector underneath the focal plane
   mounting screws (one in the center of each wafer: detector 8,7)."


*/

#define DETECTORSPACING 11.6*ARCMIN2RAD 
#define PLATESCALE      1.75    // arcmin per mm (averaged across the focalplane)
#define POINTNINESTREHLRADIUS 104.*PLATESCALE*ARCMIN2RAD 

#define X_OFFSET_V  0.0  // mm
#define Y_OFFSET_V  0.0  // mm

#define X_OFFSET_H  0.0  // mm
#define Y_OFFSET_H  0.0  // mm

#define COSPIBYTHREE 0.500000000
#define SINPIBYTHREE 0.866025403
#define COSPIBYSIX 0.866025403
#define SINPIBYSIX 0.500000000

/*Clay's original 141 element design */
#define NROW 14
#define NDETPERROW_DATA {6,9,10,11,12,13,12,13,12,11,10,9,8,5}
#define NBOLOSPERWAFER 141 /*Maximum number of bolometers per wafer.*/
#define NWAFERSPERFOCALPLANE 7 /* Number of wafers per focalplane.*/
#define NFOCALPLANES 1 /* Number of focalplanes.*/

#define NMISSINGDETECTORS 2      /* Number of detectors missing from all wafers */
#define MISSINGDETROW_DATA {7,8} /* i.e. Detector with row 7, number 1 is missing.*/
#define MISSINGDETNUM_DATA {1,7}

/* Public function definitions */

void setupfocalplane_boresight(double *focalplaneAZ, double *focalplaneEL)
{
  /* Trivial function to setup the focalplane boresight angle */
  
  *focalplaneAZ = 0.;
  *focalplaneEL = 0.;
}

double hwp_angle(double tf)
{
  /*Purpose: returns the half wave plate angle, where tf= time*freq_HWP */
  return(TWOPI*(tf-floor(tf)));
}

void setupfocalplane_decagon(double *focalplaneAZ, double *focalplaneEL)
{
  /* Purpose: Setup a single 141 element "decagon" wafer. */
  /* Detector azimuth and elevation returned in radians.*/

  int ndetperrow[NROW]= NDETPERROW_DATA;

  //  int missingdetrow[1]={7};/* i.e. Detector with row 7, number 1 is missing.*/
  //  int missingdetnum[1]={1};/* Must be arranged by row and then by number.*/ 
  //  int missingdetrow[NMISSINGDETECTORS]= MISSINGDETROW_DATA;
  //  int missingdetnum[NMISSINGDETECTORS]= MISSINGDETNUM_DATA;

  int i,j,det;//,missingdet;
  double dazi,dele;

  dele=DETECTORSPACING*SINPIBYTHREE;
  dazi=DETECTORSPACING;

  det=-1;
  //  missingdet=0;
  for(i=0;i<NROW;i++)
    {
      for(j=0;j<ndetperrow[i];j++)
	{
	  //	  if((i+1 == missingdetrow[missingdet]) & (j+1 == missingdetnum[missingdet])) 
	  //	    {
	  //	      missingdet +=1;
	  //	    }
	  //	  else
	  //	    {
	  det += 1;
	  focalplaneAZ[det] = dazi*(j-(ndetperrow[i]-1.)/2.);
	  focalplaneEL[det] = dele*(6.-i);
	      //	    }
	}
    }
}

void setupfocalplane_ebex(double *focalplaneAZ, double *focalplaneEL)
{
  /* Purpose: Setup the EBEX horizontal focal plane composed of 7x141 element
     wafers. */

  /* Based on EBEX collaboration file Focal_Plane/Decagon_wafer_focal_plane_layout.pdf*/

  /* Procedure: Setup wafer 7 at centre of focalplane by rotating a single wafer
     by 30 degrees.
     Perform translation to obtain wafer 4.
     Perform rotations to obtain wafers 1,2,3,5,6.*/

  /* Detector azimuth and elevation returned in radians.*/

  double wafer_azi[NBOLOSPERWAFER],wafer_ele[NBOLOSPERWAFER]; 
  int i,j,nrot=5;
  int wafer[6]={4,5,6,1,2,3};

  setupfocalplane_decagon(wafer_azi,wafer_ele);
  
  /*Rotate by 30 degree */
  for(i=0;i<NBOLOSPERWAFER;i++)
    {
      focalplaneAZ[(7-1)*NBOLOSPERWAFER+i]=  wafer_azi[i]*COSPIBYSIX+
	(wafer_ele[i]+DETECTORSPACING*SINPIBYTHREE)  *SINPIBYSIX;
      focalplaneEL[(7-1)*NBOLOSPERWAFER+i]= -wafer_azi[i]*SINPIBYSIX+
	(wafer_ele[i]+DETECTORSPACING*SINPIBYTHREE)*COSPIBYSIX;
    }

  /*Perform translation to get wafer 4 */
  for(i=0;i<NBOLOSPERWAFER;i++)
    {
      focalplaneAZ[(4-1)*NBOLOSPERWAFER+i]= focalplaneAZ[(7-1)*NBOLOSPERWAFER+i]
	- DETECTORSPACING*SINPIBYTHREE*13.*SINPIBYSIX*(1.+3./13.);
      focalplaneEL[(4-1)*NBOLOSPERWAFER+i]= focalplaneEL[(7-1)*NBOLOSPERWAFER+i]
	- DETECTORSPACING*SINPIBYTHREE*13.*COSPIBYSIX*(1.+3./13.);
    }
  

  /*Perform rotations to get wafers 5,6,1,2,3 */
  for(j=1;j<=nrot;j++)
    {
      for(i=0;i<NBOLOSPERWAFER;i++)
	{
	  focalplaneAZ[(wafer[j]-1)*NBOLOSPERWAFER+i]=
	    focalplaneAZ[(wafer[j-1]-1)*NBOLOSPERWAFER+i]*COSPIBYTHREE
	    +focalplaneEL[(wafer[j-1]-1)*NBOLOSPERWAFER+i]*SINPIBYTHREE;
	  focalplaneEL[(wafer[j]-1)*NBOLOSPERWAFER+i]=
	    -focalplaneAZ[(wafer[j-1]-1)*NBOLOSPERWAFER+i]*SINPIBYTHREE
	    +focalplaneEL[(wafer[j-1]-1)*NBOLOSPERWAFER+i]*COSPIBYTHREE;
	}
    }
  /* We're done */
}


int ebex_waferrownumber2index(int wafer, int row, int number)
{
  /*NEEDS FIXING now that we have "missing" pixels */

  /* Purpose: Converts EBEX detector Wafer/Row/Number convention to a detector index
     where the index convention is set by the subroutine setupfocalplane_ebex.
   */
  int index,i;
  int ndetperrow[NROW]= NDETPERROW_DATA;

  index=-1;
  for(i=0;i<row-1;i++) index+=ndetperrow[i];    
  return((wafer-1)*NBOLOSPERWAFER+index+number);
}

void setupfocalplane_ebexwafers(int wafers[], int nwafers,
				double *focalplaneAZ, double *focalplaneEL)
{
  /* Purpose: setup the EBEX focalplane, but composed of nwafers wafers, listed in
     the array wafers[]*/

  double ebexfocalplaneAZ[7*NBOLOSPERWAFER],ebexfocalplaneEL[7*NBOLOSPERWAFER];
  int wafer,n,first,index;

  setupfocalplane_ebex(ebexfocalplaneAZ,ebexfocalplaneEL);
      
  index=-1;
  for (wafer=0; wafer<nwafers; wafer++) 
    {
      first=ebex_waferrownumber2index(wafers[wafer],1,1);
      for (n=0; n<NBOLOSPERWAFER; n++) 
	{
	  index++;
	  focalplaneAZ[index]=ebexfocalplaneAZ[first+n];
	  focalplaneEL[index]=ebexfocalplaneEL[first+n];
	}
    }
}

void setupfocalplane_150ghz(double *focalplaneAZ, double *focalplaneEL)
{
  /* Purpose: Set up the detectors of the 150GHz channel,
     removing detectors outside the 0.9 Strehl radius. */ 

  int detector,ndetectors;
  int nwafers=4;
  int wafernumber[4]={2,3,5,6};
  double AZ[nwafers*NBOLOSPERWAFER],EL[nwafers*NBOLOSPERWAFER];
  double distance;
  setupfocalplane_ebexwafers(wafernumber,nwafers,AZ,EL);

  ndetectors=-1;
  for (detector=0; detector<nwafers*NBOLOSPERWAFER; detector++) 
    {
      distance = sqrt(AZ[detector]*AZ[detector]+EL[detector]*EL[detector]);
      if(distance < POINTNINESTREHLRADIUS)
	{
	  ndetectors++;
	  focalplaneAZ[ndetectors]=AZ[detector];
	  focalplaneEL[ndetectors]=EL[detector];
	}
    }
}

void setupfocalplane_250ghz(double *focalplaneAZ, double *focalplaneEL)
{
  
  /* Purpose: Set up the detectors of the 250GHz channel,
     removing detectors outside the 0.9 Strehl radius. */ 

  int detector,ndetectors;
  int nwafers=2;
  int wafernumber[2]={1,4};
  double AZ[nwafers*NBOLOSPERWAFER],EL[nwafers*NBOLOSPERWAFER];
  double distance;
  setupfocalplane_ebexwafers(wafernumber,nwafers,AZ,EL);

  ndetectors=-1;
  for (detector=0; detector<nwafers*NBOLOSPERWAFER; detector++)
    {
      distance = sqrt(AZ[detector]*AZ[detector]+EL[detector]*EL[detector]);
      if(distance < POINTNINESTREHLRADIUS)
	{
	  ndetectors++;
	  focalplaneAZ[ndetectors]=AZ[detector];
	  focalplaneEL[ndetectors]=EL[detector];
	}
    }
}

void setupfocalplane_410ghz(double *focalplaneAZ, double *focalplaneEL){

  /* Purpose: Set up the detectors of the 410GHz channel,
     removing detectors outside the 0.9 Strehl radius. */ 
  
  int detector,ndetectors;
  int nwafers=1;
  int wafernumber[1]={7};
  double AZ[nwafers*NBOLOSPERWAFER],EL[nwafers*NBOLOSPERWAFER];
  double distance;
  setupfocalplane_ebexwafers(wafernumber,nwafers,AZ,EL);

  ndetectors=-1;
  for (detector=0; detector<nwafers*NBOLOSPERWAFER; detector++)
    {
      distance = sqrt(AZ[detector]*AZ[detector]+EL[detector]*EL[detector]);
      if(distance < POINTNINESTREHLRADIUS)
	{
	  ndetectors++;
	  focalplaneAZ[ndetectors]=AZ[detector];
	  focalplaneEL[ndetectors]=EL[detector];
	}
    }
}

void setupfocalplane_horizontal(double *focalplaneAZ, double *focalplaneEL){

  /*Purpose: set up the three EBEX channels.*/
  
    setupfocalplane_150ghz(&focalplaneAZ[0],&focalplaneEL[0]);
    setupfocalplane_250ghz(&focalplaneAZ[392],&focalplaneEL[392]);
    setupfocalplane_410ghz(&focalplaneAZ[588],&focalplaneEL[588]);

}

void focalplane_cart2pol(double *focalplaneAZ, double *focalplaneEL,int ndetectors)
{
  /* Purpose: Convert Cartesian focalplane coordinates to Polar coordinates */ 
  
  int detector;
  double R,PHI;

  for (detector=0; detector<ndetectors; detector++)
    {
      R=sqrt(focalplaneAZ[detector]*focalplaneAZ[detector]+
	     focalplaneEL[detector]*focalplaneEL[detector]);
      PHI=atan2(focalplaneEL[detector],focalplaneAZ[detector]);
      focalplaneAZ[detector]=R;
      focalplaneEL[detector]=PHI;
    }
}


void focalplane_pol2cart(double focalplaneR[], double focalplanePHI[],int ndetectors)
{
  /* Purpose: Convert Polar focalplane coordinates to cartesian coordinates */ 
  
  int detector;
  double AZ,EL;

  for (detector=0; detector<ndetectors; detector++) 
    {
      AZ=focalplaneR[detector]*cos(focalplanePHI[detector]);
      EL=focalplaneR[detector]*sin(focalplanePHI[detector]);
      focalplaneR[detector]=AZ;
      focalplanePHI[detector]=EL;
    }
}

void rotate_focalplane(double *focalplaneAZ, double *focalplaneEL,int ndetectors,
		       double PHI0_deg)
     /* Purpose: Rotate the focalplane, described in Cartesian coordinates,
	by PHI0 in degrees. */ 
{
  long int detector;
  focalplane_cart2pol(&focalplaneAZ[0], &focalplaneEL[0],ndetectors);
  for (detector=0; detector<ndetectors; detector++)
    {
      focalplaneEL[detector] -= PHI0_deg*DEG2RAD;
    }
  focalplane_pol2cart(&focalplaneAZ[0], &focalplaneEL[0],ndetectors);
}


void shift_focalplane(double *focalplaneAZ, double *focalplaneEL,int ndetectors,
		       double X0_mm, double Y0_mm)
     /* Purpose: Shift the focalplane (radians), described in Cartesian coordinates,
	by XO mm (AZ) and YO mm (el) . */ 
{
  long int detector;
  for (detector=0; detector<ndetectors; detector++)
    {
      focalplaneAZ[detector] +=  X0_mm*PLATESCALE*ARCMIN2RAD ;
      focalplaneEL[detector] +=  Y0_mm*PLATESCALE*ARCMIN2RAD ;
    }
}


void write_focalplane_database(double PHI0_deg)
{
  char filename[1024]="ebex_fpdb.txt";
  //  char focalplane[2]="VH";
  long int channelname;
  int ndetperrow[NROW]= NDETPERROW_DATA;
  int missingdetrow[NMISSINGDETECTORS]= MISSINGDETROW_DATA;
  int missingdetnum[NMISSINGDETECTORS]= MISSINGDETNUM_DATA;
  float distancefromcentre;
  int wafernumber[7]={1,2,3,4,5,6,7};
  int ndet=NWAFERSPERFOCALPLANE*NBOLOSPERWAFER;
  double AZ[ndet],EL[ndet];
  //  int readoutchain=-1;
  
  FILE *fpdbfile;
  long int fplane,wafer,row,number,index,flag,i;

  fpdbfile = fopen(filename,"w+");

  /*Write out comments */

  fprintf(fpdbfile,"%s\n","# Approximation to a single EBEX focalplane, including locations of unpowered detectors");
  fprintf(fpdbfile,"%s\n","# Created by:");
  fprintf(fpdbfile,"%s\n","#  Sam (leach@sissa.it) 6 June 2007");
  //fprintf(fpdbfile,"%s\n","# ");
  fprintf(fpdbfile,"%s\n","# Modifications:");
  fprintf(fpdbfile,"%s\n","#   28 June 2007: Flag detectors (8,7) to zero (mounting screws)");
  fprintf(fpdbfile,"%s\n","#   23 August 2008: Detector spacing is 8 arcmin on sky");
  fprintf(fpdbfile,"%s\n","#   22 September 2008: Detector spacing is 11.6 arcmin");
  fprintf(fpdbfile,"%s\n","# ");
  fprintf(fpdbfile,"%s\n","# References:");
  fprintf(fpdbfile,"%s\n","#  Decagon_wafer_focal_plane_layout.pdf");
  fprintf(fpdbfile,"%s\n","#  Detector_layout.pdf");
  fprintf(fpdbfile,"%s\n","#  Email SH to SL (24/08/06) - detector spacing.");
  fprintf(fpdbfile,"%s\n","# ");
  fprintf(fpdbfile,"%s\n","# General information:");
  fprintf(fpdbfile,"%s\n","#  Boresight: wafer 7, row 8, number 7");
  fprintf(fpdbfile,"%s%f%s\n","#  Inter-detector spacing: ",DETECTORSPACING*RAD2ARCMIN," arcmin");
  fprintf(fpdbfile,"%s\n","# ");
  fprintf(fpdbfile,"%s\n","# ");
  fprintf(fpdbfile,"%s\n","# Col 1: Detector index (1--987)");
  fprintf(fpdbfile,"%s\n","# Col 2: Wafer number (1--7)");
  fprintf(fpdbfile,"%s\n","# Col 3: Row number (1--14)");
  fprintf(fpdbfile,"%s\n","# Col 4: Detector index within row (max value is 13, row dependent)");
  fprintf(fpdbfile,"%s\n","# Col 5: Detector azimith [radians]");
  fprintf(fpdbfile,"%s\n","# Col 6: Detector elevation [radians]");
  fprintf(fpdbfile,"%s\n","# Col 7: Channel name [150/250/410]");
  fprintf(fpdbfile,"%s\n","# Col 8: Flag if detector is powered or not [1/0]");
  fprintf(fpdbfile,"%s\n","# ");
  fprintf(fpdbfile,"%s\n","# ");
  fprintf(fpdbfile,"%s\n","# Detectors flagged as 0: Row 7 number 1 for all wafers (alignment marker).");
  fprintf(fpdbfile,"%s\n","#                         Row 8 number 7 for all wafers (mounting screw).");
  fprintf(fpdbfile,"%s%f%s\n","#                         All detectors outside 0.9 Strehl ratio radius of ",POINTNINESTREHLRADIUS*RAD2DEG," degrees from boresight.");
  fprintf(fpdbfile,"%s\n","# ");

  
  setupfocalplane_ebexwafers(wafernumber,NWAFERSPERFOCALPLANE,AZ,EL);
  rotate_focalplane(AZ,EL,ndet,PHI0_deg);
  shift_focalplane(&AZ[0],     &EL[0],     ndet,X_OFFSET_V,Y_OFFSET_V);

  long int detectorindex=0;
  for(fplane=1;fplane<=NFOCALPLANES;fplane++)
    {
      for(wafer=1;wafer<=NWAFERSPERFOCALPLANE;wafer++)
	{
	  for(row=1;row<=NROW;row++)
	    {
	      for(number=1;number<=ndetperrow[row-1];number++)
		{
		  flag=1;
		  detectorindex++;
		  index=ebex_waferrownumber2index(wafer,row,number);
		  

		  //Strehl radius cut of detectors.
		  distancefromcentre = sqrt(AZ[index]*AZ[index]+EL[index]*EL[index]);
		  if(distancefromcentre > POINTNINESTREHLRADIUS)
		    { 
		      flag=0;
		    }
		  
		  //Cut of detectors known to be missing.
		  for(i=0;i<NMISSINGDETECTORS;i++)
		    {
		      if((row == missingdetrow[i]) && (number == missingdetnum[i]))
			{
			  flag=0;
			}
		    }

		  if(wafer == 1 || wafer == 4) channelname=250;
		  if(wafer == 2 || wafer == 3 || wafer == 5 || wafer == 6)channelname=150; 
		  if(wafer == 7) channelname=410;


		  //		  fprintf(fpdbfile,"%4i %c %i %2i %2i %9+e %9+e %i %i\n",
		  //			  detectorindex,focalplane[fplane-1],wafer,row,number,AZ[index]*RAD2DEG,EL[index]*RAD2DEG,
		  //			  channelname, flag);
		  
		  
		  //		  		  fprintf(fpdbfile,"%4i %i %2i %2i %9f %9f %i %i\n",
		  //		  		  fprintf(fpdbfile,"%4i %i %2i %2i %+e %+e %i %i\n",
		  //			  detectorindex,wafer,row,number,AZ[index]*RAD2ARCMIN,EL[index]*RAD2ARCMIN,
		  //			  channelname, flag);

		  //		  fprintf(fpdbfile,"%4i %i %2i %2i %+e %+e %li %i\n",
		  fprintf(fpdbfile,"%4li %li %2li %2li %+e %+e %li %li\n",
			  detectorindex,wafer,row,number,AZ[index],EL[index],
			  channelname, flag);

		}
	    }
	}
    }

  

  fclose(fpdbfile);

}
