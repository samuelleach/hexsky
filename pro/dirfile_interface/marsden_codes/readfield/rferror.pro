PRO RFERROR, error

; Print to screen description of error code

IF N_PARAMS() NE 1 THEN BEGIN
    PRINT, "Proper usage: 'RFERROR, <int>'. Aborting."
    RETURN
ENDIF

WRITEU, -1, "READFIELD ERROR ", STRTRIM(STRING(error),2), ": "

CASE error of

    0:    PRINT, "successful completion"
    -10:  PRINT, "DIRFILE not found"
    -11:  PRINT, "FORMAT file not found"
    -12:  PRINT, "INCLUDEd format file not found"
    -13:  PRINT, "Recursive INCLUDE format file definition"
    -20:  PRINT, "FIELD not found in format file"
    -21:  PRINT, "field data file not found (but exists in format file)"
    -30:  PRINT, "unsupported data type (not 16- or 32-bit uint)"
    -31:  PRINT, "interpolation data file not found (for LINTERP cal type)"
    -32:  PRINT, "data fields in MULTIPLY field have different sample rates"
    -33:  PRINT, "data fields in MULTIPLY field have different number of samples"
    -40:  PRINT, "calibration type not supported (not LINCOM, LINTERP or RAW)"
    -50:  PRINT, "raw data field not found in format file"
    -60:  PRINT, "calibration field not found in format file"
    -70:  PRINT, "FFRAME larger than number of frames in file. NS set to nfif."
    -80:  PRINT, "NSKIP larger than number frames in file. NS set to nfif."
    -81:  PRINT, "NSKIP larger than NFRAME. set NSKIP <= NFRAME."
    -90:  PRINT, "NFIFU set to larger than nfif"
    ELSE: PRINT, "error code not defined"

ENDCASE

RETURN

END
