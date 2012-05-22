##################################################################
### readfields.pro ###############################################
##################################################################

READFIELDS is a wrapper function for READFIELD (see below). 
Provides array of fields, returns 2-D array containing time stream
of each field. If error occurs, returns code as scalar. If dimensions 
of fields incompatible, returns error -1. Otherwise, passes READFIELD 
error (see RFERROR function).

   e.g. Read fields RA, DEC, and TIME:

        IDL> fields = ['RA', 'DEC', 'TIME']
        IDL> data = READFIELDS('data_dir', fields, NFRAME=1000, $
			       FRAME=frame)
        IDL> help, data
        DATA            FLOAT     = Array[3, 1000]

   e.g. Read fields with incompatible data rates:

        IDL> data = READFIELDS('data_dir', ['N9C15', 'TIME'], $
                               NFRAME=1000, FRAME=frame)
        Field 'TIME' not consistent with first field.
        IDL> help, data
        DATA            INT       =       -1


##################################################################
### readfield.pro ################################################
##################################################################

"readfield.pro" is an IDL utility for reading BLAST data. It reads one
field at a time, in a similar manner to how one reads data in KST.

Much of this is documented inside the file itself, but I'm writing
this as a "quickstart" guide.

USAGE:

error = READFIELD(dirfile, field, nsr, dtrt, data, $
                  FFRAME=ff, NFRAME=nf, NSKIP=ns, $
		  FILTER=filter, NOREAD=noread, $
		  TIME=time, FRAME=frame, FORMAT=format)

Arguments:

	dirfile [INPUT]:  location of data directory
        field   [INPUT]:  name of data field to be read
        nsr     [OUTPUT]: number of samples in output array (data)
	dtrt    [OUTPUT]: data rate (sampling) in Hz of output array
	data	[OUTPUT]: double array of length nsr containing data

Keywords (optional):
	FFRAME: specify frame to start reading from
	NFRAME: specify number of frames to read
	NSKIP:  specify number of frames to skip, ie. NSKIP=2 -> for a
	          slow frame, read every second sample; for a fast
		  frame, every 40th sample
	FILTER: when set and NSKIP > 1, boxcar filter skipped samples
	NOREAD: don't read the data (used to determine size of field)
	TIME:   set variable to array of time, in seconds since beginning
		  of file, for each data point
	FRAME:  set variable to array of frame points, in frames since
		  beginning of file
        FORMAT: declare an alternate format file (default is "format" in 
		  dirfile) specify absolute path, relative to current 
		  directory, or relative to dirfile

Return value:

       error code - a non-zero error indicates failure of some
       type. Run "RFERROR, error" for description. 

See also READFIELDS for a wrapper function to read many fields in one call.

EXAMPLES:

A) To read "T_ISC" from "/data/rawdir/1064755850.b":

   IDL> data = '/data/rawdir/1064755850.b'
   IDL> error = READFIELD(data, 'T_ISC', nsr, dtrt, t_isc)
   IDL> print, error
	  0
   IDL> print, nsr
         504326
   IDL> print, dtrt
         5.00000
   IDL> help, t_isc
   T_ISC           DOUBLE    = Array[504326]

B) To read last 1000 frames of 'N15C16':

   IDL> error = READFIELD(data, 'N5C16', nsr, dtrt, n15c16, NFRAME=1000):
   IDL> print, nsr
          20000
   IDL> print, dtrt
         100.000
   IDL> help, n15c16
   N15C16          DOUBLE    = Array[20000]

C) To read 'DGPS_LON', 1 sample every second, from 4000th frame to end:

   IDL> error = READFIELD(data, 'DGPS_LON', nsr, dtrt, lon, $
                          FFRAME=4000, NSKIP=5)
   IDL> print, nsr
         100065
   IDL> print, dtrt
         1.00000
   IDL> help, lon
   LON             DOUBLE    = Array[100065]

D) To read 'T_REAC' averaged over every minute and plot against hours
   since beginning of data file:

   IDL> error = READFIELD(data, 'T_REAC', nsr, dtrt, t_reac, $
                          NSKIP=300, /FILTER, TIME=time)
   IDL> PLOT, time/3600., t_reac

E) Use TIME keyword: 

   Set variable to array containing seconds since beginning of file
   for each data point.

   eg. Read T_ISC at every minute between frames 1001 - 61001:

       IDL> data = '/data/rawdir/1064755850.b'
       IDL> error = READFIELD(data, 'T_ISC', nsr, dtrt, t_isc, $
			      NSKIP=300, FFRAME=1001, NFRAME=5000, TIME=time)
       IDL> PRINT, error
              0
       IDL> PRINT, nsr
                16
       IDL> PRINT, dtrt
           0.0166667
       IDL> PRINT, time
              200.00000       260.00000       320.00000       380.00000
              440.00000       500.00000       560.00000       620.00000
              680.00000       740.00000       800.00000       860.00000
              920.00000       980.00000       1040.0000       1100.0000


##################################################################
### rferror.pro ##################################################
##################################################################

Get description of error code.

eg. Ask for non-existent data field:

    IDL> error = READFIELD(data, 'BANANA', nsr, dtrt, banana)
    IDL> PRINT, error
         -20
    IDL> RFERROR, error
    READFIELD ERROR -20: FIELD not found in format file



NOTES:

Please send comments/complaints/suggestions to gmarsden@physics.ubc.ca.


Modification History:



Version 0.03 - G. Marsden, 14 JAN 05
		  - add FRAME keyword

Version 0.02 - G. Marsden, 20 NOV 03
		  - fix to 'NOREAD' keyword
		  - check error from READ_TEXT_DATA (for LINTERP cal type)
		  - added TIME keyword
		  - extracted STR_SPL_WS into separate file
		  - added READ_TEXT_DATA program (missing in earlier releases)
		  - catch error when NFRAME < NSKIP
		  - added RFERROR utility -- provides error description
                  - added FORMAT keyword
                  - test for existence of dirfile separately from format file

Version 0.01 - E. Chapin (echapin@inaoep.mx), Nov 2003, minor addition of 
               signed 16bit ('s'), and 32bit ('S') data types.

