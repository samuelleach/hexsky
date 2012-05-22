; Copyright 2007 Marc Betoule, Jacques Delabrouille, CNRS, Observatoire de Paris

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
; Analyse a string to check if it corresponds to a recognized PSM unit. Leading and trailing blanks
; are removed from the input unit in the process, if any.
;
;  @param unit {in}{required}{type=string} The unit of input data
;  among the list :
;  ['Jy/sr','K_CMB','K_RJ','K/KCMB','y_sz','W/m2/sr/Hz'] optionally
;  prefixed by ['n','u','m','k','M','G'] for nano, micro, milli, kilo,
;  Mega, Giga, and optionally raised to an integer power, in which case the unit is in parentheses
;  and postfixed by ['**2','**3',...]
;  @param prefix {out}{optional}{type=string} prefix of the units (e.g. 'k', 'G', ...) 
;  @param core {out}{optional}{type=string} core unit value (e.g. 'K_CMB', ...)
;  @param exponent {out}{optional}{type=integer}
;  @history <p>28/02/2007: First version, Marc Betoule </p>
;  @history <p>20/01/2009: More strict checking, added exponent, Jacques Delabrouille </p>
;  @history <p>28/09/2009: Added 'unknown' unit, Jacques Delabrouille </p>
;   
;-
FUNCTION CHECKUNIT, unit, prefix, core, exponent, type, help=help

  IF KEYWORD_SET(help) NE 0 THEN BEGIN
     PRINT, PSM_STRING_TO_LENGTH('-',LINE_LENGTH(),character='-')
     PRINT, 'CHECKUNIT: function to check whether a string is a valid PSM unit, and decompose it'
     PSM_INFO_MESSAGE, 'SYNTAX: result = CHECKUNIT(unit, prefix, core, exponent, type)'
     PSM_INFO_MESSAGE, 'unit is the input string'
     PSM_INFO_MESSAGE, 'prefix, core, exponent, and type are optional outputs for unit decomposition'
     PRINT, PSM_STRING_TO_LENGTH('-',LINE_LENGTH(),character='-')
     RETURN, 0
  ENDIF

supported_units=['Jy/sr','K_CMB','K_RJ','K/KCMB','y_sz','W/m2/sr/Hz','unknown','rad','deg','arcmin','arcsec','meter','parsec','gram','Msun']
type_units=['flux','flux','flux','flux','flux','flux','unknown','angle','angle','angle','angle','length','length','mass','mass']

;;nano, micro, milli, kilo, mega, giga
supported_prefix=['n','u','m','k','M','G']
;;parse
unit = STRTRIM(unit,2)

;;check for exponent
exponent_ok = 0B
unitexp = STR_SEP(unit,'**')
IF N_ELEMENTS(unitexp) EQ 1 THEN BEGIN
   exponent_ok = 1B
   exponent = '1'
ENDIF
IF N_ELEMENTS(unitexp) EQ 2 THEN BEGIN
   exponent = unitexp[1]
   exponent = STRTRIM(exponent,2)
   exponent_ok = (FLOAT(exponent) EQ FIX(exponent))
   IF STRLEN(exponent) EQ 0 THEN exponent_ok = 0B
ENDIF

;; core of the unit
core_ok = 0B
FOR i = 0, n_elements(supported_units)-1 DO BEGIN
   pos = STRPOS(unit, supported_units[i])
   IF pos NE -1 THEN BEGIN 
      core = supported_units[i]
      core_ok = 1B
      IF pos EQ 0 THEN prefix = '' ELSE prefix = STRMID(unit,pos-1,1)
      IF prefix EQ '(' THEN prefix = '' 
   ENDIF
ENDFOR

IF NOT core_ok THEN BEGIN
   core=''
   prefix=''
   exponent=''
ENDIF ELSE BEGIN
   which = WHERE(supported_units EQ core)
   type = (type_units(which))[0]
ENDELSE

;;check if pref is valid
prefix_ok = 0B
IF core_ok THEN BEGIN
   IF STRLEN(prefix) EQ 0 THEN prefix_ok = 1B
   IF STRLEN(prefix) EQ 1 THEN BEGIN
      wh = WHERE(supported_prefix EQ prefix, nwh) 
      IF nwh EQ 1 THEN prefix_ok = 1B
   ENDIF
ENDIF

IF exponent NE 1 THEN new_unit = '('+prefix+core+')**'+exponent ELSE new_unit = prefix + core
check_ok = (new_unit EQ unit)

;HELP, exponent_ok, core_ok, prefix_ok, check_ok

RETURN, exponent_ok * core_ok * prefix_ok * check_ok
END
