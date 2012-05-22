#include "utilities_parameters.h"

/* Public function definitions */

int scanfileforparami(FILE *f, char *str, int defaultvalue) {
  /*Purpose: read from an ascii file (already open) an integer parameter
    of the form

    name=value 
    
    where *str=name, and defaultvalue is the default value of the parameter
    to be used if value is not found.
  */
  int i; 
  int length;
  int found,foundstring;
  int test;
  int hopeful;
  int thislinelength,startingat,colonat,equalsat;
  char buffer[500],buffer2[500];


  /* this assumes that f is open. */
  
  /* first, rewind the file */
  
  rewind(f);
  
  /* how long is the string? */
  
  length = 0;
  length=strlen(str);    
  found = 0;
  foundstring = 0;


  while (feof(f) == 0) {
    /* read in a line from the file */
    fgets(buffer,254,f);
    thislinelength = strlen(buffer);
    startingat = 0;

    if (buffer[0] != '#'){
      /* check for the string in this line */		
      /* search for str in buffer, over the length. 
	 if found, set startingat */
      
      for (i=0; i<(thislinelength-length); i++) {
	test = strncmp(&buffer[i],str,length);
	if ((test == 0) & (startingat == 0)){ 
	  startingat = i;
	  foundstring=1;
	}
      }
      
      if (foundstring) {
	colonat = 0;
	equalsat = 0;
	/* the beginning string has been found. Now lets look for 
	   a semicolon. */
	for (i=startingat; i<thislinelength; i++) {
	  if ((buffer[i] == ';') & (colonat == 0)) 
	    colonat = i;
	  if ((buffer[i] == '#') & (colonat == 0)) 
	    colonat = i;
	  if ((buffer[i] == '=') & (equalsat == 0)) 
	    equalsat = i;
	}
	if (colonat == 0)
	  colonat = thislinelength;
	
	/* okay, so buffer[startingat] to buffer[i] contains the value */
	for (i=equalsat; i<colonat; i++) {
	  //	buffer2[i-(equalsat+1)] = buffer[i]; //PROBLEM HERE??
	  buffer2[i-(equalsat)] = buffer[i+1];
	}
	
	/* and run scanf to get the value */
	if (found == 0) {
	  sscanf(buffer2,"%i",&hopeful);
	  found = 1;
	}
      }
    }	
  }    
  if (found == 0) {
    printf("Failed to find parameter %s. Using default value %i\n",str,defaultvalue);
    return(defaultvalue);
  } else if (hopeful == defaultvalue){
    printf("FOUND (default) %s = %i\n",str,hopeful);
    return(hopeful);
  } else {
    printf("FOUND %s = %i\n",str,hopeful);
    return(hopeful);
  }
}


float scanfileforparamf(FILE *f, char *str, float defaultvalue) {
  /*Purpose: read from an ascii file (already open) an float parameter
    of the form

    name=value 
    
    where *str=name, and defaultvalue is the default value of the parameter
    to be used if value is not found.
  */
  int i; 
  int length;
  int found,foundstring;
  int test;
  float hopeful;
  int thislinelength,startingat,colonat,equalsat;
  char buffer[500],buffer2[500];

  /* this assumes that f is open. */
  
  /* first, rewind the file */
  
  rewind(f);
  
  /* how long is the string? */
  
  length = 0;
  length=strlen(str);

  
  found = 0;
  foundstring = 0;

  while (feof(f) == 0) {
    /* read in a line from the file */
    fgets(buffer,254,f);
    thislinelength = strlen(buffer);
    startingat = 0;

    if (buffer[0] != '#'){
      /* check for the string in this line */		
      /* search for str in buffer, over the length. 
	 if found, set startingat */
      for (i=0; i<(thislinelength-length); i++) {
	test = strncmp(&buffer[i],str,length);
	if ((test == 0) & (startingat == 0)) {
	  startingat = i;
	  foundstring=1;
	}
      }
      if (foundstring) {
	colonat = 0;
	equalsat = 0;
	/* the beginning string has been found. Now lets look for 
	   a semicolon. */
	for (i=startingat; i<thislinelength; i++) {
	  if ((buffer[i] == ';') & (colonat == 0)) 
	    colonat = i;
	  if ((buffer[i] == '#') & (colonat == 0)) 
	    colonat = i;
	  if ((buffer[i] == '=') & (equalsat == 0)) 
	    equalsat = i;
	}
	if (colonat == 0)
	  colonat = thislinelength;
	for (i=equalsat; i<colonat; i++) {
	  //	buffer2[i-(equalsat+1)] = buffer[i];
	  buffer2[i-(equalsat)] = buffer[i+1];
	}
	buffer2[colonat-(equalsat+1)] = 0; /* zero terminate this */
	
	if (found == 0) {
	  sscanf(buffer2,"%f",&hopeful);
	  found=1;
	}
      }
    }	
  }    
  if (found == 0)
    {
      printf("Failed to find parameter %s. Using default value %f\n",str,defaultvalue);
      return(defaultvalue);
    } else if (hopeful == defaultvalue){
      printf("FOUND (default) %s = %f\n",str,hopeful);
      return(hopeful);
    } else {
      printf("FOUND %s = %f\n",str,hopeful);
      return(hopeful);
    }
}

