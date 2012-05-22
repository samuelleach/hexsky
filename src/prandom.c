/***********************************************************************/
/*                                                                     */
/* An implementation of a leapfrog generalized feedback shift register */
/* pseudo-random number generator due to Aluru, Prabhu & Gustafson     */
/* with period 2^P - 1 ~ 10^384                                        */
/*                                                                     */
/* (Parallel Computing 18, 839-847, 1992).                             */
/*                                                                     */
/* Julian's PRNG adopted to the noise simulation code - 12/14/2003 rs  */
/* Apdated with the presumably working routines       - 01/16/2005 rs  */
/***********************************************************************/

#include <math.h>
#include "prandom.h"

/*******************************************************/
/* parallel random number generator module from Julian */
/*******************************************************/

#define P1 607
#define P2 273
#define ISIZE 16

int PRNG_ARRAY[P1], PRNG_INDEX, PRNG_SEED;
float PRNG_RMAX;

void PRNG_initialize( int my_pe, int no_pe, int seed)

{
  int i, j, delay=10000, offset;
  int bit[2*P1];

  /* set up seed, bits and randoms */

  PRNG_SEED = seed;
  for (i=0; i<P1; i++) {
    PRNG_ARRAY[i] = 0;
    bit[i] = (i<PRNG_SEED) ? 0 : 1;
  }

  /* apply initial delay to scramble bits */

  for (j=0; j<delay; j++) for (i=0; i<P1; i++) bit[i] ^= bit[(i+P2)%P1];
  
  /* calculate bits my_pe, my_pe+n, ... my_pe+(P1-1)*n */

  for (j=0; j<no_pe; j++) {
    for (i=0; i<P1; i++) bit[i+P1] = bit[i]^bit[i+P2];
    offset = (my_pe>>j)%2;
    for (i=0; i<P1; i++) bit[i] = bit[2*i+offset];
  }

  /* calculate the initial array of randoms bit by bit */

  for (j=ISIZE-1; j>=0; j--) {
    for (i=0; i<P1; i++) {
      PRNG_ARRAY[i] += bit[i]<<j;
      bit[i] ^= bit[(i+P2)%P1];
    }
  }

  /* initialise other variables */

  PRNG_INDEX = P1-1;
  PRNG_RMAX = (float)(1<<ISIZE) - 1.0;

  return;
}

/* return a uniform random number from the interval [0.0, 1.0] */

float PRNG_uniform()

{
  PRNG_INDEX = (PRNG_INDEX+1)%P1;
  PRNG_ARRAY[PRNG_INDEX] ^= PRNG_ARRAY[(PRNG_INDEX+P2)%P1];

  return (float )PRNG_ARRAY[PRNG_INDEX]/PRNG_RMAX;
}

/* return a random number from the unit-variance gaussian */

int PRNG_gaussian( double *y)

{
  static double gset;
  double fac, rsq, v1, v2;

  do { 
    v1 = 2.0*PRNG_uniform() - 1.0; 
    v2 = 2.0*PRNG_uniform() - 1.0;
    rsq = v1*v1 + v2*v2;
  } while (rsq >= 1.0 || rsq == 0.0); 

  fac = sqrt(-2.0*log(rsq)/rsq);

  y[1]=v1*fac; 
  y[0]=v2*fac;

  return( 1);
}

int PRNG_gaussran( double *yvec, int nvec)

{
  double fac, rsq, v1, v2;
  float PRNG_uniform();
  int i;

  for( i=0; i< nvec/2; i++) {

    do { 
      v1 = 2.0*PRNG_uniform() - 1.0; 
      v2 = 2.0*PRNG_uniform() - 1.0;
      rsq = v1*v1 + v2*v2;
    } while (rsq >= 1.0 || rsq == 0.0); 
    fac = sqrt(-2.0*log(rsq)/rsq);

    yvec[ 2*i]=v1*fac;
    yvec[ 2*i+1]=v2*fac;
  } 

  if( nvec%2) {
    do {
      v1 = 2.0*PRNG_uniform() - 1.0; 
      v2 = 2.0*PRNG_uniform() - 1.0;
      rsq = v1*v1 + v2*v2;
    } while( rsq>=1.0 || rsq==0.0);
    fac=sqrt( -2.0*log(rsq)/rsq);

    yvec[nvec-1]=v1*fac;
  }

  /*return;*/
  return(0);
}


/* return a random unit n-vector */

void PRNG_unitv( int n, float *v)

{
  int i;
  float norm;

  do {
    for (i=0, norm=0.0; i<n; i++) {
      v[i] = 2.0*PRNG_uniform()-1.0;
      norm += v[i]*v[i];
    }
  } while ((norm=sqrt(norm)) > 1.0);
  for (i=0; i<n; i++) v[i] /= norm;

  /*  return;*/
}
