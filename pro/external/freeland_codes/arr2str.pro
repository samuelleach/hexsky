;+
; Project     : SSW     
;                   
; Name        : ARR2STR()
;               
; Purpose     : Convert an array to a delimited string.
;               
; Explanation : 
;               
; Use         : IDL> s = arr2str(array,'-')
;                    s = arr2str(array,delim='-')
;    
; Inputs      : arr  -  input data array which is to be converted
;                       to a simple string.
;               
; Opt. Inputs : delim - an alternative positional parameter to specify the
;                       delimiter.
;               
; Outputs     : Function returns a simple string using the delimiter to 
;               separate the elements of the original array.
;               
; Opt. Outputs: 
;               
; Keywords    : delimiter  -  specify the delimiter to be used, default 
;                             delimiter is ','
;		trim_str   -  If set, call STRTRIM when converting to string
;		compress   -  If set, call STRCOMPRESS after converting
;               no_duplicate  If set, inhibit having string with consecutive
;                             delimiters such as // 
;
; Calls       :
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, string
;               
; Prev. Hist. : Sam Freeland 11/19/91 
;               (Various Slf,MDM,DP mods)
;
; Written     : Sam Freeland 
;               
; Modified    : Version 2, William Thompson, GSFC, 15 June 1995
;			Added /TRIM keyword to be compatible with Yohkoh
;			version.  Added /COMPRESS keyword
;               Version 2.1, Sam Freeland, SSW merge
;               Version 3, Zarro (SAC/GSFC) - added /NO_DUPLICATE &
;                       renamed TRIM keyword to TRIM_STR to avoid
;                       name conflict with TRIM function
;
; Version     : Version 3
;-            

function arr2str, starray, delim, delimiter=delimiter, trim_str=trim_str,$
	compress=compress,no_duplicate=no_duplicate

;
;force a return to caller on error
;
on_error, 2      

;
;  delimiter specified as positional parameter
;
if n_params() eq 2 then delimiter = delim

;
;  use default delimiter
;
if (n_elements(delimiter) eq 0) then delimiter=','

;
;  clean up array
;
strings=string(starray)
if (keyword_set(trim_str)) then strings=(strtrim(string(starray),2))
string=strings(0)

;
;  concatenate elements with required delimiter
;

no_dup=keyword_set(no_duplicate)
for i=1,n_elements(starray)-1 do begin
 temp_limiter=delimiter
 if no_dup then begin
  first_char=strmid(strtrim(strings(i),2),0,1)
  if first_char eq delimiter then temp_limiter=''
 endif
 string = string + temp_limiter + strings(i)
endfor
if keyword_set(compress) then string=strcompress(string)

return,string

end
