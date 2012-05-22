pro schedule_update_time_to_next_command,schedule

  ;AUTHOR: S. Leach
  ;PURPOSE: Calculates and updates the time to the next command.

  for cc = 0,schedule.ncommands -2 do begin
    schedule.command[cc].time_to_next_command   = $
	      24.*(1.*schedule.command[cc+1].parameters[0]- $
		   1.*schedule.command[cc].parameters[0]) + $
	      float(schedule.command[cc+1].parameters[1])-$
	      float(schedule.command[cc].parameters[1])
  endfor
	    
end