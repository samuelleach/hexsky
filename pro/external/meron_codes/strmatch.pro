Function StrMatch, str, list, len, caseon = cas, all = all, exclude = exl

;+
; NAME:
;	STRMATCH
; VERSION:
;	3.0
; PURPOSE:
;	Compares the string STR with the strings in the array LIST.  Comparison
;	is done for the first LEN characters, or all of them if LEN is 0.  If a
;	 match is found, STR is replaced by the full string from the list (or
;	if the keyword /ALL is set, by an array containing all the matching 
;	strings).
; CATEGORY:
;	String Processing.
; CALLING SEQUENCE:
;	Result = STRMATCH( STR, LIST [, LEN] [, keywords])
; INPUTS:
;    STR
;	Character string.
;    LIST
;	Character array.
; OPTIONAL INPUT PARAMETERS:
;    LEN
;	The number of characters to compare.  Default is full comparison.
; KEYWORD PARAMETERS:
;    /CASEON
;	Switch. If set the comparison is case sensitive. Default is ignore case.
;    /ALL
;	Switch.  If set, returns the indices of all the matching elements.
;    /EXCLUDE
;	Switch.  If set returns the indices of all the non-matching elements.
; OUTPUTS:
;	Returns the index of the first match, or -1l if no match is found.
;	Optionally (see keyword ALL above) returns all the matching indices,
;	or non-matching indices when the keyword EXCLUDE is set.
; OPTIONAL OUTPUT PARAMETERS:
;	None.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None other then the substitution in STR.
; RESTRICTIONS:
;	None.
; PROCEDURE:
;	Uses the function STREQ from MIDL.
; MODIFICATION HISTORY:
;	Created 15-JUL-1991 by Mati Meron.
;	Modified 20-NOV-1993 by Mati Meron.  Added keyword ALL.
;	Modified 11-OCT-1997 by Roger J. Dejus.  Added keyword EXCLUDE.
;-

    if keyword_set(exl) then $
	match = where(Streq(str,list,len,caseon = cas) eq 0, nmatch) else $
	match = where(Streq(str,list,len,caseon = cas), nmatch)
    if not keyword_set(all) then match = match(0)
    if nmatch gt 0 then str = list(match)

    return, match
end