#include "utilities_gnuplot.h"

/*
  FILE *gnuplotlogfile;
  gnuplotlogfile = fopen(GNUPLOTSCRIPT,"w+"); 
*/
  
/* Public function definitions */

void gnuplot(char *gnucommand, FILE *gnuplotlogfile, int displayplot)
{
  char syscommand[1024];
  
  sprintf(syscommand, "echo \" %s \" | gnuplot -persist", gnucommand);
  fprintf(gnuplotlogfile,"\n\n%s\n",syscommand);
  if(displayplot)
    system(syscommand);
}


void gnuplot_plot(double y[], int n, double scaling, char *outfileroot, char *filename,int displayplot){

  char gnuplotcommands[1024];
  char file[2056],logfile[2056];
  FILE *datafile,*gnuplotlogfile;
  int i;

  sprintf(logfile,"%s_%s%s",outfileroot,filename,"_gnuplot.script");
  gnuplotlogfile = fopen(logfile,"w+"); /* Setup a log file for
					   gnuplot commands used */

  sprintf(file,"%s_%s.dat",outfileroot,filename);
  datafile = fopen(file,"w+"); /* overwrites old files */

  for (i=0; i<n; i++) {
    fprintf(datafile,"%i %f\n",i,y[i]*scaling);
  }
  fclose(datafile);
    
  /* Make plot of chopping function */
  //  sprintf(gnuplotcommands,"set xlabel \\\"Time (seconds)\\\"\n");
  //  sprintf(gnuplotcommands,"%s plot\\\"",gnuplotcommands);
  sprintf(gnuplotcommands,"plot\\\"");
  sprintf(gnuplotcommands,"%s%s",gnuplotcommands,file);
  sprintf(gnuplotcommands,"%s\\\"",gnuplotcommands);
  gnuplot(gnuplotcommands,gnuplotlogfile,displayplot);

  fclose(gnuplotlogfile);

}

void gnuplot_plot2d(double y[], double x[], int n, char *outfileroot,
		    char *filename, int displayplot){

  char gnuplotcommands[1024];
  char file[2056],logfile[2056];
  FILE *datafile,*gnuplotlogfile;
  int i;

  sprintf(logfile,"%s_%s%s",outfileroot,filename,"_gnuplot.script");
  gnuplotlogfile = fopen(logfile,"w+"); /* Setup a log file for
					   gnuplot commands used */

  sprintf(file,"%s_%s.dat",outfileroot,filename);
  datafile = fopen(file,"w+"); /* overwrites old files */

  for (i=0; i<n; i++) {
    fprintf(datafile,"%f  %f\n",x[i],y[i]);
  }
  fclose(datafile);
    
  /* Make plot  */
  sprintf(gnuplotcommands,"plot\\\"");
  sprintf(gnuplotcommands,"%s%s",gnuplotcommands,file);
  sprintf(gnuplotcommands,"%s\\\"",gnuplotcommands);

  //  gnuplot(gnuplotcommands,gnuplotlogfile);
  gnuplot(gnuplotcommands,gnuplotlogfile,displayplot);

  fclose(gnuplotlogfile);
}

void gnuplot_histogram(long int y[], double maxy, int n, char *outfileroot,
		       char *filename, int displayplot){

  char gnuplotcommands[1024];
  char file[2056],logfile[2056];
  FILE *datafile,*gnuplotlogfile;
  long int i,val;

  sprintf(logfile,"%s_%s%s",outfileroot,filename,"_gnuplot.script");
  gnuplotlogfile = fopen(logfile,"w+"); /* Setup a log file for
					   gnuplot commands used */

  sprintf(file,"%s_%s.dat",outfileroot,filename);
  datafile = fopen(file,"w+"); /* overwrites old files */

  for (i=0; i<n; i++)
    {
      val=*( y + i );
      fprintf(datafile,"%li \n",val);
    }
  fclose(datafile);
    
  /* Make plot  */
  sprintf(gnuplotcommands,"plot \\\"");
  sprintf(gnuplotcommands,"%s%s",gnuplotcommands,file);
  sprintf(gnuplotcommands,"%s\\\" with lines ",gnuplotcommands);

  gnuplot(gnuplotcommands,gnuplotlogfile,displayplot);

  fclose(gnuplotlogfile);
}
