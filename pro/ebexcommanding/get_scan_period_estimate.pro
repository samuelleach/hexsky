FUNCTION get_scan_period_estimate,command,mission,$
                                  time_to_next_elevationstep=time_to_next_elevationstep

  ;AUTHOR: S. Leach
  ;PURPOSE: Get an estimate of the scan period for EBEX commands.
  
  period = 0.
  format           = command_format(command.name,$
                                    syntax=syntax,$
                                    numelestep_index=numelestep_index,$
                                    azthrow_index=azthrow_index,$
                                    azspeed_index=azspeed_index)


  if azspeed_index eq -1 then begin
    message,'Command '+command.name+' not supported.',/continue
    return,period
  endif
    
  if azthrow_index eq -1 then begin
    message,'Command '+command.name+' not supported.',/continue
    return,period
  endif
    
  commandlist = get_command_list()
  if total(strmatch(commandlist,command.name)) gt 0 then begin
     azthrow = command.parameters[azthrow_index]
     azspeed = command.parameters[azspeed_index]
  endif else begin
     message,'Command '+command.name+' not supported.',/continue
  endelse

;  azaccel = mission.maxaccel_deg
;  period  = 2.*(azthrow/azspeed + 2.*azspeed/azaccel + $
;                mission.starcamstop_sec)
  period  = ebex_scan_period(azthrow,azspeed,mission.maxaccel_deg,mission.starcamstop_sec)

  time_to_next_elevationstep = command.parameters[numelestep_index]*period +$
                               mission.trepointing_sec

  return, period

end
