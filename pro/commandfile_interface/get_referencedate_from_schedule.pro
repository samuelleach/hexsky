FUNCTION get_referencedate_from_schedule,schedulefile

   ;AUTHOR: S. Leach
   ;PURPOSE: Read in and parse the first line of a schedule file which
   ;         contains a UTC reference date and time.

  unit = 13

  openr, unit, schedulefile

  ;-----------------------------------------
  ;Parse the first line of the schedule file
  ;-----------------------------------------
  line = ""
  readf,unit,line
  pos = strpos(line,'-',0)
  if (pos[0] gt 0) then year  = fix(strmid(line,0,4))       
  if (pos[0] gt 0) then month = fix(strmid(line,pos[0]+1,2))
  pos                                  = strpos(line,'-',/reverse_search)
  if (pos[0] gt 0) then day   = fix(strmid(line,pos[0]+1))
  print,'Schedule reference year, month, day  = ',$
    strtrim(year,2)+'-'+int2filestring(month,2)+'-'+$
    strtrim(day,2)

  pos                          = strpos(line,':',0)
  if (pos[0] gt 0) then hour   = strmid(line,pos[0]-2,2)
  if (pos[0] gt 0) then minute = strmid(line,pos[0]+1,2)
  pos                          = strpos(line,':',/reverse_search)
  if (pos[0] gt 0) then sec    = strmid(line,pos[0]+1,2)
  print,'Schedule reference hour, minute, sec = ',hour,':',minute,':',sec


  close,unit

  referencedate = [year,month,day,hour,minute,sec]

  return,referencedate

end
