pro strategy_example

  ;AUTHOR: S. Leach
  ;PURPOSE: Demonstrate the simulation of an EBEX scanning strategy.
  ;         Schedule files are produced with the suggest_scanning_strategy
  ;         code on the basis of parameters stored in a 'strategy file'.

  skip    = 4              ; Simulate 1 in skip detectors in the focal plane.
  hits    = 2.*skip        ; Number of hits per sample.
  channel = [150,250,410]  ; Channels to simulate.
  make_channel_maps = 0
  

  ;---------------------
  ; Select strategy file
  ;---------------------
;  strategyfile = !HEXSKYROOT+'/strategyfiles/'+$
;                 ['latplus7.ess','latnominal.ess','latminus7.ess','latminus7_raster.ess']
;  strategyfile = !HEXSKYROOT+'/strategyfiles/'+$
;                 ['latnominal','latplus7','latminus7','latminus7_raster']+'_v0.6.ess'
;  strategyfile = !HEXSKYROOT+'/strategyfiles/latnominal_v0.6_2day.ess'
  strategyfile = !HEXSKYROOT+'/strategyfiles/latnominal_v0.6.ess'
  

  ;--------------------------------------------------
  ; Loop over strategies:
  ; suggest_scanning_strategy produces schedule files
  ;--------------------------------------------------
  for ss = 0, n_elements(strategyfile) - 1 do begin
      ;---------------------------------------------
      ; Read in strategy file and make schedule file
      ;---------------------------------------------
      strategy     = read_parameterfile(strategyfile[ss])
;      suggest_scanning_strategy,strategy,/with_ascent_command
      suggest_scanning_strategy,strategy
  endfor

      
  ;----------------------------
  ; Simulate boresight pointing
  ;----------------------------
  for ss = 0, n_elements(strategyfile) - 1 do begin
      strategy     = read_parameterfile(strategyfile[ss])
      rot_ang_plot = [strategy.cmb_ra_hr1*15., strategy.cmb_dec_deg1]
      schedulefile = strategy.outputdir+'/'+strategy.schedulefile_out
      missionfile  = !HEXSKYROOT+'/missionfiles/'+strategy.missionfile  
      hexsky_test_driver,schedulefile=schedulefile,out=strategy.outputdir,$
        /lstsched,mission=missionfile,plot_level=1,/boresight,$
        /without_pendulations,rot_ang_plot=rot_ang_plot
  endfor

   ;------------------
   ; Make channel maps
   ;------------------
  if make_channel_maps eq 1 then begin
  for ss = 0, n_elements(strategyfile) - 1 do begin
    strategy     = read_parameterfile(strategyfile[ss])
    rot_ang_plot = [strategy.cmb_ra_hr1*15., strategy.cmb_dec_deg1]
    schedulefile = strategy.outputdir+'/'+strategy.schedulefile_out
    missionfile  = !HEXSKYROOT+'/missionfiles/'+strategy.missionfile  
    for cc = 0, n_elements(channel) - 1 do begin
      hexsky_test_driver,schedulefile=schedulefile,out=strategy.outputdir,$
			  /lstsched,mission=missionfile,plot_level=0,$
			  channel=channel[cc],skip=skip,hits=hits,focalplane_phi0_deg=60.,$
			  simulate_pointing=0,/without_pendulations,rot_ang_plot=rot_ang_plot
    endfor      
  endfor
  endif
  
end
