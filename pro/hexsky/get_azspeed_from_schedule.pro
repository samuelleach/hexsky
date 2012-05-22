function get_azspeed_from_schedule,schedule

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns the azimuth speed of each command in a schedule struct.
  
  azspeed_deg = make_array(schedule.ncommands,value=0.0d0)

  for cc = 0 , n_elements(azspeed_deg)-1 do begin    
      cmd_format = command_format(schedule.command[cc].name,azspeed_index=azspeed_index)
      if azspeed_index ne -1 then begin
          azspeed_deg[cc] = float(schedule.command[cc].parameters[azspeed_index])
      endif else begin
          azspeed_deg[cc] = 0.
      endelse
  endfor

  return, azspeed_deg

end
