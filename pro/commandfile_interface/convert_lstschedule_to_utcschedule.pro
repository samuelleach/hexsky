pro convert_lstschedule_to_utcschedule,schedulefile_in,schedulefile_out,missionfile,$
                                       gst_reference_date=gst_reference_date,comment=comment

  ;AUTHOR: S. Leach
  ;PURPOSE: Convert a LST style schedule file into an UTC
  ;         style schedule file (for simulating).
  ;         gst_reference_date is an array containing three integers [year,month,day]

  if n_elements(gst_reference_date) eq 0 then begin
     reference          = get_referencedate_from_schedule(schedulefile_in)
     gst_reference_date = reference[0:2]
  endif
  
  ;Read in the schedule and mission
  lstschedule = read_schedulefile(schedulefile_in)
  mission     = read_parameterfile(missionfile)
  
  ;Copy the schedule to a new structure
  utcschedule          = lstschedule
  utcschedule.filename = ''
  
  ;Get the JD and lon/lat of the commands
  jd     = get_jd_from_lstschedule(lstschedule,mission,lon=lon,lat=lat)

  ;Get the JD of the new reference time
  year   = gst_reference_date[0]
  month  = gst_reference_date[1]
  day    = gst_reference_date[2]

  ; Update the reference time and date in the LST schedule 
  utcschedule.year     = year
  utcschedule.month    = month
  utcschedule.day      = day
  utcschedule.hour_utc = 0.    ; Midnight UTC
  
  ; Get the reference JD
  jdcnv,utcschedule.year,utcschedule.month,utcschedule.day,utcschedule.hour_utc,JD_ref   

  ; Get the UTC day and UTC hour of each command
  utc_hr  = make_array(n_elements(jd),value=0d)
  utc_day = make_array(n_elements(jd),value=0d)
  for cc = 0L, n_elements(jd) -1L do begin
     day         = floor(jd[cc] - jd_ref) + 1
     hr          = ((jd[cc] - jd_ref)  - floor(jd[cc]-jd_ref))*24d0
;     hr          = sigfig(hr,6) ; Buggy when using six sig figs. eg IDL> print,sigfig(14.071069,6)
     if(hr eq 24.) then begin
        hr  = 0.
        day = day + 1
     endif
     utc_day[cc] = day
     utc_hr[cc]  = hr
  endfor
  
  for cc = 0L,utcschedule.ncommands -1L  do begin
     utcschedule.command[cc].parameters[0] = utc_day[cc]
     utcschedule.command[cc].parameters[1] = utc_hr[cc]

;     commandcomment = strtrim(day,2)+' '+themonths(month,/abbrev)+$
;                      ' '+strtrim(year,2)+' '+decimalhour2clocktime(hour)+' UTC'
;     
     utcschedule.command[cc].comment = ''
  endfor

  ;Uncomment /stop_commands to have stop commands in between each command.
  write_schedulefile,schedulefile_out,utcschedule;,comment=comment;,/stop_commands


end
