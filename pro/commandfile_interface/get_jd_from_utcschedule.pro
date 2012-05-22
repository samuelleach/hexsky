function get_jd_from_utcschedule,schedule,centralRA=centralRA,centralDec=CentralDec

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns the Julian day of each command in a UTC style schedule struct.
  ;         Optionally returns the central RA and Dec of the command,
  ;         in degrees.

  jd         = make_array(schedule.ncommands,value=0.0d0)
  centralRA  = make_array(schedule.ncommands,value=0.0d0)
  centralDec = make_array(schedule.ncommands,value=0.0d0)

  YR  = schedule.year
  MN  = schedule.month
  DAY = schedule.day
  HR  = schedule.hour_utc
  for cc = 0L,n_elements(jd)-1L do begin    
     JDCNV, YR, MN, $
            DAY + schedule.command[cc].parameters[0] - 1 ,$
            double(HR) + double(schedule.command[cc].parameters[1]),$
            JULIAN
     
     jd[cc] = julian

     centralRA[cc]  = schedule.command[cc].parameters[2]*15.
     centralDec[cc] = schedule.command[cc].parameters[3]
   
  endfor

  return, jd

end
