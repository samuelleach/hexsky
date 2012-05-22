pro suggest_scanning_strategy,strategy,schedulefile=schedulefile_out,$
                              with_ascent_command=with_ascent_command

  ;AUTHOR: S. Leach
  ;PURPOSE: Sketch of software needed to auto-generate a scanning
  ;         strategy consisting of twice daily calibrator scans, with
  ;         cmb scans in between. The strategy parameter is the contents
  ;         of a .ess parameter file.


  missionfile               = !HEXSKYROOT+'/missionfiles/'+strategy.missionfile
  mission                   = read_parameterfile(missionfile)
  schedulefile_out          = strategy.outputdir+'/'+strategy.schedulefile_out
  schedulefile_adjusted_out = schedulefile_out
  nday                      = strategy.nday

  spawn,'mkdir -p '+strategy.outputdir

  ;-------------------------------------------------------------
  ; First, get the declination centres for the CMB scan commands
  ; during one sidereal day, and set up other parameters of the
  ; cmb scans
  ;-------------------------------------------------------------
  if strategy.adjust_dec_for_mosaic eq 1 then begin
     get_declination_centres,strategy.decmosaic_centraldec_deg,strategy.decmosaic_decrange_total_deg,$
                             strategy.decmosaic_nbrick,strategy.decmosaic_nlayer,$
                             brick_centraldec_deg,brick_decrange_deg,brick_layer,pointing_period_fraction
     n_cmbscan          = n_elements(brick_centraldec_deg)
  endif else begin
     n_cmbscan          = strategy.nscan_per_day_per_patch
  endelse
  cmb_scan_period_sec = strategy.cmb_chopperiod_sec1
  cmb_scan_throw_deg  = ebex_scan_throw(cmb_scan_period_sec,strategy.cmb_scanspeed_deg1,$
                                        mission.maxaccel_deg,mission.starcamstop_sec)
  cmb_ra_hr         = strategy.cmb_ra_hr1
  cmb_dec_deg       = strategy.cmb_dec_deg1

  print,'cmb scan period [sec] = ',cmb_scan_period_sec
  print,'cmb throw [deg]       = ',cmb_scan_throw_deg


  ;------------------------------------------------
  ; Next set up parameters of the calibrator scans.
  ; f_cal is the fraction of 24 sidereal hours per
  ;       observing cycle that is allocated to
  ;       calibrator scans.
  ; n_cal is hardwired to 2 calibrator scans per
  ;       day.
  ; elstep_arcmin is the elevation step used for
  ;        the calibrator scans.
  ;-----------------------------------------------
  calibrator_name = strategy.calname1
  f_cal           = strategy.fcal1
  n_cal           = 2 
  elstep_arcmin   = [3.,-3.] ; El step. Need to automate this.
  cal_scan_throw  = strategy.cal_throw_deg1
  cal_scan_period = ebex_scan_period(cal_scan_throw,strategy.cal_scanspeed_deg1*1.,$
                                     mission.maxaccel_deg,mission.starcamstop_sec)

  lst_cal     = make_array(n_cal,val=0.)
  lst_cmbscan = make_array(n_cmbscan,val=0.)

  ;--------------------------------------
  ;Get calibrator coordinates in RA / Dec
  ;--------------------------------------
  calibrator_coord = target(calibrator_name)
  calibrator_ra_hr = calibrator_coord[0]/15.
  
 
  ;-----------------------------------------------------------------
  ; Calculate the duration of the in hours of the calibrator and cmb 
  ; commands.
  ;-----------------------------------------------------------------
  t_cal_hr     = 24.* f_cal / float(n_cal)
  t_cmbscan_hr = 24 * (1. - f_cal) / float(n_cmbscan) 

  ;--------------------------------------------
  ; Fix the LST (hr) of the calibrator commands
  ; Recall that a source reaches its maximum elevation
  ; when LST = RA
  ;--------------------------------------------
  lst_cal[0] = calibrator_ra_hr - t_cal_hr/2. + 6. ; Calibrator scans timed for maximum cross-linking
  lst_cal[1] = calibrator_ra_hr - t_cal_hr/2. - 6.

