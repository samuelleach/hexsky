pro convert_utcschedule_to_lstschedule,schedulefile_in,schedulefile_out,$
					mission,gst_reference_date,$
					comment=comment
  ;AUTHOR: S. Leach
  ;PURPOSE: Convert a UTC style schedule file into an EBEX "LST"
  ;         style schedule file.
  ;        gst_reference_date is an array containing three integers [year,month,day]

  
  ;Read in the schedule
  utcschedule = read_schedulefile(schedulefile_in)
  
  ;Copy the schedule to a new structure
  lstschedule          = utcschedule
  lstschedule.filename = ''
  
  ;Get the JD of the commands
  jd          = get_jd_from_utcschedule(utcschedule)

  ;Get the longitude and latitude of the gondola (depends on the orbit
  ;speed contained in the missionfile).
  get_earthpos_from_utcschedule, utcschedule,mission,lon,lat

  ;Get the JD of the new reference time
  year   = gst_reference_date[0]
  month  = gst_reference_date[1]
  day    = gst_reference_date[2]
  string = get_lstschedulefile_firstline(day,month,year,jd_ref=jd_ref,hour_utc=hour_utc)

  ;Update the reference time and date in the LST schedule 
  lstschedule.year     = year
  lstschedule.month    = month
  lstschedule.day      = day
  lstschedule.hour_utc = hour_utc
  
;  LST_HR  = (jd-jd_ref)*24.*1.002737909 + lon*24./360.
;  lst_hr  = lst_hr mod 24.
;  print,'LST hour old2',lst_hr

  lst_hr = make_array(n_elements(lon),value=0d)
  for cc = 0L, n_elements(lon) -1L do begin
     ct2lst,lst,lon[cc],dummy,jd[cc]
     lst_hr[cc] = lst
  endfor
  
  ;Get LST day of command relative to new reference UTC
  LST_DAY = floor((jd-jd_ref)*1.002737909d0 + lon/360d0)
  
  for cc = 0L,lstschedule.ncommands - 1L  do begin
     lstschedule.command[cc].parameters[0] = lst_day[cc]
     lstschedule.command[cc].parameters[1] = lst_hr[cc]
     
     daycnv,jd[cc],year,month,day,hour
     
     commandcomment = strtrim(day,2)+' '+themonths(month,/abbrev)+$
                      ' '+strtrim(year,2)+' '+decimalhour2clocktime(hour)+' UTC'
     
     lstschedule.command[cc].comment = lstschedule.command[cc].comment+$
                                       '; '+commandcomment
  endfor

  ;Uncomment /stop_commands to have stop commands in between each command.
  write_schedulefile,schedulefile_out,lstschedule,comment=comment;,/stop_commands


end
