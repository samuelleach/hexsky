pro hexsky_test_driver,schedulefile=schedulefile,missionfile=missionfile,$
                       outputdir=outputdir,$
                       skipdetectors=skipdetectors,boresight=boresight,$
                       detectorpair=detectorpair,$
                       get_conditionnumber=get_conditionnumber,$
                       without_pendulations=without_pendulations,$
                       channel=channel,focalplane_phi0_deg=focalplane_phi0_deg,$
                       nside_hitmap=nside_hitmap,$
                       lstschedule=lstschedule,$
                       hits_per_sample=hits_per_sample, warning_file=warning_file,$
                       documentation=documentation,simulate_pointing=simulate_pointing,$
                       first_command=first_command,last_command=last_command,$
                       plot_level=plot_level,rot_ang_plot=rot_ang_plot
  

  ;AUTHOR: S. Leach
  ;PURPOSE: This is the main driver routine for end-to-end 
  ;         simulation and documentation of a UTC or LST schedule file.

  starttime = systime(/julian)

;;------------------------------------------------------------------
;; Prototype driver for simulating the pointing from a schedule file
;;------------------------------------------------------------------  
  if n_elements(outputdir)           eq 0 then outputdir           = './output'
  if n_elements(skipdetectors)       eq 0 then skipdetectors       = 1
  if n_elements(get_conditionnumber) eq 0 then get_conditionnumber = 0
  if n_elements(focalplane_phi0_deg) eq 0 then focalplane_phi0_deg = 0.
  if n_elements(nside_hitmap)        eq 0 then nside_hitmap        = 512
  if n_elements(hits_per_sample)     eq 0 then hits_per_sample     = 1.
  if n_elements(warning_file)        eq 0 then warning_file        = 'WARNINGS_readme'
  if n_elements(documentation)       eq 0 then documentation       = 1
  if n_elements(simulate_pointing)   eq 0 then simulate_pointing   = 1
  if n_elements(first_command)       eq 0 then first_command       = 1
  if n_elements(last_command)        eq 0 then last_command        = -1
  if n_elements(plot_level)          eq 0 then plot_level          = 1
  if n_elements(simulate_pointing)   eq 0 then simulate_pointing   = 1
  if n_elements(rot_ang_plot)        eq 0 then rot_ang_plot        = [82.5,-44.5]

  spawn,'mkdir -p '+ outputdir

  if simulate_pointing eq 1 then spawn,'rm -rf '+ outputdir+'/'+warning_file

  ;;---------------------------------------------------------
  ;; Mission file contains information a mission location and
  ;; experiment details:
  ;;---------------------------------------------------------
  if n_elements(missionfile) eq 0 then missionfile = !HEXSKYROOT+'/missionfiles/ldb_mission.par'

  ;;--------------------------------------
  ;; Schedule file contains EBEX commands:
  ;;--------------------------------------
  if n_elements(schedulefile) eq 0 then schedulefile = !HEXSKYROOT+'/schedulefiles/cmb_example_0.4.sch'

  ;;----------------------------
  ;; Convert LST schedule to UTC 
  ;;----------------------------
  if keyword_set(lstschedule) then begin
     utcschedulefile = outputdir+'/'+fsc_base_filename(schedulefile)+'_utc.sch'
     convert_lstschedule_to_utcschedule,schedulefile,utcschedulefile,missionfile
     myschedulefile   = utcschedulefile
  endif else begin
     myschedulefile   = schedulefile
  endelse
    
  ;;---------------
  ;; Read in files:
  ;;---------------
  schedule     = read_schedulefile(myschedulefile)
  mission      = read_parameterfile(missionfile)

  ;;---------------------------
  ;; Get focalplane information
  ;;---------------------------
;  focalplanefile = !HEXSKYROOT+'/data/ebex_fpdb.txt'
  focalplanefile = !HEXSKYROOT+'/data/ebex_fpdb_v3.txt'
  focalplane = read_focalplanefile(focalplanefile,phi0_deg=focalplane_phi0_deg,outputdir=outputdir)
  if n_elements(channel) gt 0 then begin
     if ((channel ne 150) xor (channel ne 250) xor (channel ne 410)) then begin
        message,'Error: must set channel = 150 or 250 or 410'
     endif  
     subdir = strtrim(channel,2)
     focalplane[where(focalplane.channel ne channel)].power = 0
  endif

;  subset of detectors:
;  focalplane = get_na_wafer(150)
;  focalplane = get_na_wafer([150,250,410])

  if keyword_set(boresight) then begin
     focalplane = get_boresight()
     subdir     = 'boresight'
  endif 
  if keyword_set(detectorpair) then begin
     focalplane = get_detectorpair()
     subdir     = 'detectorpair' 
  endif

  ;;--------------------------------------
  ;; Simulate the pointing of the mission:
  ;;--------------------------------------
  pointing_dirfilename = outputdir+'/dirfile'
  if simulate_pointing then begin
     if keyword_set(without_pendulations) then begin
        simulate_pointing,  schedule, mission,/without_pendulations,$
                            outputdir=outputdir,warning_file=warning_file,$
                            first_command=first_command,last_command=last_command
     endif else begin
        simulate_pointing,  schedule, mission, outputdir=outputdir,warning_file=warning_file,$
                            first_command=first_command,last_command=last_command
     endelse
  endif else begin
     asc_read,outputdir+'/command_firstsample.dat',first_sample_index,nsample
     nc = n_elements(first_sample_index)
     schedule.command[0:nc-1].first_sample_index = first_sample_index
     schedule.command[0:nc-1].nsample            = nsample
  endelse

  ;;----------------------------------------------------------------------
  ;; Simulate and visualise Healpix hitmap and dustmap, command by command
  ;;----------------------------------------------------------------------
  if documentation then begin
     get_scanning_strategy_documentation,pointing_dirfilename,schedule,$
                                         focalplane,missionfile,skipdetectors=skipdetectors,$
                                         get_conditionnumber=get_conditionnumber,$
                                         outputdir=outputdir,nside_hitmap=nside_hitmap,$
                                         hits_per_sample=hits_per_sample,warning_file=warning_file,$
                                         plot_level=plot_level,subdir=subdir,$
                                         rot_ang_plot=rot_ang_plot
  endif

;  ;;-----------------------------------------------------
;  ;; Estimate signal to noise of power spectrum estimates
;  ;;-----------------------------------------------------
;  clfile              = !HEXSKYROOT+'/data/cl_WMAP-5yr_r0.05_lens.fits'
;  integrationtimefile = outputdir+'/tint_'+fsc_base_filename(schedule.filename)+'.fits'
;;  time_per_sample = mission.tsamp_sec
;;;  NET = (193.33, 398.67, 3077.30) thermodynamic uK sqrt(Hz)
;  NET         = 193.33
;  NEQ         = sqrt(2.)*NET
;  fwhm_arcmin = 8.
;;;  estimate_pse_s_over_n,clfile,integrationtimefile,time_per_sample,NET,NEQ,fwhm_arcmin
;

  endtime = systime(/julian)
  runtime = (endtime-starttime)*24.*60.
  message,'FINISHED SIMULATING '+schedulefile,/continue
  message,'Run time [min] = '+number_formatter(runtime,dec=1),/continue

end
