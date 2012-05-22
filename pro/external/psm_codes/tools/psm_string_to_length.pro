; Copyright 2008 jacques Delabrouille, CNRS

; This file is part of the Planck Sky Model.
;
; The Planck Sky Model is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; version 2 of the License.
;
; The Planck Sky Model is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY, without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with the Planck Sky Model. If not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

;+
; Routine to add at the end (or beginning) of a string the number of trailing (or leading) blanks to make its length
;     match the given input length (useful for writing formatted strings in a file)
; @param strin {in}{required}{type=string} The string to be modified
; @param leng {in}{required}{type=integer} The length of the output string
; @keyword strict {in}{optional}{type=boolean} set this keyword for last characters to be cut out if the input string is greater than length
; @keyword leading {in}{optional}{type=boolean} set this keyword to add characters at beginning rather than end
; @keyword character {in}{optional}{type=string} set this keyword to a one character string, to set the character added at beginning or end (default=blank character ' ')
; @examples
; @history <p>02/12/2008: Initial version, Jacques Delabrouille</p>
; @copyright Jacques Delabrouille, CNRS
;-

FUNCTION SINGLE_STRING_TO_LENGTH, strin, leng, strict=strict, leading=leading, character=character

instrlen = STRLEN(strin)
st=strin

IF NOT KEYWORD_SET(character) THEN character=' '

IF instrlen LT leng THEN BEGIN
  nblanks = leng-instrlen
  IF NOT KEYWORD_SET(leading) THEN FOR i=0, nblanks-1 DO st=st+character ELSE FOR i=0, nblanks-1 DO st=character+st
ENDIF
len = STRLEN(st)

IF KEYWORD_SET(strict) NE 0 THEN BEGIN
   IF NOT KEYWORD_SET(leading) THEN st = STRMID(st,0,leng) ELSE st = STRMID(st,len-leng,leng)
ENDIF

RETURN, st
END

FUNCTION PSM_STRING_TO_LENGTH, strin, leng, strict=strict, leading=leading, character=character, help=help

  IF KEYWORD_SET(help) NE 0 THEN BEGIN
     PRINT, 'PSM_STRING_TO_LENGTH: function for formatting a string to a given length'
     PRINT, 'SYNTAX: result = PSM_STRING_TO_LENGTH(strin, leng, strict=, leading=, character=)'
     RETURN, 0
  ENDIF

IF ISARRAY(strin) THEN BEGIN

   nstr = N_ELEMENTS(strin)
   st = strin
   FOR i=0, nstr-1 DO st[i] = SINGLE_STRING_TO_LENGTH(strin[i], leng, strict=strict, leading=leading, character=character)
   RETURN, st

ENDIF ELSE RETURN, SINGLE_STRING_TO_LENGTH(strin, leng, strict=strict, leading=leading, character=character)



END
