pro plot_ldb_visibility

  ;AUTHOR: S. Leach
  ;PURPOSE: Example of plotting an "visibility map".

  year   = 2011
  month  = 12
  day    = 31
  hour   = 0
  minute = 0
  
  lat_deg = [-68.867,-71.867,-74.867,-77.867, -80.867,-83.867,-86.867]
  lon_deg = 166.66
  
  minel = 30.
  maxel = 60
  maxel = 57
  
  juldate,[year,month,day,hour,minute,0],jd
  jd = jd + 2400000d
  
  outline = [outline_target('carina_nebula',2),outline_target('rcw38',2)]
  
  
  units    = 'hours/day'
  gp       = outline_galacticplane()
  gc       = outline_circle(266.43,-29.0,6.) ; Galactic centre
  schedule = read_schedulefile(!HEXSKYROOT+'/schedulefiles/cmb_example_0.4.sch')
  mission  = read_parameterfile(!HEXSKYROOT+'/missionfiles/ldb_mission.par')
  sched    = outline_schedule(schedule,mission)

  for ll = 0, n_elements(lat_deg)-1L do begin
     map                   = get_visibilitymap(jd,24.,lon_deg,lat_deg[ll],minel=minel,maxel=maxel,nside=32)
     map(where(map eq 0.)) = !healpix.bad_value
     
     mollview,map,units=units,title = 'Sky visibility from Antarctica, January 2011',grat=[30,15],$
              outline=[OUTLINE,gp,gc,sched],coord=['C','C'],glsize=1.15,char=1.1,png='ldb_visibility_maxel'+$
              number_formatter(maxel,dec=0)+'_lat'+number_formatter(lat_deg[ll],dec=1)+'.png',$
              rot=[100,0],subtitle='Lon, Lat [deg] = ['+number_formatter(lon_deg,dec=1)+', '+$
              number_formatter(lat_deg[ll],dec=1)+'], max el [deg] = '+number_formatter(maxel,dec=0),$
              window=1
  endfor

end
