function get_elevation_from_lstschedule,schedule,mission,lon=lon,lat=lat

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns the elevation of each command in an LST schedule struct,
  ;         given information about the launch date and orbit 
  ;         speed in a mission struct.
  ;
  ;         Note that this elevation corresponds only approximately
  ;         to the elevation that will be set by the pointing code in fcp
  ;         and in the hexsky pointing code. This is because the elevation
  ;         chosen in fcp/hexsky takes into account the drift of the sky
  ;         that occurs during the command.

  az_command    = make_array(schedule.ncommands,value=0.0d0)
  el_command    = make_array(schedule.ncommands,value=0.0d0)

  lat = mission.latitude_deg
  for cc = 0L,n_elements(el_command)-1L do begin    
     case strlowcase(schedule.command[cc].name) of
        'cmb_scan': begin
           lst = schedule.command[cc].parameters[1]
           ra  = schedule.command[cc].parameters[2] * 15.
           dec = schedule.command[cc].parameters[3]
        
           radeclst2azel,ra,dec,lst,lat,az,el

           el_command[cc] = el
           az_command[cc] = az
        end
        'calibrator_scan': begin
           lst = schedule.command[cc].parameters[1]
           ra  = schedule.command[cc].parameters[2] * 15.
           dec = schedule.command[cc].parameters[3]
        
           radeclst2azel,ra,dec,lst,lat,az,el

           el_command[cc] = el
           az_command[cc] = az
        end
        'cmb_dipole': begin
           el_command[cc] = schedule.command[cc].parameters[3]          
        end
     endcase
  endfor

  return, el_command

end
