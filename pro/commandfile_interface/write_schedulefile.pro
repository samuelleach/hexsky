pro write_schedulefile,file,schedule,comment=comment,stop_commands=stop_commands

  ;AUTHOR: S. Leach
  ;PURPOSE: Write a schedule (array of command structs)
  ;         to a file.

  ; Need to add local start time and local end time
  
  ;Write the reference UTC data and time in the first line
  message,'Writing schedule file to '+file,/cont
  openw,lun,file,/get_lun

  hour    = floor(schedule.hour_utc)
  minutes = floor((schedule.hour_utc-hour)*60.d0)
  seconds = floor(((schedule.hour_utc-hour)*60.-minutes)*60.d0)

  date =  string(schedule.year,f='(I4.4)') + '-' + $
	string(schedule.month,f='(i2.2)') +  $
    '-'+string(schedule.day,f='(i2.2)')

  time =  string(hour,f='(I2.2)') + ':' + string(minutes,f='(i2.2)') +  $
    ':'+string(seconds,f='(i2.2)')

  printf,lun,date+' '+time
  printf,lun,' '

  ;--------------------------------
  ; Write comments in schedule file
  ;--------------------------------
  timestring='# Written on '+systime()
  if !version.os_family eq 'unix' then begin
    spawn,'whoami',  username
    spawn,'uname -n',machinename
    timestring = timestring+' by '+username+'@'+machinename+'.'
  endif
  printf,lun,timestring
  if n_elements(comment) ne 0 then begin
      printf,lun,' '
      for cc=0,n_elements(comment)-1 do begin
          printf,lun,'# '+comment[cc]
      endfor
  endif
  printf,lun,' '
  printf,lun,' '
  

  ;Write commands
  ncommand = schedule.ncommands
  for cc=0L, ncommand-1L do begin
    printf,lun,command_to_string(schedule.command[cc])

    if keyword_set(stop_commands) then begin
    ;Temporary fix for EBEX NA campaign 2009 - need stop command between cmb_scans
    ;with parameters that change from one command to another.
       if cc lt ncommand-1L then begin
          stopcommand = 'stop            '+strtrim(fix(schedule.command[cc+1].parameters[0]),2)+$
                        ' '+number_formatter(schedule.command[cc+1].parameters[1]-0.001,dec=3)
          printf,lun,stopcommand
       endif
    endif
  endfor
    
  free_lun,lun

end
