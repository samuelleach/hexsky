; Copyright 2007 Observatoire de Paris

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
; Returns the number of lines in an ASCII file. This function is built
; into IDL versions starting from 5.6. This replacement program has been
; taken from the IDL online help.
;
; @categories tools
; 
; @param filename {in}{required}{type=str} Name of ASCII file.
;
; @history <p>Created October 16 2007, Sam Leach</p>
;-

FUNCTION file_lines, filename
  OPENR, unit, filename, /GET_LUN
  str = ''
  count = 0ll
  WHILE not(EOF(unit)) DO BEGIN
    READF, unit, str
    count = count + 1
  ENDWHILE
  FREE_LUN, unit
  RETURN, count
END  
