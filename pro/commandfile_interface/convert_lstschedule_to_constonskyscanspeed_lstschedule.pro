pro convert_lstschedule_to_constonskyscanspeed_lstschedule,schedulefile_in,schedulefile_out,missionfile

  ;AUTHOR: S. Leach
  ;PURPOSE: Convert a LST style schedule file into a schedule
  ;         with constant on-sky scan speed:

  ; The transformation applied to the az speed and azthrow is the following:
  ;
  ; azspeed [deg/s] -> azspeed x cos(45)/cos(el)
  ; azthrow [deg]   -> azthrow x cos(45)/cos(el) 

  ;--------------------------------
  ;Read in the schedule and mission
  ;--------------------------------
  lstschedule = read_schedulefile(schedulefile_in)
  mission     = read_parameterfile(missionfile)
  
  ;------------------------------------
  ;Copy the schedule to a new structure
  ;------------------------------------
  lstschedule_new          = lstschedule
  lstschedule_new.filename = ''
  
  ;--------------------------
  ; Get elevation of commands
  ;--------------------------
  el     = get_elevation_from_lstschedule(lstschedule,mission,lon=lon,lat=lat)

  cosff  = cos(45.*!dtor)
  for cc = 0L,lstschedule_new.ncommands -1L  do begin
     case strlowcase(lstschedule_new.command[cc].name) of
        'cmb_scan': begin
           azspeed = lstschedule.command[cc].parameters[4]*cosff/cos(el[cc]*!dtor)
           azthrow = lstschedule.command[cc].parameters[5]*cosff/cos(el[cc]*!dtor)
           lstschedule_new.command[cc].parameters[4] = azspeed
           lstschedule_new.command[cc].parameters[5] = azthrow
        end
        'calibrator_scan': begin
           wait,0.0001
;           azspeed = lstschedule.command[cc].parameters[4]*cosff/cos(el[cc]*!dtor)
;           azthrow = lstschedule.command[cc].parameters[5]*cosff/cos(el[cc]*!dtor)
;           lstschedule_new.command[cc].parameters[4] = azspeed
;           lstschedule_new.command[cc].parameters[5] = azthrow
        end
        'cmb_dipole': begin
           wait,0.0001
        end
     endcase
  endfor

  write_schedulefile,schedulefile_out,lstschedule_new ;,comment=comment;,/stop_commands


end

pro test_convert_lstschedule_to_constonskyscanspeed_lstschedule

  inputschedule  = 'ldb_v0.5.sch'
  outputschedule = 'ldb_v0.5_const.sch'
  missionfile    = 'ldb_mission.par'

  convert_lstschedule_to_constonskyscanspeed_lstschedule,inputschedule,outputschedule,missionfile

end
