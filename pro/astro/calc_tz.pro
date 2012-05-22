FUNCTION CALC_TZ,longitude,DST = dst

  ;AUTHOR: C. Bao
  ;PURPOSE: Calculate timezone based longitude.

  if n_elements(dst) eq 0 then dst = 'off'
  
  if longitude lt 180. then tz =  round(longitude / 15.) $
  else tz = round((-360. + longitude)/15.)

  if keyword_set(dst) then begin
  if dst eq 'on' then tz= tz+1
  endif
  return,tz

END


