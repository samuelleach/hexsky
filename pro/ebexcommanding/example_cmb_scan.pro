function example_cmb_scan,ra_deg=ra_deg,dec_deg=dec_deg,day=day,lst=lst,azspeed=azspeed,$
                          azwidth=azwidth,targetdecrange=targetdecrange,$
                          numelevationstep=numelevationstep,numthrowplusone=numthrowplusone

  ;AUTHOR: S. Leach
  ;PURPOSE: Return an example cmb_scan command

  if n_elements(ra_deg) eq 0 then ra_deg = 62.
  if n_elements(dec_deg) eq 0 then dec_deg = 17
  if n_elements(day) eq 0 then day = 17
  if n_elements(lst) eq 0 then lst = 14.
  if n_elements(azspeed) eq 0 then azspeed = 0.4 
  if n_elements(azwidth) eq 0 then azwidth = 30.0 
  if n_elements(targetdecrange) eq 0 then targetdecrange = 10.0 
  if n_elements(numelevationstep) eq 0 then numelevationstep = 111 
  if n_elements(numthrowplusone) eq 0 then numthrowplusone = 3

  command      = {command}
  command.name = 'cmb_scan'
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
  command.parameters[2] = ra_deg/15.
  command.parameters[3] = dec_deg
  command.parameters[4] = azspeed
  command.parameters[5] = azwidth
  command.parameters[6] = targetdecrange
  command.parameters[7] = numelevationstep
  command.parameters[8] = numthrowplusone

  return, command

end
