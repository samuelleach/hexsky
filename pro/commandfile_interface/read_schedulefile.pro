function read_schedulefile, file
  
  ;AUTHOR: S. Leach
  ;PURPOSE: Code for reading in BLAST/EBEX schedule
  ;         file into an IDL {schedule} structure.

  schedule          = {schedule}
  schedule.filename = file

  ;;Reads the file discarding empty lines
  ;;and lines which begin with '#'

  line  = ""
  table = ['','']
  openr, 1, file
  iline = 0

  ;-----------------------------------------
  ;Parse the first line of the schedule file
  ;-----------------------------------------
  reference      = get_referencedate_from_schedule(file)
  schedule.year  = reference[0]
  schedule.month = reference[1]
  schedule.day   = reference[2]
  hour           = reference[3]
  minute         = reference[4]
  sec            = reference[5]
  schedule.hour_utc = hour + float(minute)/60. + float(sec)/3600.
  print, ' => UTC = ', schedule.hour_utc

  readf,1,line

;   pos = strpos(line,'-',0)
; ;  if (pos[0] gt 0) then schedule.year  = fix(strmid(line,0))       ;Buggy with gdl0.9rc3
; ;  if (pos[0] gt 0) then schedule.month = fix(strmid(line,pos[0]+1));Buggy with gdl0.9rc3
;   if (pos[0] gt 0) then schedule.year  = fix(strmid(line,0,4))       
;   if (pos[0] gt 0) then schedule.month = fix(strmid(line,pos[0]+1,2))
;   pos                                  = strpos(line,'-',/reverse_search)
;   if (pos[0] gt 0) then schedule.day   = fix(strmid(line,pos[0]+1))
;   print,'Schedule reference year, month, day  = ',$
;         strtrim(schedule.year,2)+'-'+int2filestring(schedule.month,2)+'-'+$
;         strtrim(schedule.day,2)

;   pos                          = strpos(line,':',0)
;   if (pos[0] gt 0) then hour   = strmid(line,pos[0]-2,2)
;   if (pos[0] gt 0) then minute = strmid(line,pos[0]+1,2)
;   pos                          = strpos(line,':',/reverse_search)
;   if (pos[0] gt 0) then sec = strmid(line,pos[0]+1,2)
;   print,'Schedule reference hour, minute, sec = ',hour,':',minute,':',sec




  nc = 0
  while (not EOF(1)) do begin
    readf,1,line
    iline = iline+1
    line  = strtrim(line,2)
    if strmid(line, 0, 1) ne '#' and strlen(line) ge 1 then begin
      i = strpos(line,' ') ;Looks for spaces between command name and command parameters
      if i eq -1 then begin
        close,1
        print,'Syntax error in parameter file at line ' + strtrim(iline,2) + ' : ' + line
	message,'Please remove any tabs in the command file'
      endif
      key   = strmid(line, 0, i)
;      val   = strmid(line, i+1)         ; Problem for gdl0.9rc3
      val   = strmid(line, i+1,2000)
      table = [[table],[key,val]]
      nc = nc +1
    endif
  endwhile
  close, 1
  
  table = table[*,1:*]

  ;--------------------------
  ;Work out how many commands
  ;--------------------------
  nc = size(table)
  if(nc[0] eq 1) then begin
     ncommand = 1
  endif else begin
     ncommand = nc[2]
  endelse

  ;---------------------------
  ;Create a schedule structure
  ;---------------------------
  parameters           = get_parameters(table[*,0],nparameters=nparameters)
  comment              = get_comment(table[*,0])
  time_to_next_command = 24.
  expected_duration    = 25.

  schedule.ncommands   = ncommand
  ;--------------------------------------
  ;Replicate the structure and fill it up
  ;--------------------------------------
  for cc=0,ncommand -1 do begin
      schedule.command[cc].name                 = table[0,cc]
      schedule.command[cc].parameters           = get_parameters(table[*,cc],nparameters=nparameters)
      schedule.command[cc].nparameters          = nparameters
      schedule.command[cc].comment              = get_comment(table[*,cc])
      schedule.command[cc].time_to_next_command = 24.
      schedule.command[cc].expected_duration    = 25.
  endfor

  ;------------------------------------------------
  ;Calculate the time until the next command starts
  ;------------------------------------------------
  schedule_update_time_to_next_command,schedule
  

  return,schedule
  
end