void scanfileforparamc(FILE *f, char *str, char *defaultvalue, char *string) {
  /*Purpose: read from an ascii file (already open) an string parameter
    of the form

    name=value
    
    where *str=name, and defaultvalue is the default value of the parameter
    to be used if value is not found.
  */
  int i;
  int length;
  int found,foundstring;
  int test;
  //  char hopeful[512];		    
  char hopeful[513]; /*Needs to be 513, not 512, else line below marked *** crashes
		       with gcc compiler.*/
  int thislinelength,startingat,colonat,equalsat;
  char buffer[512],buffer2[512];

  /* this assumes that f is open. */
  
  /* first, rewind the file */
  
  rewind(f);
  
  /* how long is the string? */
  
  length = 0;
  length=strlen(str);

  found = 0;
  foundstring = 0;

  while (feof(f) == 0) {
    /* read in a line from the file */
    fgets(buffer,254,f);
    thislinelength = strlen(buffer);
    startingat = 0;

    if (buffer[0] != '#'){
      /* check for the string in this line */
      /* search for str in buffer, over the length.
	 if found, set startingat */
      for (i=0; i<(thislinelength-length); i++) {
	test = strncmp(&buffer[i],str,length);
	if ((test == 0) & (startingat == 0)) {
	  startingat = i;
	  foundstring=1;
	}
      }
      if (foundstring) {
	colonat = 0;
	equalsat = 0;
	/* the beginning string has been found. Now lets look for
	   a semicolon. */
	for (i=startingat; i<thislinelength; i++) {
	  if ((buffer[i] == ';') & (colonat == 0))
	    colonat = i;
	  if ((buffer[i] == '#') & (colonat == 0))
	    colonat = i;
	  if ((buffer[i] == '=') & (equalsat == 0))
	    equalsat = i;
	}
	if (colonat == 0)
	  colonat = thislinelength;
	for (i=equalsat; i<colonat; i++) {
	  //	buffer2[i-(equalsat+1)] = buffer[i];
	  buffer2[i-(equalsat)] = buffer[i+1];
	}
	buffer2[colonat-(equalsat+1)] = 0; /* zero terminate this */
	
	if (found == 0) {
	  sscanf(buffer2,"%s",hopeful); /* *** */
	  found=1;
	}
      }
    }
  }
  if (found == 0)
    {
      printf("Failed to find parameter %s. Using default value %s\n",str,defaultvalue);
      sprintf(string,defaultvalue);
    } else if (hopeful == defaultvalue){
      printf("FOUND (default) %s = %s\n",str,hopeful);
      sprintf(string,hopeful);
    } else {
      printf("FOUND %s = %s\n",str,hopeful);
      sprintf(string,hopeful);
    }
}
