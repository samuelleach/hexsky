function example_dipole_scan,day=day,lst=lst,azspeed=azspeed,$
                          elevation=elevation,totalTime=totalTime,$
                          finalAZ=finalAz,finalEl=finalEl
  
  ;AUTHOR: S. Leach
  ;PURPOSE: Return an example cmb_dipole command

  if n_elements(day) eq 0 then day = 17
  if n_elements(lst) eq 0 then lst = 14.
  if n_elements(azspeed) eq 0 then azspeed = 1.0 
  if n_elements(elevation) eq 0 then elevation = 60.0 
  if n_elements(totalTime) eq 0 then totalTime = 16200.0 
  if n_elements(finalAz) eq 0 then finalAz = 0.
  if n_elements(finalEl) eq 0 then finalEl = 30.

  command      = {command}
  command.name = 'cmb_dipole'
  format       = command_format(command.name,nparameters=nparameters)
  command.nparameters = nparameters

  myday = day
  mylst = lst
  if lst gt 24. then begin
     mylst = lst - 24.
     myday = day + 1
  endif
  
  command.parameters[0] = myday
  command.parameters[1] = mylst
  command.parameters[2] = azspeed
  command.parameters[3] = elevation
  command.parameters[4] = totalTime
  command.parameters[5] = finalAz
  command.parameters[6] = finalEl

  return, command

end
