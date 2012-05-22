
#include "reconstructErrors.h"
#include "memory.h"
#include "malloc.h"
#include <math.h>

int invErrCorr( int opt, double starSigma2, double gyroSigma2, double **invCorr, int nband, int n)

/* 
   calculates non-zero elements of the inverse error correlation matrix for gyros plus star camera system
   matrix invErrCorr needs to be pre-allocated with the dimensions given by n and nband+1.

   - rs 30/09/2006
*/

{
	int i;
    
	if( (nband != 1) || (gyroSigma2 <= 0.0) || (starSigma2 <= 0.0) || (opt < -1)) return( 0);
	
    for( i = 1; i < n-1; i++)
	{
      /* diagonal */
	  invCorr[0][i] = 2.0/gyroSigma2;
	  /* off-diagonal */
	  invCorr[1][i] = -1.0/gyroSigma2;
	}

	if( opt == -1) 
	{                 /* two star case */
	  /* and the 1st and the last digonal */
  	  invCorr[0][0] = invCorr[0][n-1] = 1.0/starSigma2+1.0/gyroSigma2;
	  /* and offdiagonal */
	  invCorr[1][0] = -1.0/gyroSigma2;
	}
	else
	{                 /* one star at the position given by opt */
      /* fix first the diagonal */
	  invCorr[0][0] = invCorr[0][n-1] = 1.0/gyroSigma2;
	  invCorr[0][opt] = 1.0/starSigma2+1.0/gyroSigma2;
	  /* and now off-diagonal */
	  invCorr[1][0] = -1.0/gyroSigma2;
	}
	
	return( 1);
}

int halfTriDagSolv( double **a, double *rhs, double *x, int n)

{
	int j;
	double tmp, *vect;

	vect = (double *)calloc( n, sizeof( double));

    if( a[0][0] == 0.0) return( 0);
	
    x[0] = rhs[0]/a[0][0];

    for( j = 1; j < n; j++) {
	  if( a[0][j] == 0.0) return( 0);
      vect[j] = a[1][j-1]/a[0][j-1];		
      x[j] = rhs[j]/a[0][j];
    }	

    for( j = n-2; j >= 0; j--)
      x[j] -= vect[j+1]*x[j+1];
	
	free( vect);
	
	return( 1);
}

int trdgcholdc( double **a, int n, int nhalfBand)

   /* 
     does cholesky decomposition of a tridiagonal
     matrix in place 
	 a - is an upper triangle of a symmetric bandiagonal matrix stored as a series of vectors 
		 containing respective diagonals addresses of which (counted off the diagonal) 
	     are stored in **a;
     n - # of rows;
	 nhalfBand - a half band width (e.g., 1 for a tridiagonal matrix);

	 - rs 30/09/2006 Paris        
   */

{
	int i, j, k;
	double tmp;

    for( i = 0; i < n; i++) 
	{
      for( j = i; j <= min( i+nhalfBand, n-1); j++) 
	  {
	    tmp = a[j-i][i];
	    for( k = min( nhalfBand-(j-i), i); k >= 1; k--) 
	      tmp -= a[k][i-k]*a[j-i+k][i-k];
	
	      if( i == j) 
		  {
			if( tmp <= 0.0) return( 0);
			a[0][i] = sqrt( tmp);
	      }
		  else
		  {
			a[j-i][i] = tmp/a[0][i];
		  }
	  }
    }
	
	return( 1);
}

int get_reconstruction_errors( int opt, int n, double starSigma2, double gyroSigma2, double *errorsAZ, double *errorsEL)

{
   double **invCorr, *rhs;
   int i;
   int nband = 1;
   
   /* allocate workSpace */
   invCorr = (double** )malloc( (nband+1)*sizeof( double*));
   for( i = 0; i <= nband; i++)  invCorr[i] = (double *)calloc( n, sizeof( double));
   
   rhs = (double *)calloc( n, sizeof( double));
   
   invErrCorr( opt, starSigma2, gyroSigma2, invCorr, nband, n);

   if( !trdgcholdc( invCorr, n, nband)) return( 0);

   /* azimuth */
   PRNG_gaussran( rhs, n);
   if( !halfTriDagSolv( invCorr, rhs, errorsAZ, n)) return( 0);

   /* elevation */
   PRNG_gaussran( rhs, n);
   if( !halfTriDagSolv( invCorr, rhs, errorsEL, n)) return( 0);
   
   /* deallocate */
   for( i = 0; i <= nband; i++)  free( invCorr[i]);  free( invCorr);
   free( rhs);
   
   return( 1);
}