;  lst_cal[0] = cmb_ra_hr - t_cal_hr/2. + 6.     ; Calibrator scans timed for maximum and minimum elevation of cmb patch
;  lst_cal[1] = cmb_ra_hr - t_cal_hr/2. - 6.
  

  ;--------------------------------------------------
  ; Fix the nominal LST (hr) of the CMB scan commands
  ; (to be adjusted later for unequal time commands)
  ; in between the two calibrator scans.
  ;--------------------------------------------------
  for ss = 0, n_cmbscan/2 -1 do begin    
     lst_cmbscan[ss]               = lst_cal[0] + t_cal_hr + t_cmbscan_hr * ss
     lst_cmbscan[n_cmbscan/2 + ss] = lst_cal[1] + t_cal_hr + t_cmbscan_hr * ss
  endfor
  
  ;--------------------------------------------------------
  ; Calculate the number of elevation steps for the cmb and
  ; calibrator scans, and estimate the target dec range for
  ; for cmb scan
  ;--------------------------------------------------------
  cmb_scan_numel     = floor(t_cmbscan_hr / ( (cmb_scan_period_sec + mission.trepointing_sec)/3600.) ) * $
                       (1. - strategy.expected_orbitspeed) 
  cmb_scan_targetdec = cmb_scan_numel * strategy.cmb_elevation_step_arcmin1/60.

  cal_scan_numel     = floor(t_cal_hr/((cal_scan_period + mission.trepointing_sec)/3600.)) * $
                       (1. - strategy.expected_orbitspeed) 


  mysched = example_schedule(year_ref=strategy.schedule_ref_year,$
                             month_ref=strategy.schedule_ref_month,$
                             day_ref=strategy.schedule_ref_day)
  ;---------------
  ; Loop over days
  ;---------------
  ref = strategy.first_day*1
  for dd = ref, ref + strategy.nday - 1 do begin 
     ;------------------------
     ; Get calibrator commands
     ;------------------------
     cal_command = make_array(n_cal,value={command})
     for cc = 0, n_cal - 1 do begin
        cal_command[cc] = example_calibrator_scan(calibrator=calibrator_name,day=dd,lst=lst_cal[cc],numel=cal_scan_numel,$
                                                  elevationstep=elstep_arcmin[cc],azwidth=cal_scan_throw,$
                                                  azspeed=strategy.cal_scanspeed_deg1)
     endfor
     ;-----------------------------------------------------------
     ; Get CMB commands. Assumes nominal patch centre RA and Dec.
     ;-----------------------------------------------------------
     cmb_command = make_array(n_cmbscan,value={command})
     for cc = 0, n_cmbscan - 1 do begin
        cmb_command[cc] = example_cmb_scan(ra_deg=cmb_ra_hr*15.,dec_deg=cmb_dec_deg,day=dd,lst=lst_cmbscan[cc],$
                                           numel=cmb_scan_numel,targetdec=cmb_scan_targetdec,azwidth=cmb_scan_throw_deg,$
                                           azspeed=strategy.cmb_scanspeed_deg1)
     endfor
     
     ;--------------------------------------
     ; Merge commands into a single schedule
     ;--------------------------------------
     ; Special case for first day: Drop the first calibrator
     ; from the schedule (to avoid excessive battery depletion)
     if dd eq ref then begin
        mysched = merge_commands_into_schedule(mysched,cal_command[0])
     endif else begin
        mysched = merge_commands_into_schedule(mysched,cal_command)
     endelse        
     mysched = merge_commands_into_schedule(mysched,cmb_command)
  endfor
  write_schedulefile,schedulefile_out,mysched

  ;--------------------------------------------------
  ; Add dipole scan to start of schedule file.
  ; This function was used during some simulations of
  ; battery depletion during the ascent to float.
  ;--------------------------------------------------
  ascent_shift = 0
  if (keyword_set(with_ascent_command)) then begin
      ascent_duration_hr = 4.5
      insert_ascent_command,mysched,mysched,ascent_duration_hr
      write_schedulefile,schedulefile_out,mysched
      ascent_shift = 1
  endif


  ;--------------------------------------
  ; Final production of scanning strategy
  ;--------------------------------------
  if strategy.adjust_dec_for_mosaic eq 1 then begin
     ;----------------------------------------------------------------------------
     ; Fix the declination of the cmb commands based on a 'mosaic' of declinations
     ; calculated with get_declination_centres above.
     ; 
     ; The elevations of commands (for cmb patch centre) are
     ; calculated and then new declinations of commands are assigned
     ; according the the principle that higher (less negative) declinations are scanned
     ; when the patch centre is at higher elevations. This is for
     ; the sake of sky accessibility, given the observing elevation constraints.
     ;----------------------------------------------------------------------------
      aa = ascent_shift ; (1 or 0)
      t_cmbscan_adjusted = 24. * (1. - f_cal) / total(pointing_period_fraction) 
      schedule_new       = read_schedulefile(schedulefile_out)
      ;---------------------------------------------------
      ; Get the initial elevation of the all the commands.
      ;---------------------------------------------------
      elevation          = get_elevation_from_lstschedule(schedule_new,mission)
      elevation_cmbscan  = [elevation[aa:(n_cmbscan/2 + aa-1)],elevation[(aa+1+n_cmbscan/2):(n_cmbscan+aa)]]
      index_elevation    = sort(elevation_cmbscan)
      index_declination  = sort(brick_centraldec_deg)
