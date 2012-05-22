FUNCTION READ_TEXT_DATA, file, ERROR=error,_EXTRA=extra

;+
;
; data = READ_TEXT_DATA(file, ERROR=error)
;
; Wrapper for READ_ASCII. Returns a 2-D data array instead of a
; structure. Takes any of READ_ASCII's keyworks. Returns the 
; single-element array [0] if file not successfully read.
;
;-

CATCH, err

IF err THEN BEGIN
    error = err
    RETURN, [0]
ENDIF

data = READ_ASCII(file, _EXTRA=extra)

RETURN, data.(0)

END
