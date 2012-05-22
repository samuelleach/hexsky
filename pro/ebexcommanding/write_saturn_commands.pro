PRO WRITE_SATURN_COMMANDS,reference_date,mission

 ; Author: C.Bao
 ; Purpose: Automatically generates
 ; Saturn commands from May 15th to May 26th 2009 for NA flight

;Reference date
year   = reference_date[0]
month  = reference_date[1]
day    = reference_date[2]

lat = mission.latitude_deg ;34.467
lon = mission.longitude_start_deg ;-104.233

;Scanning parameters
nelevationsteps    = 90  
scanspeed          = 1.  ; deg/s
scanwidth          = 7.  ; deg
numstarcam         = 5
totalscantime      = 1.0 ; hours
nscan_per_risefall = 3
elevation_step     = [5.,4.,3.,-3,-4,-5]

asc_read,!HEXSKYROOT+'/schedulefiles/na_rise_set.txt',day_num,sun_rise,sun_set,moon_rise,moon_set,$
	  saturn_r_20,saturn_r_60,saturn_s_60,saturn_s_20,jupiter_r_20,jupiter_s_20,dark_night,$
	  sl=8,nel=23,comment_symbol='#',outcomment = comment

focalplane = get_na_wafer([150,250,410])
get_focalplane_average_azel,focalplane,xoff,yoff
tz = calc_tz(lon,DST='ON')

; Loop over days in May
for dd = 15, 25 do begin
  mission.day       = dd
  mission.month     = month
  schedule          = {schedule}
  schedule.year     = year
  schedule.month    = month
  schedule.day      = day
  schedule.hour_utc = 6.0
 
  schedule.ncommands = nscan_per_risefall * 2

  for cc = 0,2 do begin
    schedule.command[cc] = {command}
    schedule.command[cc].name = 'calibrator_scan'
    schedule.command[cc].nparameters = 9
    schedule.command[cc].comment = 'Saturn'
    schedule.command[cc].time_to_next_command = 24.
    schedule.command[cc].expected_duration = 25.
    schedule.command[cc].parameters[0] = dd
    schedule.command[cc].parameters[1] = saturn_r_60[dd-10]-$
	      4./5.*(saturn_r_60[dd-10]-saturn_r_20[dd-10]-$
		     nscan_per_risefall*totalscantime)-$
	      totalscantime*float(3-cc)

    juldate,[year,month,schedule.day,schedule.command[cc].parameters[1]],jd
    jd = double(jd - tz/24.) + 2400000d
    
    planet_coords,jd,saturn_ra,saturn_dec,planet = 'SATURN',/JD

    aim_the_boresight,saturn_ra,saturn_dec,jd,lon,lat,xoff,yoff,ra_bs,dec_bs

    schedule.command[cc].parameters[2]   = ra_bs/15.
    schedule.command[cc].parameters[3]   = dec_bs
    schedule.command[cc].parameters[4:5] = [scanspeed,scanwidth]
    schedule.command[cc].parameters[6]   = elevation_step[cc] ;5-j  ;Elevation steps
    schedule.command[cc].parameters[7:8] = [nelevationsteps,numstarcam]
 endfor

  for cc=3,5 do begin
    schedule.command[cc] = {command}
    schedule.command[cc].name = 'calibrator_scan'
    schedule.command[cc].nparameters = 9
    schedule.command[cc].comment = 'Saturn'
    schedule.command[cc].time_to_next_command = 24.
    schedule.command[cc].expected_duration = 25.
    schedule.command[cc].parameters[0] = dd
    schedule.command[cc].parameters[1] = saturn_s_20[dd+1-10]-$
	      (saturn_s_20[dd-10]+24-saturn_s_60[dd-10]-$
	       nscan_per_risefall*totalscantime)/2.0+$
	      24-totalscantime*float(6-cc)
    juldate,[year,month,schedule.day,schedule.command[cc].parameters[1]],jd

 
    if schedule.command[cc].parameters[1] ge 24 then begin
      schedule.command[cc].parameters[0] = dd + 1
      schedule.command[cc].parameters[1] = schedule.command[cc].parameters[1] mod 24
      juldate,[year,month,schedule.day+1,schedule.command[cc].parameters[1]],jd
    endif

    jd = double(jd - tz/24.) + 2400000d
    
    planet_coords,jd,saturn_ra,saturn_dec,planet = 'SATURN',/JD

    aim_the_boresight,saturn_ra,saturn_dec,jd,lon,lat,xoff,yoff,ra_bs,dec_bs

    schedule.command[cc].parameters[2]   = ra_bs/15.
    schedule.command[cc].parameters[3]   = dec_bs
    schedule.command[cc].parameters[4:5] = [scanspeed,scanwidth]
    schedule.command[cc].parameters[6]   = elevation_step[cc]
    schedule.command[cc].parameters[7:8] = [nelevationsteps,numstarcam]
 endfor

 ; Update the times to the next command in the schedule
 schedule_update_time_to_next_command,schedule


 ; Check duration of commands without full simulation of pointing.
 print,' '
 print, 'Checking expected command duration for '+themonths(month)+' '+strtrim(string(schedule.day+dd-1),2)
 print,' '
 simulate_pointing,schedule,mission,/no_pointing

 ;Make a comment for the schedule file
 nc        = schedule.ncommands
 jd        = get_jd_from_schedule(schedule)
 starttime = jd2dateandtime(jd[0]) 
 jd_end    = jd[nc-1] + schedule.command[nc-1].expected_duration/24.
 endtime   = jd2dateandtime(jd_end)
 comment   = 'Schedule starts on '+starttime+' and ends on '+endtime
 
 ;Write to disk
 month_string = strlowcase(themonths(month))
 fileroot = 'saturn_'+month_string+strtrim(string(schedule.day+dd-1),2)+'.sch'
 filename = !HEXSKYROOT+'/schedulefiles/'+fileroot
 schedule.filename = filename
 write_schedulefile,filename,schedule,comment=comment


 ;Convert to lst schedule
 filename_lst = !HEXSKYROOT+'/schedulefiles/lstsched/NA_'+fileroot
 convert_utcschedule_to_lstschedule,filename,filename_lst,mission,reference_date,$
				     comment=comment
 
 
endfor



END