;     plot,elevation_cmbscan[index_elevation],psym=sym(3),xrange=[-1,n_cmbscan+1]
      cmbscan_index      = -1L
      nc = n_elements(elevation)
      for cc = 0,nc - 1  do begin
          if schedule_new.command[cc].name eq 'cmb_scan' then begin
              cmbscan_index                          = cmbscan_index + 1
              index                                  = cmbscan_index mod n_cmbscan
              ind1                                   = where(index_elevation eq index)
              ind2                                   = where(index_declination eq ind1[0])
              schedule_new.command[cc].parameters[3] = brick_centraldec_deg[ind2]             ; Dec
              schedule_new.command[cc].parameters[6] = brick_decrange_deg[ind2]               ; Decrange
              factor                                 = pointing_period_fraction[ind2]
              schedule_new.command[cc].parameters[7] = floor(schedule_new.command[cc].parameters[7]*factor*$
                                                             t_cmbscan_adjusted/t_cmbscan_hr) ; nelsteps
           
             ;-----------------------------------------------
             ; Adjust start time of the next cmb_scan command
             ;-----------------------------------------------
              lst_day0 = schedule_new.command[cc].parameters[0]
              lst_hr0  = schedule_new.command[cc].parameters[1]
              lst_day1 = schedule_new.command[cc+1].parameters[0]
              lst_hr1  = schedule_new.command[cc+1].parameters[1]
              
              lst_hr1_adjust  = lst_hr0 + t_cmbscan_adjusted*factor
              lst_day1_adjust = lst_day1
              
              if (schedule_new.command[cc+1].name eq 'cmb_scan') then begin              
                  schedule_new.command[cc+1].parameters[0] = lst_day1_adjust 
                  schedule_new.command[cc+1].parameters[1] = lst_hr1_adjust mod 24.
              endif
              
          endif
      endfor
      write_schedulefile,schedulefile_adjusted_out,schedule_new
  endif

  ;-----------------------------------------------------------------
  ; Adjust the scan speed depending on the elevation of the command:
  ;
  ;   azspeed [deg/s] -> azspeed x cos(45)/cos(el)
  ;   azthrow [deg]   -> azthrow x cos(45)/cos(el) 
  ; 
  ; The aim here is to produce a more homogeneous scanning.
  ;-----------------------------------------------------------------
  if strategy.adjust_scanspeed_for_elevation eq 1 then begin
      convert_lstschedule_to_constonskyscanspeed_lstschedule,$
        schedulefile_adjusted_out,schedulefile_adjusted_out,missionfile
  endif

  


end
