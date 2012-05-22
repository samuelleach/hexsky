; Copyright 2007 ----

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
; Looks for a keyword and read its corresponding value in a table
;
; Case-insensitive search in the table
;
; @categories pipe
;
; @param table {in}{required}{type=strarr(*,2)} vector of couple (keyword, value) 
; @param keyword {in}{required}{type=string} the keyword we look for
; @keyword default {in}{optional}{type=generic} default value to return if the specified keyword is not present in the list. If undefined the keyword is compulsory and an error is raised if not found.
; @returns the corresponding value in the table
;      
; @history Created, january 2007, Marc Betoule
;-
function read_keyword, table, keyword, default=default
  entries = strupcase(table[0,*])
  entries = strcompress(entries, /remove_all)

  keyword = strupcase(keyword)
  keyword = strcompress(keyword, /remove_all)
  
  index = where(entries eq keyword, noccur)
  
  if noccur eq 0 then begin
    if keyword_set(default) then begin
      message, 'Keyword '+ keyword + ' set to '+strjoin(string(default))+' by default',/info
      return, default
    endif else message, "Missing keyword " + keyword
  endif else if noccur eq 1 then begin
    val = table[1,index[0]]
    val = strtrim(val,2)
    val = strcompress(val)
    if strpos(val,' ') ne -1 then begin
      pos1=0
      pos2=strpos(val,' ',pos1)
      tab = [strmid(val,pos1, pos2-pos1)]
      pos1 = pos2+1
      pos2 = strpos(val,' ',pos1)
      while pos2 ne -1 do begin
        tab = [tab,strmid(val,pos1, pos2-pos1)]
        pos1 = pos2+1
        pos2 = strpos(val,' ',pos1)
      endwhile
      tab=[tab, strmid(val, pos1)]
      return, tab
    endif else begin
      return, val
    endelse
  endif else message, "Keyword " + keyword + " occurs more than once"
end
