pro schedule_shift,schedulefile_in,schedulefile_out,shift_hr,$
                   shift_ra=shift_ra



  ;AUTHOR: S. Leach
  ;PURPOSE: Read in a schedule file, delay start of commands by shift_hr
  ;         and increase the RA of the scanning commands by shift_hr.
  ;

  if n_elements(shift_ra) eq 0 then shift_ra = 0

  schedulein  = read_schedulefile(schedulefile_in)
  scheduleout = schedulein

  for cc = 0, schedulein.ncommands do begin
     format = command_format(schedulein.command[cc].name,ra_index=ra_index)
     scheduleout.command[cc].parameters[1]= schedulein.command[cc].parameters[1]+shift_hr

     ;Update the time and day of the commands
     while scheduleout.command[cc].parameters[1] lt -24. do begin
        scheduleout.command[cc].parameters[1] = scheduleout.command[cc].parameters[1] + 24.
        scheduleout.command[cc].parameters[0] = scheduleout.command[cc].parameters[0] -1.
     endwhile

     while scheduleout.command[cc].parameters[1] gt 24. do begin
        scheduleout.command[cc].parameters[1] = scheduleout.command[cc].parameters[1] - 24.
        scheduleout.command[cc].parameters[0] = scheduleout.command[cc].parameters[0]+1.
     endwhile
     
     ;Update the RA of the commands
     if shift_ra eq 1 then begin
         if ra_index ne -1 then begin        
             scheduleout.command[cc].parameters[ra_index] = (scheduleout.command[cc].parameters[ra_index] + shift_hr) mod 24.
         endif     
     endif

  endfor


  if shift_ra eq 1 then begin
      racomment = ' and RA '
  endif else begin
      racomment = ''
  endelse
      
  comment = 'This schedule file is '+schedulefile_in+' with each command start time '+$
    racomment+'shifted by '+number_formatter(shift_hr,dec=3)+' hours.'

  write_schedulefile,schedulefile_out,scheduleout,comment=comment


end
