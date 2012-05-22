pro insert_ascent_command,schedule_in,schedule_out,ascent_duration_hr

  ;AUTHOR: S. Leach
  ;PURPOSE: Put a dipole scan (ascent simulation) at the beginning of 
  ;        a schedule.


  schedule_out = schedule_in
  day0         = schedule_out.command[0].parameters[0]
  lst0         = schedule_out.command[0].parameters[1]

  if lst0 lt ascent_duration_hr then begin
     day_dipole_scan = day0 - 1.
     lst_dipole_scan = lst0 + 24. - ascent_duration_hr
  endif else begin
     day_dipole_scan = day0
     lst_dipole_scan = lst0 - ascent_duration_hr
  endelse
  
  totaltime      = ascent_duration_hr * 3600.
  dipole_command = example_dipole_scan(totaltime=totaltime,day=day_dipole_scan,lst=lst_dipole_scan)  
  schedule_out   = merge_commands_into_schedule(schedule_out,dipole_command)


end
