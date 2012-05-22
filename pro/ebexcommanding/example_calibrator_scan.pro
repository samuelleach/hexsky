function example_calibrator_scan,calibrator=calibrator,day=day,lst=lst,azspeed=azspeed,$
                                 azwidth=azwidth,elevationstep=elevationstep,$
                                 numelevationstep=numelevationstep,numthrowplusone=numthrowplusone

  ;AUTHOR: S. Leach
  ;PURPOSE: Return an example calibrator_scan command.

  if n_elements(calibrator) eq 0 then calibrator = 'rcw38'
  if n_elements(day) eq 0 then day = 17
  if n_elements(lst) eq 0 then lst = 14.
  if n_elements(azspeed) eq 0 then azspeed = 0.8 
  if n_elements(azwidth) eq 0 then azwidth = 13.0 
  if n_elements(elevationstep) eq 0 then elevationstep = 3.0
  if n_elements(numelevationstep) eq 0 then numelevationstep = 111 
  if n_elements(numthrowplusone) eq 0 then numthrowplusone = 3

  
  coord = target(calibrator)
  RA    = coord[0]/15.
  Dec   = coord[1]

  command             = {command} 
  command.name        = 'calibrator_scan'
  format              = command_format(command.name,nparameters=nparameters)
  command.nparameters = nparameters
  
  command.parameters[0] = day
  command.parameters[1] = lst
  command.parameters[2] = Ra
  command.parameters[3] = Dec
  command.parameters[4] = azspeed
  command.parameters[5] = azwidth
  command.parameters[6] = elevationstep
  command.parameters[7] = numelevationstep
  command.parameters[8] = numthrowplusone

;  command.expected_duration

  return, command

end
