FUNCTION STR_SPL_WS, str

;+
; Returns array of all elements in 'str' separated by white space
; (spaces and tabs). Strips leading and trailing white space from each
; element. 
;
; USAGE: string_array = STR_SPL_WS(input_string)
;
; eg:
;     IDL> is = "hello my  name is "
;     IDL> os = STR_SPL_WS(is)
;     IDL> HELP, os
;       OS              STRING    = Array[4]
;     IDL> FOR i=0,N_ELEMENTS(os)-1 DO PRINT, '>' + os[i] + '<'
;       >hello<
;       >my<
;       >name<
;       >is<
;-

; remove leading and trailing white space
sstr = STRTRIM(str, 2)

first = 1                       ; = 1 if first element
cstr = ''                       ; current string

WHILE STRLEN(sstr) GT 0 DO BEGIN
    cch = STRMID(sstr, 0, 1)     ; current character
    IF (cch EQ STRING(32B)) OR (cch EQ STRING(9B)) THEN BEGIN
        IF first THEN BEGIN
            star = [cstr]
            first = 0
        ENDIF ELSE star = [star, cstr]
        sstr = STRTRIM(sstr, 1)
        cstr = ''
    ENDIF ELSE BEGIN
        cstr = cstr + cch
;        sstr = STRMID(sstr, 1)     ; Buggy in gdl0.9rc3
        sstr = STRMID(sstr, 1,2000)
    ENDELSE
ENDWHILE

IF first THEN star = [cstr] $
ELSE star = [star, cstr]

RETURN, star

END

