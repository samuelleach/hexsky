function merge_commands_into_schedule,schedule,commands

  ;AUTHOR: S. Leach
  ;PURPOSE: Merge an array of commands into a schedule struct (insert, reorder, check)

  nmerge = n_elements(commands)

  newschedule = schedule
  for cc=0, nmerge-1 do begin
     nc           = newschedule.ncommands
     if nc gt 0 then begin
        lst_schedule = newschedule.command[0:(nc-1)].parameters[0]*24. + newschedule.command[0:(nc-1)].parameters[1]
        lst_command  = commands[cc].parameters[0]*24. + commands[cc].parameters[1]  

        index = where(lst_command gt lst_schedule)
        if index[0] eq -1 then begin
           placement = 0
        endif else begin
           placement = index[n_elements(index)-1]+1
        endelse

        oldcommands = newschedule.command
        newcommands = arrinsert(oldcommands,commands[cc],at=placement)
        newschedule.command[0:nc] = newcommands[0:nc]
     endif else begin
        newschedule.command[0] = commands[cc]
     endelse

     newschedule.ncommands = newschedule.ncommands + 1
  endfor
 
  return,newschedule

end
