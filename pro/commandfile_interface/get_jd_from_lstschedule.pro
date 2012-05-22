function get_jd_from_lstschedule,schedule,mission,lon=lon,lat=lat

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns the Julian day of each command in a LST style schedule struct,
  ;         given information about the launch date and orbit 
  ;         speed in a mission struct.

  dLST_ref     = make_array(schedule.ncommands,value=0.0d0)
  dLST_launch  = make_array(schedule.ncommands,value=0.0d0)
  JD           = make_array(schedule.ncommands,value=0.0d0)
  dLON         = make_array(schedule.ncommands,value=0.0d0)

  ;Get the JD of the reference time (first line of schedule file)
  jdcnv,schedule.year,schedule.month,schedule.day,schedule.hour_utc,jd_ref
;  print,'JD_ref    = ',jd_ref,' ',jd2dateandtime(jd_ref)

  ;Get the JD of the launch
  jdcnv,mission.year,mission.month,mission.day,mission.launch_utc,jd_launch
;  print,'JD_launch = ',jd_launch,' ',jd2dateandtime(jd_launch)
;  print,'JD_launch - JD_ref = ',jd_launch-jd_ref

  ;Get the LST of the reference time
;  jd2lst,jd_ref,mission.longitude_start_deg,LST_ref
;  print, 'LST_ref [hr]   = ',LST_ref
;  print, 'Lon_start [hr] = ',mission.longitude_start_deg/15d0

  ;Get the LST of the launch
  jd2lst,jd_launch,mission.longitude_start_deg,LST_launch
;  print, 'LST_launch = ',LST_launch

  ;Get the schedule day of the launch 
  scheduleday_launch = floor((JD_launch - jd_ref)*1.002737909d0 + mission.longitude_start_deg/360d0)
;  print,'Day of launch in LST schedule file = ',scheduleday_launch

  dlstlaunch_ref = lst_launch + 24d0 * scheduleday_launch
;  print, 'dLSTlaunch_ref = ',dLSTlaunch_ref
  
  ;Check that the LST = 0 at the reference time and launch location.
  ;Get the sidereal time of the reference time (supposed to be GST=0 by convention).
  LST_ref = mission.longitude_start_deg/15d0

  ;Get the dLST (total number of LST hours) since the reference time.
  for cc = 0L,n_elements(dLST_ref)-1L do begin    
     dLST_ref[cc] =  (schedule.command[cc].parameters[0])*24d0 + $ ; DAY
                     schedule.command[cc].parameters[1]           -      $
                     LST_ref
  endfor

  ;Get the amount of LST since the launch
  dlst_launch = dlst_ref - dlstlaunch_ref + mission.longitude_start_deg/15d0
;  print,'dLST_LAUNCH'
;  print,dlst_launch

  ;Get the amount of longitude coverered since the launch
  dlon_launch = dlst_launch/(1d0 + 24.06570982441908d0/(mission.orbitspeed*24.)) * 15.
;  print,dlst_launch
  lon         = mission.longitude_start_deg + dlon_launch
;  lon         = modpos(lon, wrap=360.)
;  print,'LON'
;  print,lon

  ;Get the JD of each command
  gondola_in_motion = 0
  if(mission.orbitspeed ne 0.) then begin
      gondola_in_motion = 1
  endif
      
  for cc = 0L,n_elements(JD)-1L do begin    
     if (gondola_in_motion) then begin
          ; Use the gondola longitude as measure of JD (recall orbit speed
          ; is measured in orbits per JD).
;        day     = dlon_launch[cc]/mission.orbitspeed/360. + $
;                  schedule.day + schedule.command[0].parameters[0] + 1.
;        hour    = (day-floor(day))*24d0
;        jdcnv, schedule.year,schedule.month,day,hour,myjd

        myjd = jd_launch + dlon_launch[cc]/mission.orbitspeed/360.
     endif else begin
          ; Calculate the JD from the LST and LON
;        lst      = lst_launch + dlst_launch[cc]
;        day      = ceil( dlst_launch[cc] / 24d0 / 1.002737909d0) + $
;                   schedule.day + schedule.command[0].parameters[0]
;        utc_hour = lst2ct( lst mod 24., lon[cc], 0, day, schedule.month, schedule.year)
;        jdcnv, schedule.year,schedule.month,day,utc_hour,myjd

        myjd = jd_launch + dlst_launch[cc]/ 24d0/ 1.002737909d0
     endelse
     jd[cc] = myjd
  endfor

  return, jd

end
