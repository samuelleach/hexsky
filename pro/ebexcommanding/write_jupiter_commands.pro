PRO write_jupiter_commands,reference_date,mission

  ;Reference date
  year   = reference_date[0]
  month  = reference_date[1]
  day    = reference_date[2]

  date   = [25,26,27,28,29,30,31,1,2,3,4,5]
  months = ['may','may','may','may','may','may','may',$
	  'june','june','june','june','june']
  lat = mission.latitude_deg ;34.467
  lon = mission.longitude_start_deg ;-104.233

  for ss = 0,n_elements(date)-1 do begin
    fileroot = 'jupiter_'+months[ss]+strtrim(date[ss],2)+'.sch'
    filename = !HEXSKYROOT+'/schedulefiles/'+fileroot
    schedule = read_schedulefile(filename)
  
    print, 'Checking expected command duration for '+themonths(month)+$
	   ' '+strtrim(string(schedule.day),2)
    print, ' '
    simulate_pointing,schedule,mission,/no_pointing
    
    ;Make a comment for the schedule file
    nc        = schedule.ncommands
    jd        = get_jd_from_schedule(schedule)
    starttime = jd2dateandtime(jd[0]) 
    jd_end    = jd[nc-1] + schedule.command[nc-1].expected_duration/24.
    endtime   = jd2dateandtime(jd_end)
    comment   = 'Schedule starts on '+starttime+' and ends on '+endtime
  
    ;Write to disk
;    month_string = strlowcase(themonths(month))
;    fileroot = 'saturn_'+month_string+strtrim(string(schedule.day+dd-1),2)+'.sch'
;    filename = !HEXSKYROOT+'/schedulefiles/'+fileroot
;    schedule.filename = filename
;    write_schedulefile,filename,schedule,comment=comment
    
    ;Convert to lst schedule
    filename_lst = !HEXSKYROOT+'/schedulefiles/lstsched/NA_'+fileroot
    convert_utcschedule_to_lstschedule,filename,filename_lst,mission,reference_date,$
				      comment=comment
 
 
endfor



END
