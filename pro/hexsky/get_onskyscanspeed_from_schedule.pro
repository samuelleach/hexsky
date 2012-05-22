function get_onskyscanspeed_from_schedule,schedule,elevation

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns the on-sky scan speed of each command in a schedule struct.
  
  onskyscanspeed_deg = make_array(schedule.ncommands,value=0.0d0)
  azspeed_deg        = get_azspeed_from_schedule(schedule)

  for cc=0,n_elements(azspeed_deg)-1 do begin    
      onskyscanspeed_deg[cc] = azspeed_deg[cc]*cos(elevation[cc]*!dtor)
  endfor

  return, onskyscanspeed_deg

end
