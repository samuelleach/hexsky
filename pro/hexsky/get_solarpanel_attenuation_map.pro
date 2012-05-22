function get_solarpanel_attenuation_map,jd0,duration_hr,lon,lat,$
                                        nside=nside,panel_el_deg=panel_el_deg,$
                                        panel_az_offset_deg=panel_az_offset_deg
  ;AUTHOR: S. Leach
  ;PURPOSE: Calculate the cosine of the sun incidence angle on an inclined
  ;         panel averaged over a period of time.

  if n_elements(nside) eq 0                then nside = 32
  if n_elements(panel_el_deg) eq 0         then panel_el_deg = 23.5
  if n_elements(panel_az_offset_deg) eq 0  then panel_az_offset_deg = 180.

  amap = make_array(nside2npix(nside),value=0d0)

  nstep = 40
  jd    = jd0 + findgen(nstep)/float(nstep-1)*duration_hr/24. 
  
  for tt = 0L, nstep -1L do begin
     map = get_cossuninc_map(nside,jd[tt],lon,lat,panel_el_deg,panel_az_offset_deg,$
                            sun_az_deg=sun_az_deg)
     index = where(map lt 0.)
     if index[0] ne -1 then map[index] = 0.

     ;Check that the Sun is above the horizon
     if (sun_az_deg gt 0.) then amap = amap + map
  endfor
  
  amap = amap/ float(nstep)
  return,amap

end

pro test_get_solarpanel_attenuation_map


  jd            = systime(/julian)+ 45 + 365 +0.5
  duration_hour = 12.
  lon           = 70.
  lat           = -27.8
  panel_el_deg  = 23.5

  amap = get_solarpanel_attenuation_map(jd,duration_hour,lon,lat,panel_el_deg=panel_el_deg,nside=64)

  mollview,amap,grat=[30,30],outline=outline_galacticplane(),coord=['C','C']

end
