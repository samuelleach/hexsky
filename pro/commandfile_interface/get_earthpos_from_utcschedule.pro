pro get_earthpos_from_utcschedule,schedule,mission,lon,lat

  ;AUTHOR: S. Leach
  ;PURPOSE: Given (UTC) schedule and mission structs, this program
  ;         returns the earth position of the gondola in lon and lat.

  lon = make_array(schedule.ncommands,value=0.)
  lat = make_array(schedule.ncommands,value=0.)
  
  JDCNV, mission.year, mission.month, mission.day,mission.launch_utc,$
         jd_launch
  
  jd = get_jd_from_utcschedule(schedule)
  for cc = 0L,n_elements(lon) - 1L do begin
     lon_temp = get_gondola_longitude(mission.longitude_start_deg,jd_launch,jd[cc],$
                                      mission.orbitspeed)
;     lon[cc]  = modpos(lon_temp,wrap=180.,/zero_cent)
     lon[cc]  = lon_temp
     lat[cc]  = mission.latitude_deg    
  endfor


end
