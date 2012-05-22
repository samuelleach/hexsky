FUNCTION READFIELDS, datadir, fields, FFRAME=fframe, NFRAME=nframe, $
                     NSKIP=nskip, FROMEND=fromend, FILTER=filter, $
                     FRAME=frame, TIME=time, QUIET=quiet, $
                     NSR=nsr, DTRT=dtrt, ERROR=error

;+
; Gaelen Marsden (gmarsden@physics.ubc.ca)
; 06 Dec 2004
;
; Read a series of kst data fields, listed in 'fields' array from
; directory 'datadir' into 2-D array 'data'. Data are calibrated
; according to format file. This function is a wrapper for READFIELD. 
;
; USAGE: data = READFIELDS(datadir, fields, FFRAME=fframe, $
;                   NFRAME=nframe, NSKIP=nskip, FROMEND=fromend, $
;                   FILTER=filter, FORMAT=format, FRAME=frame, TIME=time, $
;                   QUIET=quiet ,NSR=nsr, DTRT=dtrt, ERROR=error)
;
; INPUTS:
;   datadir: directory containing field data
;   fields:  1-D array (length NF) containing names of fields to
;            read. If NSKIP not specified, each requested field must
;            have same data rate. An error of -1 will otherwise be
;            returned. 
;
; OUTPUTS:
;   data:    2-D array (size NF x NPTS) containing requested data
;            streams. If an error occurs, the error code returned by
;            READFIELD is returned. Check the number of dimensions of
;            data to test for success (ie. (SIZE(data))[0] EQ 0).
; 
; KEYWORDS are as described in READFIELD.PRO, plus the following:
;   QUIET:   suppress noisy output to stdout
;   NSR:     number of samples read, as returned by READFIELD
;   DTRT:    data rate, as returned by READFIELD
;   ERROR:   error code returned by READFIELD
;
;-

loud = 1
IF KEYWORD_SET(quiet) THEN loud = 0

; determine size of first field
error = READFIELD(datadir, fields[0], nsr, dtrt, FFRAME=fframe, $
                  NFRAME=nframe, NSKIP=nskip, FROMEND=fromend, $
                  FILTER=filter, FRAME=frame, TIME=time, $
                  /NOREAD)

IF error NE 0 THEN RETURN, error

nf = N_ELEMENTS(fields)

;data = FLTARR(nf, nsr)
data = DBLARR(nf, nsr) ;Modification by EBEX team.

FOR f=0,nf-1 DO BEGIN

    error = READFIELD(datadir, fields[f], tnsr, tdtrt, tdata, $
                      FFRAME=fframe, NFRAME=nframe, NSKIP=nskip, $
                      FROMEND=fromend, FILTER=filter)

    IF error NE 0 THEN BEGIN
	IF loud THEN $
          PRINT, "Could not read field '", fields[f], "'."
        RETURN, error
    ENDIF

    IF tnsr NE nsr THEN BEGIN
	IF loud THEN $
          PRINT, "Field '", fields[f], "' not consistent with first field."
        RETURN, -1
    ENDIF

    IF loud THEN PRINT, "Read field '", fields[f], "'."
    data[f,*] = tdata

ENDFOR
                      
RETURN, data

END
