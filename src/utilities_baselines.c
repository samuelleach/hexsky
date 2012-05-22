#include "utilities_baselines.h"

/* Public function definitions */

void *multidetectorbaseline_double_init(long int ndetectors, long int nsamples){

  void *multidetectorbaseline;

  if (ndetectors == 0 || nsamples == 0) return NULL;
  multidetectorbaseline=calloc(ndetectors*nsamples, sizeof(double));

  if (multidetectorbaseline == NULL) {
    printf("Can't allocate memory for this %li by %li baseline of doubles.\n",
	   ndetectors,nsamples);
    exit(-1);
  }

  return multidetectorbaseline;
}

void *multidetectorbaseline_float_init(long int ndetectors, long int nsamples){

  void *multidetectorbaseline;

  if (ndetectors == 0 || nsamples == 0) return NULL;
  multidetectorbaseline=calloc(ndetectors*nsamples, sizeof(float));

  if (multidetectorbaseline == NULL) {
    printf("Can't allocate memory for this %li by %li baseline of floats.\n",
	   ndetectors,nsamples);
    exit(-1);
  }

  return multidetectorbaseline;
}

void *multidetectorbaseline_longint_init(long int ndetectors, long int nsamples){

  void *multidetectorbaseline;

  if (ndetectors == 0 || nsamples == 0) return NULL;
  multidetectorbaseline=calloc(ndetectors*nsamples, sizeof(long int));

  if (multidetectorbaseline == NULL) {
    printf("Can't allocate memory for this %li by %li baseline of long integers.\n",
	   ndetectors,nsamples);
    exit(-1);
  }
  return multidetectorbaseline;
}

void *baseline_double_init(long int nsamples){

  void *baseline;

  if (nsamples == 0) return NULL;
  baseline=calloc(nsamples, sizeof(double));

  if (baseline == NULL) {
    printf("Can't allocate memory for this %li baseline of doubles.\n",
	   nsamples);
    exit(-1);
  }
  return baseline;
}
void *baseline_float_init(long int nsamples){

  void *baseline;

  if (nsamples == 0) return NULL;
  baseline=calloc(nsamples, sizeof(float));

  if (baseline == NULL) {
    printf("Can't allocate memory for this %li baseline of floats.\n",
	   nsamples);
    exit(-1);
  }
  return baseline;
}
void *baseline_longint_init(long int nsamples){

  void *baseline;

  if (nsamples == 0) return NULL;
  baseline=calloc(nsamples, sizeof(long int));

  if (baseline == NULL) {
    printf("Can't allocate memory for this %li baseline of long integers.\n",
	   nsamples);
    exit(-1);
  }
  return baseline;
}
