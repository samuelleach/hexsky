pro write_parameterfile, file, st


openw, lun, file, /get_lun

if not keyword_set(st) then return
tags = tag_names(st)

;Check for '__' and replace with parentheses.
for i = 0, n_elements(tags)-1 do begin
  mm = strpos(tags[i],'__')
  if mm ne -1 then begin
    tag=tags[i]
    strreplace,tag,'__','('    
    tags[i]=  tag+')'
  endif
endfor
					

for i = 0, n_elements(tags)-1 do begin
    if n_elements(st.(i)) gt 1 then $
      val = fltarr2string(st.(i)) else $
      val = strtrim(string(st.(i),/print),2)

    printf, lun, strlowcase(tags[i]) + ' = ' + val
endfor

free_lun, lun

end
