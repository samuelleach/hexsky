PRO jpblib_init,set_path=set_path

; JPBlib startup file used to get all JPBlib routines in whatever
; environment
; Version 1.0	J.P.Bernard	?
; Version 1.1	P.Marty		22-JUN-00
;
;===============================
; Defines Environment Variables (If not already defined) :
;=========================
sysv='!sep'
defsysv, sysv, exist=exist
IF not exist THEN BEGIN
  CASE !version.os_family OF
    'unix':  defsysv, sysv, '/', 1
    'MacOS': defsysv, sysv, ':', 1
    'Win32': defsysv, sysv, '\', 1
    'OSF':   defsysv, sysv, '/', 1
    ELSE:    message,'Operating system '+!version.os_family+' not supported.',/info
    ENDCASE
ENDIF
;=========================
sysv='!path_sep'
defsysv, sysv, exist=exist
IF not exist THEN BEGIN
  CASE !version.os_family OF
    'unix':  defsysv, sysv, ':', 1
    'MacOS': defsysv, sysv, ',', 1
    'Win32': defsysv, sysv, ';', 1
    'OSF':   defsysv, sysv, ':', 1
    ELSE:    message,'Operating system '+!version.os_family+' not supported.',/info
    ENDCASE
ENDIF
                           ;=========================
sysv='!jpblib_dir'
defsysv, sysv, exist=exist
IF not exist THEN BEGIN
  CASE !version.os_family OF
    'MacOS':  defsysv, sysv, 'JPB:IDL_Libraries:JPBlib_V1.3:', 1
    'Win32': defsysv, sysv, '???', 1
    ELSE:    defsysv, sysv, GETENV("JPBLIB_DIR"),1
    ENDCASE
ENDIF
                           ;=========================
sysv='!dwingeloo_data_dir'
defsysv, sysv, exist=exist
IF not exist THEN BEGIN
  CASE !version.os_family OF
    'MacOS':  defsysv, sysv, 'Data:Astro:HI:', 1
    'Win32': defsysv, sysv, '???', 1
    ELSE:    defsysv, sysv, GETENV("DWINGELOO_DIR"),1
    ENDCASE
ENDIF
                           ;=========================
sysv='!dwingeloo_param_dir'
defsysv, sysv, exist=exist
IF not exist THEN BEGIN
  CASE !version.os_family OF
    'MacOS':  defsysv, sysv, 'Data:Astro:HI:', 1
    'Win32': defsysv, sysv, '???', 1
    ELSE:    defsysv, sysv, GETENV("DWINGELOO_DIR"),1
    ENDCASE
ENDIF
                           ;=========================
sysv='!cosurvey_data_dir'
defsysv, sysv, exist=exist
IF not exist THEN BEGIN
  CASE !version.os_family OF
    'MacOS':  defsysv, sysv, 'Data:Astro:CO:', 1
    'Win32': defsysv, sysv, '???', 1
    ELSE:    defsysv, sysv, GETENV("COSURVEY_DIR"),1
    ENDCASE
ENDIF
                           ;=========================
sysv='!iras_data_dir'
defsysv, sysv, exist=exist
IF not exist THEN BEGIN
  CASE !version.os_family OF
    'MacOS':  defsysv, sysv, 'Data:Astro:IRAS:', 1
    'Win32': defsysv, sysv, '???', 1
    ELSE:    defsysv, sysv, GETENV("IRAS_DATA_DIR"),1
    ENDCASE
ENDIF
                           ;=========================
sysv='!iris_data_dir'
defsysv, sysv, exist=exist
IF not exist THEN BEGIN
  CASE !version.os_family OF
    'MacOS':  defsysv, sysv, 'Data:Astro:IRAS:', 1
    'Win32': defsysv, sysv, '???', 1
    ELSE:    defsysv, sysv, GETENV("IRIS_DATA_DIR"),1
    ENDCASE
ENDIF

;********************* You should not need to modify below this line ***********************
defsysv, '!jpblib_version', '1.3', 1
;===============================
; Expands IDL procedures Path :
IF keyword_set(set_path) THEN !path = !path + !path_sep + expand_path('+' + !jpblib_dir)
defsysv, '!loaded_lib', exist=exist
IF exist THEN BEGIN
  defsysv, "!loaded_lib", !loaded_lib + strlowcase('JPBlib V' + !jpblib_version) + ","
ENDIF ELSE BEGIN
  defsysv, "!loaded_lib",''
ENDELSE
                         ;===============================
; Routine Initialization :
defsysv, '!jpblib_example_dir', !jpblib_dir+'Examples'+!sep,        1
defsysv, '!jpblib_issa_dir',    !jpblib_dir+'ISSA'+!sep,            1
defsysv, '!jpblib_help_dir',    !jpblib_dir+'Help'+!sep+'Html'+!sep, 1
!path = !path + !path_sep + filepath('', /tmp)
;stop
PRINT,"Trash area added to path"
defsysv, '!indef', exist=exist
IF NOT exist THEN defsysv, '!indef', -32768., 1
;===============================
PRINT, 'JPBlib V' + !jpblib_version + ' Software now available for ' + !version.os

END
