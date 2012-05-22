;+
; Gaelen Marsden (gmarsden@physics.ubc.ca)
; 08 Nov 2003
;
; Read a kst data field from directory 'dirfile' into 'data'
; data are calibrated according to format file
;
; USAGE: error = READFIELD(dirfile, field, nsr, dtrt, data, nfifu, $
;                    FFRAME=fframe, NFRAME=nframe, NSKIP=nskip, $
;                    FROMEND=fromend, SETNFIF=setnfif, FILTER=filter, $
;                    NOREAD=noread, TIME=time, FRAME=frame)
;
; Calls READFIELD_ITER to search format files and read raw data from
; file. 
;
; INPUTS:
;   dirfile: directory (eg. *.x) containing fields
;   field:   field to be read
;   nfifu:   if SETNFIF set, set nfif (# frames in file) to nfifu
;            (u -> used) this is to deal with data being written to 
;            file while reading out several fields -- essentially 
;            ignore last nfif-nfifu frames
;
; OUTPUTS:
;   data:    if NOREAD not set, set to double array containing data read 
;            from field
;   nsr:     number of samples read
;   dtrt:    data rate (Hz)
;   nfifu:   set to number of frames used
;            = nfif if SETNFIF set
;
; KEYWORDS:
;   FFRAME:  first frame to be read
;            if not set, fframe=0
;   NFRAME:  number of frames to be read
;            if NFRAME > # samples in file, return all
;            if not set, return all
;   NSKIP:   read first point of every NSKIPth frame
;            if not set or NSKIP=0, return every sample
;   FROMEND: if set, reads NFRAMEs from end
;   SETNFIF: see INPUTS
;   FILTER:  if NSKIP set, boxcar-average skipped data
;   NOREAD:  if not set, don't read data
;   TIME:    set variable to array containing decimal seconds, since
;            beginning of file, for each data point. useful for comparing
;            multiple fields
;   FRAME:   set variable to array containing frame number (similar to TIME)
;   
;
; ERROR LIST: See "rferror.pro", or run "RFERROR, error"
;
;
; DEPENDENCIES:
; 
;   str_spl_ws.pro
;   read_text_data.pro
;
;
; VERSION CONTROL and Bug Fix/Feature Log
;
;   V0.05: 6 JAN 09, S. Leach (leach@sissa.it)
;   
;          - add GetData types: UINT8, UINT16, INT16, UINT32,
;            INT32, FLOAT32, FLOAT, FLOAT64, DOUBLE.
;          - TO BE IMPLEMENTED: CONST, PHASE, STRING field types.
;            See (http://getdata.sourceforge.net/dirfile.html).
;
;   V0.04: 10 JUL 07, G. Marsden (gmarsden@phas.ubc.ca)
;   
;          - change to disk read line: now read chunk of correct
;            length from disk instead of all the way to the end of
;            file. 
;
;   V0.03: 19 DEC 05, G. Marsden (gmarsden@phas.ubc.ca)
;
;          - support INCLUDE format tag
;          - added MULTIPLY data type
;          - added BIT data type
;          - add FRAME keyword
;          - created GET_FORMAT_LINE function
;          - removed FORMAT keyword
;
;   V0.02: 20 NOV 03, G. Marsden (gmarsden@physics.ubc.ca)
;
;          - fix to 'NOREAD' keyword
;          - check error from READ_TEXT_DATA (for LINTERP cal type)
;          - added TIME keyword
;          - extracted STR_SPL_WS into separate file
;          - catch error when NFRAME < NSKIP
;          - added FORMAT keyword
;          - test for existence of dirfile separately from format file
;
;   V0.01: 19 NOV 03, E. Chapin (echapin@inaoep.mx)
;
;          - addition of signed 16bit ('s'), and 32bit ('S') native 
;            data types
;
;   V0.00: 08 NOV 03, G. Marsden (gmarsden@physics.ubc.ca)
;
;-

;--------------------------------------------------------------- 

FUNCTION GET_FORMAT_LINE, formatlun, field, tokens, dirfile, $
                          formatlist, SUBDIR=subdir

; Find field in format file
; Sets variable `tokens' to string array containing parsed data
; Returns 1 if field found, 0 otherwise

flist = formatlist
IF SIZE(flist, /N_DIM) EQ 0 THEN flist = [flist]

; reset file pointer
POINT_LUN, formatlun, 0                

line = ''
err = -20

; step through file line by line
WHILE err NE 0 DO BEGIN

    ; exit loop if end of file found
    IF EOF(formatlun) THEN BREAK

    READF, formatlun, line
    sarr = STR_SPL_WS(line)     ; string array
    
    ; test for comment character
    IF STRMID(sarr[0], 0, 1) EQ '#' THEN CONTINUE
    
    IF sarr[0] EQ field THEN BEGIN
        err = 0
        tokens = sarr
        subdir = dirfile
    ENDIF

    IF sarr[0] EQ "INCLUDE" THEN BEGIN
        subfile = sarr[1]
        IF ( WHERE(subfile EQ flist) NE -1 ) THEN RETURN, -13

        OPENR, subflun, dirfile + '/' + subfile, /GET_LUN, ERROR=ferr
        IF ferr NE 0 THEN RETURN, -12
        
        ; split off directory
        p = RSTRPOS(subfile, '/')

        dfile = dirfile
        IF p NE -1 THEN dfile = dfile + STRMID(subfile, 0, p+1) 

        ; add format file to list
        flist = [flist, subfile]

        ; search INCLUDEd format file
        
        err = GET_FORMAT_LINE(subflun, field, tokens, dfile, flist, SUBDIR=subdir)
        
        FREE_LUN, subflun
    ENDIF

ENDWHILE

RETURN, err

END

;--------------------------------------------------------------- 

FUNCTION READFIELD_ITER, formatlun, dirfile, formatfile, field, nsr, dtrt, data, $
                         nfifu, FFRAME=fframe, NFRAME=nframe, NSKIP=nskip, $
                         FROMEND=fromend, SETNFIF=setnfif, FILTER=filter, $
                         NOREAD=noread, TIME=time, FRAME=frame, GETSRATE=getsrate

; Called by READFIELD
; Recursively searches 'format' file for field until type 'RAW' is found

; find field in format file
; tokens is array containing string words on line
dfile = dirfile
err = GET_FORMAT_LINE(formatlun, field, tokens, dirfile, $
                      formatfile, SUBDIR=subdir)

; Error if field not found
IF err NE 0 THEN RETURN, err

; search on TYPE of data field
; RAW is terminating case -> read data from file
CASE tokens[1] OF

    'LINCOM': BEGIN
        ; linear combination of other data fields
        IF KEYWORD_SET(getsrate) THEN $ ; find sample rate of first field in list
          RETURN, READFIELD_ITER(formatlun, dirfile, formatfile, tokens[3], nsr, /GETSRATE)
        nlc = FIX(tokens[2])
        FOR i=1,nlc DO BEGIN
            basef  = tokens[i*3]
            slope  = DOUBLE(tokens[i*3+1])
            offset = DOUBLE(tokens[i*3+2])
            err = READFIELD_ITER(formatlun, dirfile, formatfile, basef, nsr, dtrt, $
                                 datat, nfifu, FFRAME=fframe, NFRAME=nframe, $
                                 NSKIP=nskip, FROMEND=fromend, $
                                 SETNFIF=setnfif, FILTER=filter, $
                                 NOREAD=noread, TIME=time, FRAME=frame)
            IF err NE 0 THEN RETURN, err
            IF KEYWORD_SET(noread) THEN RETURN, 0 ; statement added to V0.02
            datat  =  slope * TEMPORARY(datat) + offset  
            IF i EQ 1 THEN data = datat ELSE data = TEMPORARY(data) + datat
                                ; statement added to V0.02
        ENDFOR
    END

    'LINTERP': BEGIN
        ; interpolate a calibration file
        IF KEYWORD_SET(getsrate) THEN $ ; find sample rate 
          RETURN, READFIELD_ITER(formatlun, dirfile, formatfile, tokens[2], nsr, /GETSRATE)
        interpfile = tokens[3]
        err = READFIELD_ITER(formatlun, dirfile, formatfile, tokens[2], nsr, dtrt, $
                             data, nfifu, FFRAME=fframe, NFRAME=nframe, $
                             NSKIP=nskip, FROMEND=fromend, $
                             SETNFIF=setnfif, FILTER=filter, $
                             NOREAD=noread, TIME=time, FRAME=frame)
        IF err NE 0 THEN RETURN, err
        interpdata = READ_TEXT_DATA(interpfile, ERROR=err)
        IF err NE 0 THEN RETURN, -31              ; statement added to V0.02
        IF KEYWORD_SET(noread) THEN RETURN, 0 ; statement added to V0.03
        data = INTERPOL(interpdata[1,*], interpdata[0,*], TEMPORARY(data))
    END

    'BIT': BEGIN
        ; bit fields
        ; added to V0.03
        IF KEYWORD_SET(getsrate) THEN $ ; find sample rate 
          RETURN, READFIELD_ITER(formatlun, dirfile, formatfile, tokens[2], nsr, /GETSRATE)
        pos = FIX(tokens[3])
        len = 1                 ; 2nd parameter default
        IF N_ELEMENTS(tokens) GT 4 THEN len = FIX(tokens[4])
        err = READFIELD_ITER(formatlun, dirfile, formatfile, tokens[2], nsr, dtrt, $
                             data, nfifu, FFRAME=fframe, NFRAME=nframe, $
                             NSKIP=nskip, FROMEND=fromend, $
                             SETNFIF=setnfif, FILTER=filter, $
                             NOREAD=noread, TIME=time, FRAME=frame)
        IF err NE 0 THEN RETURN, err
        IF KEYWORD_SET(noread) THEN RETURN, 0 ; statement added to V0.03
        data = ISHFT(TEMPORARY(data), -pos) AND (ISHFT(1, len) - 1)
    END

    'MULTIPLY': BEGIN
        ; multiply two fields (added to V0.03)
        IF KEYWORD_SET(getsrate) THEN $ ; find sample rate 
          RETURN, READFIELD_ITER(formatlun, dirfile, formatfile, tokens[2], nsr, /GETSRATE)

        ; read first field
        err = READFIELD_ITER(formatlun, dirfile, formatfile, tokens[2], srate1, /GETSRATE)
        IF err NE 0 THEN RETURN, err
        err = READFIELD_ITER(formatlun, dirfile, formatfile, tokens[2], nsr1, dtrt1, $
                             data1, nfifu, FFRAME=fframe, NFRAME=nframe, $
                             NSKIP=nskip, FROMEND=fromend, $
                             SETNFIF=setnfif, FILTER=filter, $
                             NOREAD=noread, TIME=time, FRAME=frame)
        IF err NE 0 THEN RETURN, err

        ; read second field
        err = READFIELD_ITER(formatlun, dirfile, formatfile, tokens[3], srate2, /GETSRATE)
        IF err NE 0 THEN RETURN, err
        nf2 = CEIL(nsr1 * srate2 * dtrt1)
        err = READFIELD_ITER(formatlun, dirfile, formatfile, tokens[3], nsr2, dtrt2, $
                             data2, nfifu, FFRAME=fframe, NFRAME=nf2, $
                             NSKIP=nskip, FROMEND=fromend, $
                             SETNFIF=setnfif, FILTER=filter, NOREAD=noread)
        IF err NE 0 THEN RETURN, err

        IF KEYWORD_SET(noread) THEN RETURN, 0 ; statement added to V0.03

        nsr  = (nsr2 * srate1 < nsr1 * srate2) / srate2
        dtrt = dtrt1
        ind1 = LINDGEN(nsr)
        ind2 = ind1 * srate2 / srate1
        data = data1[ind1] * data2[ind2]
        time = time[ind1]
        frame = frame[ind1]
    END

    'RAW': BEGIN
        ; read data from disk

        ; set data type
        CASE tokens[2] OF
            'u': BEGIN          ; 16 bit unsigned integer
                bps   = 2       ; bytes per sample
                dtype = 0U      ; data type
            END
            'U': BEGIN          ; 32 bit unsigned integer
                bps   = 4
                dtype = 0UL
            END
            's': BEGIN          ; 16 bit signed integer
                bps   = 2       ; statement added to V0.01
                dtype = 0
            END
            'S': BEGIN          ; 32 bit signed integer
                bps   = 4       ; statement added to V0.01
                dtype = 0L
            END
            'c': BEGIN          ; 8 bit char
                bps   = 1       ; statement added to V0.03
                dtype = 0B
            END
            'd': BEGIN
                bps   = 8       ; 64 bit double
                dtype = 0D      ; statement added to V0.03
            END
            'UINT8': BEGIN
                bps   = 1       ; 8 bit unsigned integer
                dtype = 0B      ; statement added to V0.05
            END
            'UINT16': BEGIN
                bps   = 2       ; 16 bit unsigned integer
                dtype = 0U      ; statement added to V0.05
            END
            'INT16': BEGIN
                bps   = 2       ; 16 bit unsigned integer
                dtype = 0       ; statement added to V0.05
            END
            'UINT32': BEGIN
                bps   = 4       ; 32 bit unsigned integer
                dtype = 0UL     ; statement added to V0.05
            END
            'INT32': BEGIN
                bps   = 4       ; 32 bit signed integer
                dtype = 0L      ; statement added to V0.05
            END
            'INT64': BEGIN
                bps   = 8       ; 64 bit signed integer
                dtype = 0L      ; ????Check this SL
            END
            'FLOAT32': BEGIN
                bps   = 4       ; 32 bit float
                dtype = 0E      ; statement added to V0.05
            END
            'FLOAT': BEGIN
                bps   = 4       ; 32 bit float
                dtype = 0E      ; statement added to V0.05
            END
            'FLOAT64': BEGIN
                bps   = 8       ; 64 bit float
                dtype = 0D      ; statement added to V0.05
            END
            'DOUBLE': BEGIN
                bps   = 8       ; 64 bit float
                dtype = 0D      ; statement added to V0.05
            END
            ELSE: BEGIN
                PRINT, 'Data type "', tokens[2], '" not supported.'
                RETURN, -30
            END
        ENDCASE

        nspf = FIX(tokens[3])     ; set # samples per frame

        ; return samples per frame if GETSRATE set
        IF KEYWORD_SET(getsrate) THEN BEGIN
            nsr = nspf
            RETURN, 0
        ENDIF

        ; open raw data file
        OPENR, fieldlun, subdir + field, /GET_LUN, ERROR=err
        IF err NE 0 THEN RETURN, -21

        fsize = (FSTAT(fieldlun)).size
        nsif = fsize / bps      ; number of samples in file
        nfif = nsif / nspf      ; number of frames in file (round down)

        ; if SETNFIF set, nfif = nfifu
        IF SETNFIF THEN BEGIN
            IF nfifu LE nfif THEN nfif = nfifu $
            ELSE BEGIN
                FREE_LUN, formatlun
                RETURN, -90
            ENDELSE
        ENDIF ELSE nfifu = nfif
        
        ; set nfif such that (nfif mod nskip) = 0
        IF nskip GT 1 THEN nfif = (nfif / nskip) * nskip
        nsif = nfif * nspf      ; reject partial frames

;-------------------------------------------------------
; deal with keywords and out-of-range values

        ; fframe
        IF fframe LT 0 THEN fframe = 0 $
        ELSE IF fframe GT nfif THEN BEGIN
            nsr = nfif          ; set nsamp to nfif for use by caller
            FREE_LUN, fieldlun
            RETURN, -70
        ENDIF

        ; nframe
        IF nframe LE 0 THEN nframe = nfif ; setting to nfif reads all

        ; nskip

        IF nskip LE 0 THEN nskip = 0 $
        ELSE IF nskip GT nfif THEN BEGIN
            nsr = nfif
            FREE_LUN, fieldlun
            RETURN, -80
        ENDIF

        IF nframe LT nskip THEN BEGIN ; statement added to V0.02
            FREE_LUN, fieldlun
            RETURN, -81
        ENDIF

;-------------------------------------------------------
; Calculate, based on keywords and length of file/data format:
;    - ns: number of samples to readout
;    - sp: starting point -- 1st sample to be read
;    - ss: sample spacing
;
; I realize this looks like a big mess and is completely
; non-intuitive, but it was worked out with care. ie. it should be
; right and you shouldn't have to fool with it.

; Some changes to the following section in V0.03
; Notably, new keyword FROMEND and fframe-1 -> fframe

        nframe = LONG(nframe)
        fframe = LONG(fframe)

        IF nskip EQ 0 THEN BEGIN
            ; read every sample
            ss = 1
            IF fromend THEN BEGIN
                ; read from end
                ns = (nframe * nspf) < nsif
                sp = nsif - ns
            ENDIF ELSE BEGIN
                ; read from beginning
                ns = (nframe*nspf) < (nsif - (fframe)*nspf)
                sp = fframe*nspf
            ENDELSE
        ENDIF ELSE BEGIN
            ; skip samples
            ss = nskip*nspf
            IF fromend THEN BEGIN
                ; read from end
                ns = (nframe < nfif) / nskip
                sp = (nfif - ns*nskip)*nspf
            ENDIF ELSE BEGIN
                ; read from beginning
                ns = (nframe < (nfif-fframe)) / nskip
                sp = fframe*nspf
            ENDELSE
        ENDELSE

;-------------------------------------------------------------

        nsr = ns           ; number of samples read (N_ELEMENTS(data))
        frrt = 5.          ; frame rate
                           ; statement added to V0.02
        dtrt = frrt * nspf / ss ; frame rate * # samp. per frame / samp. 
                                ; skip size

        ; FRAME keyword
        frame = (DINDGEN(ns)*ss + sp) / nspf ; statement added to V0.03

        ; set time array (returned to user through TIME keyword)
        time = frame / frrt     ; statement added to V0.02 
                                ; re-written in V0.03

        ; return if NOREAD keyword set quit
        IF KEYWORD_SET(noread) THEN BEGIN
            FREE_LUN, fieldlun
            RETURN, 0
        ENDIF
  
        ; allocate temp array to read fully-sampled data
        ;tdata = REPLICATE(dtype, nsif-sp)
        tdata = REPLICATE(dtype, ns*ss) ; re-written in V0.04 (correct?)

        POINT_LUN, fieldlun, sp*bps
        READU, fieldlun, tdata

        ; allocate data array of type readd, set above
        data = replicate(dtype, ns)

        IF ss EQ 1 THEN $
          data = tdata[0:ns-1] $ ; if ss=1 read block
        ELSE BEGIN              ; else step through
            p = 0L
            FOR i=0L,ns-1 DO BEGIN
                IF filter AND (ss GT 1) THEN $
                  td = MEAN(tdata[p:p+ss-1]) $
                ELSE $
                  td = tdata[p]
                data[i] = td
                p = p + ss
            ENDFOR
        ENDELSE

        FREE_LUN, fieldlun

    END
    ELSE: RETURN, -40
ENDCASE

RETURN, 0

END

;--------------------------------------------------------------- 

FUNCTION READFIELD, dirfile, field, nsr, dtrt, data, nfifu, $
                    FFRAME=fframe, NFRAME=nframe, NSKIP=nskip, $
                    FROMEND=fromend, SETNFIF=setnfif, FILTER=filter, $
                    NOREAD=noread, TIME=time, FRAME=frame

; Read field 'field' from directory 'dirfile' into 'data'
; Data is calibrated according to format file
;
; See above.

IF NOT KEYWORD_SET(fframe)  THEN fframe  = 0L  ; CHANGE TO V0.03
IF NOT KEYWORD_SET(nframe)  THEN nframe  = -1L ; -1 to indicate no limit
IF NOT KEYWORD_SET(nskip)   THEN nskip   = 0
IF NOT KEYWORD_SET(fromend) THEN fromend = 0   ; ADDED TO V0.03
IF NOT KEYWORD_SET(setnfif) THEN setnfif = 0
IF NOT KEYWORD_SET(filter)  THEN filter  = 0
IF NOT KEYWORD_SET(noread)  THEN noread  = 0

; Following removed from V0.03 -- error codes not consistent across
; different version of IDL
;
; test for existence of dirfile
; added to v0.02
; OPENR, dirfilelun, dirfile, /GET_LUN, ERROR=err
; IF err NE -289 THEN RETURN, -10



; add trailing '/' to dirfile, if not present
dflen = STRLEN(dirfile)
IF STRMID(dirfile, dflen-1) NE '/' THEN $
  dirfile = dirfile + '/'

formatfile = dirfile + 'format'
OPENR, formatlun, formatfile, /GET_LUN, ERROR=err ; default

; test if format file exists
IF err NE 0 THEN  RETURN, -11

; Find FRAME offset
; New to V0.03

foffset = 0

ferr = GET_FORMAT_LINE(formatlun, 'FRAMEOFFSET', tokens, dirfile, formatfile)

newff = fframe
IF ferr EQ 0 THEN BEGIN
    foffset = tokens[1]
    newff = fframe - foffset
ENDIF

; call READFIELD_ITER
err = READFIELD_ITER(formatlun, dirfile, formatfile, field, nsr, dtrt, data, nfifu, $
                     FFRAME=newff, NFRAME=nframe, NSKIP=nskip, $
                     FROMEND=fromend, SETNFIF=setnfif, FILTER=filter, $
                     NOREAD=noread, TIME=time, FRAME=frame)

FREE_LUN, formatlun

; Adjust frame and time for FRAMEOFFSET
IF KEYWORD_SET(frame) THEN frame = frame + foffset
IF KEYWORD_SET(time)  THEN time  = time  + foffset / 5.

RETURN, err

END
