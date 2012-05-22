; Copyright 2007 C.N.R.S., Observatoire de Paris

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
; Fills structures of parameters reading a config file
;
; @categories pipe
;
; @param file {in}{required}{type=string} path toward the config file 
; @param params {out}{type=struct} encapsulates the set of parameters
; @param seed {out}{required}{type=int/string} seed value (value is 'NO_SEED' in prediction case)
;
; @uses fill_struct, read_simulation_param, read_prediction_param
;
; @history <p>Created, january 2007, Marc Betoule</p>
; @history <p>bug fixed in definition of SZ parameters, february 01 2007, Jacques Delabrouille</p>
; @history <p>split reading into two branch : simulation and prediction, february 05 2007, Marc Betoule </p>
; @history <p>Improved detection of syntax errors, february 06 2007, Marc Betoule </p>
; @history <p>Seed is an output parameter and is set @ psm_main july 12 2007, Maude Le Jeune</p>
; @history <p>Default version number defined to 1.4 instead of 1.9, July 13 2007, Jacques Delabrouille </p>
; @history <p>Now calls DEFINE_CONST to define physical constants (speed of light, etc...), July 13 2007, Jacques Delabrouille </p>
; @history <p>Now default output units are mK_RJ, July 19 2008, Jacques Delabrouille </p>
; @history <p>Specify syntax error is in the parameter file, August 27 2008, Sam Leach </p>
;-
;pro read_param_file, file, params, seed
pro read_parfile, file, table
  
  ;;Reads the file discarding empty lines
  ;;and lines which begin with '#'
  line = ""
  table = ['','']
  openr, 1, file
  iline =0
  while (not EOF(1)) do begin
    readf,1,line
    iline=iline+1
    line = strtrim(line,2)
    if strmid(line, 0, 1) ne '#' and strlen(line) ge 1 then begin
      i = strpos(line,'=')
      if i eq -1 then begin
        close,1
        message,'Syntax error in parameter file at line ' + strtrim(iline,2) + ' : ' + line
      endif
      key=strmid(line, 0, i)
      val=strmid(line, i+1)
      table = [[table],[key,val]]
    endif
  endwhile
  close, 1
  
  table = table[*,1:*]
  
end
