pro write_dipole_commands,reference_date,mission

  ;Author: C.Bao
  ;Purpose: Automatically generates dipole commands         


  ;Reference date
  year   = reference_date[0]
  month  = reference_date[1]
  day    = reference_date[2]


  ; total time
  tot_t = 3600
  ; elevation
  elev = 36
  ; final az and final el to be removed says Will.
  ; az_speed
  az_speed = 15.0

  initial_day = 11
  nday     = 20
  nscan    = 2
  scantime = make_array(nday,nscan)
  
  
  ;First iteration. May need to improve as we learn the constraints.
  scantime[*,0]= 9.5
  scantime[*,1]= 1.5
  
  for dd=0,nday-1 do begin
   mission.day       = (day+dd+initial_day-1) mod 31
   mission.month     = month+floor((day+dd+initial_day-1)/31)
   schedule = {schedule}
   schedule.year     = year
   schedule.month    = month
   schedule.day      = day 
   schedule.hour_utc = 6.0

   schedule.ncommands = nscan

    for cc = 0,nscan-1 do begin
     schedule.command[cc] = {command}
     schedule.command[cc].name = 'cmb_dipole'
     schedule.command[cc].nparameters = 5 ; without final az and el
     schedule.command[cc].comment = 'Dipole'
     schedule.command[cc].time_to_next_command = 24.
     schedule.command[cc].expected_duration = 25.
     schedule.command[cc].parameters[0] = day+dd+initial_day-1
     schedule.command[cc].parameters[1] = scantime[dd,cc]
     schedule.command[cc].parameters[2] = az_speed
     schedule.command[cc].parameters[3] = elev
     schedule.command[cc].parameters[4] = tot_t
   endfor

 ; Update the times to the next command in the schedule
 schedule_update_time_to_next_command,schedule

 ;Make a comment for the schedule file
 nc        = schedule.ncommands
 jd        = get_jd_from_schedule(schedule)
 starttime = jd2dateandtime(jd[0]) 
 jd_end    = jd[nc-1] + schedule.command[nc-1].expected_duration/24.
 endtime   = jd2dateandtime(jd_end)
 comment   = 'Schedule starts on '+starttime+' and ends on '+endtime

 print,mission.month,mission.day

 ;Write to disk
 month_string = strlowcase(themonths(mission.month))
 fileroot = 'dipole_'+month_string+strtrim(string(mission.day),2)+'.sch'
 filename = !HEXSKYROOT+'/schedulefiles/'+fileroot
 schedule.filename = filename
 write_schedulefile,filename,schedule,comment=comment

 ;Convert to lst schedule
 filename_lst = !HEXSKYROOT+'/schedulefiles/lstsched/NA_'+fileroot
 convert_utcschedule_to_lstschedule,filename,filename_lst,mission,reference_date,$
				     comment=comment

endfor


end
