pro get_scanning_strategy_documentation,pointing_dirfilename,schedule,$
                                        focalplane,missionfile,$
                                        outputdir=outputdir,window=window,$
                                        skipdetectors=skipdetectors,$
                                        get_conditionnumber=get_conditionnumber,$
                                        nside_hitmap=nside_hitmap,$
                                        hits_per_sample=hits_per_sample,$
                                        warning_file=warning_file,$
                                        plot_level=plot_level,$
                                        subdir=subdir,$
                                        rot_ang_plot=rot_ang_plot


  ;AUTHOR: S. Leach
  ;PURPOSE: Create visualisation and LaTeX documentation of the scanning strategy.
  ;         Documentation is found in output/scanning_doc.pdf


  if(n_elements(outputdir) eq 0)           then outputdir     = './output/'
  if(n_elements(window) eq 0)              then window        = -1 ; Useful for running on remote machines -
                                                                   ; suppresses graphics windows
  if(n_elements(skipdetectors) eq 0)       then skipdetectors   = 1
  if(n_elements(get_conditionnumber) eq 0) then get_conditionnumber = 0
  if(n_elements(nside_hitmap) eq 0)        then nside_hitmap    = 512
  if(n_elements(hits_per_sample) eq 0)     then hits_per_sample = 1.0d0
  if(n_elements(warning_file) eq 0)        then warning_file    = 'WARNINGS_readme'
  if(n_elements(plot_level) eq 0)          then plot_level      = 0
  if(n_elements(subdir) eq 0)              then subdir          = 'boresight/'
  if n_elements(rot_ang_plot) eq 0         then rot_ang_plot    = [82.5,-44.5]

  mapdir = outputdir+'/maps/'+subdir
  spawn,'mkdir -p '+mapdir

  loadct, 38
  !p.background = 255
  !p.color      = 0
  
  read_fits_map,!HEXSKYROOT+'/data/dust_carlo_150ghz_512_radec.fits',dust150
  mission             = read_parameterfile(missionfile)
  antimoon_constraint = mission.antimoon_constraint_deg  
  antisun_constraint  = mission.antisun_constraint_deg  
  myoutline           = outline_schedule(schedule,mission)

  ;-------------------------------------------------------------
  ;First get command syntax for printing in schedule file header
  ;-------------------------------------------------------------
  command        = get_command_list()
  commandsyntax  = make_array(n_elements(command),value='')
  commandstring  = '                '
  for cc = 0,n_elements(command)-1L do begin
      cmd_format        = command_format(command[cc],syntax=syntax)
      commandstring     = '                 '
      strput,commandstring,command[cc],0
      commandsyntax[cc] = commandstring+syntax
  endfor

  lstschedulefile = cwd()+'/'+outputdir+'/lst_'+fsc_base_filename(schedule.filename)+'.sch'
  message,'--------------------------------------------------',/continue
  message,'Converting schedule file from UTC to LST timing in ',/continue
  message,lstschedulefile,/continue
  message,'--------------------------------------------------',/continue
  day   = schedule.day & month = schedule.month & year  = schedule.year
  convert_utcschedule_to_lstschedule,schedule.filename,lstschedulefile,$
                                     mission,[year,month,day],comment=commandsyntax
  wait,0.5


  ;---------------------------------
  ;Make scanning strategy az/el plot
  ;---------------------------------
  plot_schedule_azel,schedule,outputdir=outputdir

  ;------------------------------
  ;Make calibrator scan beam maps
  ;------------------------------
  calibrator_list  = ['SATURN','JUPITER','POLARIS','CASA','GALCENTRE','CENA','RCW38',$
                      'MAT5A','PKS0537-441','CARINA_NEBULA']
  jd_start         = get_jd_from_utcschedule(schedule)
  calibrator_scans = 0
  minimap_size_arcmin = mission.minimap_size_arcmin
  if plot_level ge 1 then begin
     load_ct = 1
     for cc = 0,schedule.ncommands -1  do begin
        if schedule.command[cc].name eq 'calibrator_scan' then begin
           calibrator_scans = 1
           nn               = int2filestring(cc+1,3)
           plotrootname     = 'command'+nn
           simulate_planetscan,pointing_dirfilename,mission,focalplane,$
                               planet=calibrator_list,first_sample=schedule.command[cc].first_sample_index,$
                               nsample=schedule.command[cc].nsample,plotrootname=plotrootname,$
                               skipdetectors = skipdetectors,output_dir=outputdir,$
                               minimap_size_arcmin = minimap_size_arcmin,load_ct=load_ct
           load_ct = 0
        endif
     endfor
  endif

  ;---------------------
  ;Make dipole scan maps
  ;---------------------
  for cc = 0,schedule.ncommands -1  do begin
      if strlowcase(schedule.command[cc].name) eq 'cmb_dipole' then begin
          nn           = int2filestring(cc+1,3)
          plotrootname = 'command'+nn
          simulate_dipolescan,pointing_dirfilename,mission,focalplane,$
                              first_sample=schedule.command[cc].first_sample_index,$
                              nsample=schedule.command[cc].nsample,plotrootname=plotrootname,$
                              skipdetectors=skipdetectors,output_dir=outputdir
      endif
  endfor

  
  ;----------------------------------------
  ;Make plot of focalplane integration time
  ;----------------------------------------
  spawn,'mkdir -p '+outputdir+'/ps/'+subdir
  if calibrator_scans then begin
      psfile = outputdir+'/ps/'+subdir+'/focalplane_integrationtime.ps'
      view_focalplane_integrationtime,focalplane,psfile,$
                                      minimap_size_arcmin=minimap_size_arcmin
  endif

  ;-------------------------------------------
  ;Work out average location of the focalplane
  ;-------------------------------------------
  det_index             = where(focalplane[*].power eq 1)
  ndet                  = n_elements(det_index)
  get_focalplane_average_azel,focalplane,focalplane_average_az,focalplane_average_el
;  full_focalplane       = get_na_wafer([150,250,410])
;  get_focalplane_average_azel,full_focalplane,focalplane_average_az,focalplane_average_el
  
  ;--------------------------------------------------
  ;Make hitmaps and postscript plots for each command
  ;--------------------------------------------------
  dustmax      = 1000
  target_coords,ra_polaris,dec_polaris,'POLARIS'       & outline_polaris   = outline_circle(ra_polaris,dec_polaris,0.5)
  target_coords,ra_casa,dec_casa,'CASA'                & outline_casa      = outline_circle(ra_casa,dec_casa,0.5)
  target_coords,ra_galcentre,dec_galcentre,'GALCENTRE' & outline_galcentre = outline_target('GALCENTRE',0.5)
  target_coords,ra_cena,dec_cena,'CENA'                & outline_cena      = outline_target('CENA',0.5)
  target_coords,ra_rcw38,dec_rcw38,'rcw38'             & outline_rcw38     = outline_target('RCW38',0.5)
  target_coords,ra_pks0537,dec_pks0537,'PKS0537-441'   & outline_pks0537   = outline_target('PKS0537-441',0.5)
 
  duration     = make_array(schedule.ncommands,value='')
  area_sqdeg   = make_array(schedule.ncommands,value=0.)
  get_earthpos_from_utcschedule,schedule,mission,lon,lat

  schedule_hitmap_bycommand            = make_array(nside2npix(nside_hitmap),n_elements(get_command_list()),value=0.)

   fixedoutline =  [outline_galacticplane(),$
                    outline_galacticplane(b=-2),outline_galacticplane(b=2),$
                    outline_polaris,outline_casa,outline_galcentre,$
                    outline_cena,outline_rcw38,outline_pks0537,$
                    outline_file(!HEXSKYROOT+'/data/BOOMERANG_deep.dat')]
   pixsize      = nside_to_pixsize(nside_hitmap)
   float_npix   = float(nside2npix(nside_hitmap))
   for cc = 0L,schedule.ncommands -1L  do begin
      print, ' '
      print,'Running get_hitmap for command '+strtrim(cc+1,2)+'/'+strtrim(schedule.ncommands,2)
      command_hitmap = get_hitmap(pointing_dirfilename, focalplane,mission,nside_hitmap=nside_hitmap,$
                                 first_sample=schedule.command[cc].first_sample_index,$
                                 nsample=schedule.command[cc].nsample,window=window,$
                                 skipdetectors=skipdetectors,get_conditionnumber=get_conditionnumber,$
                                 output_dir=outputdir,hits_per_sample=hits_per_sample) 
      RA           = schedule.command[cc].parameters[2]
      Dec          = schedule.command[cc].parameters[3]
      if abs(dec) lt 80 then grat= 5. else grat = [30,5]
      rot          = [ra*15.,dec]
      nn           = int2filestring(cc+1,3)
      duration[cc] = number_formatter(schedule.command[cc].expected_duration,dec=2)
      ;Plot integration time
      targetfield    = [outline_planet('SATURN', jd_start[cc]),$
                        outline_planet('JUPITER',jd_start[cc]),$
                        outline_moonpos(jd_start[cc]),$
                        outline_antisun(jd_start[cc],lat[cc],lon[cc])]
      field = [fixedoutline,targetfield,myoutline[cc]]
      area_sqdeg[cc] = 41253. * float(n_elements(where(command_hitmap[*,0] ne !healpix.bad_value)))/float_npix
      gnomres  = 4
      if plot_level ge 1 then begin
         gnomview,command_hitmap,1,/flip,$
                  rot=rot,window=window,grat=grat,glsize=1.5,coord=['C','C'],res=gnomres,$
                  title='Command '+strtrim(cc+1,2)+ ' ('+schedule.command[cc].name+') integration time',$
                  subtitle='Total time = '+duration[cc]+' hrs ; Coverage [sq deg] = '+$
                  number_formatter(area_sqdeg[cc],dec=1),$
                  factor=mission.tsamp_sec,$
                  units='s ('+number_formatter(pixsize,dec=1)+"' pixels)",$ ;'
                  ps=outputdir+'/ps/command'+nn+'_hits.ps',outline=field,/silent,/transparent
      endif

      ;----------------------------------
      ;Get cosIncidenceAngle for the moon
      ;----------------------------------
      ;; jd2lst,jd_start[cc],lon[cc],lst_command 
      ;; moontolerance_deg = 180. - antimoon_constraint      
      ;; datelocation      = jd2dateandtime(jd_start[cc])+$
      ;;                     ', Lon, lat [deg] =  ['+number_formatter(lon[schedule.ncommands-1],dec=1)+$
      ;;                     ', '+number_formatter(lat[cc],dec=1)+']'
      ;; mmap     = get_cosmooninc_map(jd_start[cc],lon[cc],lat[cc],moontolerance_deg=moontolerance_deg,nside=32)
      ;; title    = 'cosIncidenceAngle of Moon, '+textoidl('LST_0')+' [hr] = '+number_formatter(lst_command,dec=1)
      ;; subtitle = datelocation
      ;; mollview,mmap,1,$
      ;;          window=window,grat=grat,glsize=1.5,coord=['C','C'],$
      ;;          title=title,subtitle=subtitle,units=units,$
      ;;          ps=outputdir+'/ps/command'+nn+'_moonincidenceangle_moll.ps',/silent,$
      ;;          outline=[myoutline[cc],outline_galacticplane()]

      ;-------------------------------
      ;Bin up hits into hitmap (total)
      ;-------------------------------
      command_hitmap(where(command_hitmap[*,0] eq !healpix.bad_value)) = 0.
      if cc eq 0 then begin
         schedule_hitmap = command_hitmap
      endif else begin
         schedule_hitmap = schedule_hitmap + command_hitmap
      endelse

      ;-----------------------------------------
      ;Bin up hits into hitmap (by command type)
      ;-----------------------------------------
      index                              = where(get_command_list() eq schedule.command[cc].name)
      schedule_hitmap_bycommand[*,index] = schedule_hitmap_bycommand[*,index] + command_hitmap


      ;***** Temporary : write hitmap for each command ******
;      nn                  = int2filestring(cc+1,3)
;      tint_bycommand_file = mapdir+'/tint_command_'+nn+'.fits'
;      write_tqu,tint_bycommand_file,command_hitmap,order='ring',coord='C'

      ; new code : plot total integration time for cmb patch

      ;-------------
      ;Plot dust map
      ;-------------
      if plot_level ge 2 then begin
         gnomview,dust150,/flip,$
                  rot=rot,window=window+1,grat=grat,glsize=1.5,coord=['C','C'],res=5,$
                  title='Command '+strtrim(cc+1,2)+ ' ('+schedule.command[cc].name+') dust at 150 GHz',$
                  ps=outputdir+'/ps/command'+nn+'_dust.ps',$
                  units=textoidl('\muK_{CMB}'),max= dustmax,$
                  factor=conversion_factor('uK_RJ','uK_CMB',150*1e9),outline=field,/silent,/log
      endif

     ;-------------------------
     ;Plot condition number map
     ;-------------------------
      if(get_conditionnumber) then begin
         qu = 0
         if qu then mincond = 1 else mincond=2
         maxcond  = 4
         map_cond = get_conditionnumbermap(command_hitmap,qu=qu)
         map_cond(where(map_cond eq 0.)) = !healpix.bad_value
         gnomview,map_cond,/flip,$
                  rot=rot,window=window+1,grat=grat,glsize=1.5,coord=['C','C'],res=gnomres,$
                  title='Command '+strtrim(cc+1,2)+ ' ('+schedule.command[cc].name+') condition number',$
                  ps=outputdir+'/ps/command'+nn+'_conditionnumber.ps',$
                  subtitle='Total time = '+duration[cc]+' hrs ; Coverage [sq deg] = '+$
                  number_formatter(area_sqdeg[cc],dec=1),factor=1.,$
                  units='('+number_formatter(pixsize,dec=1)+"' pixels)",$
                  min=mincond,max=maxcond,outline=field,/silent
      endif
   endfor


  ;--------------------------------
  ;Plot map of total number of hits
  ;--------------------------------
  total_duration = (schedule.command[schedule.ncommands -1].parameters[0]-$
                    schedule.command[0].parameters[0])*24. + $
                   (schedule.command[schedule.ncommands -1].parameters[1]-$
                    schedule.command[0].parameters[1]) + $
                   schedule.command[schedule.ncommands -1].expected_duration
  total_duration = number_formatter(total_duration,dec=2)

  ;--------------------------
  ;Plot integration time maps
  ;--------------------------
  commands       = get_command_list()
  ncommandtype   = n_elements(commands) 
  hitmap_plotted = make_array(ncommandtype,value=0)
  rot_maxval     = make_array(2,ncommandtype,value=0)
  outline        = [outline_galacticplane(),$
                    outline_galacticplane(b=-2),outline_galacticplane(b=2)]
  if plot_level ge 0 then begin
     for cc = 0, ncommandtype - 1 do begin
        maxval_command = 0.
        if total(schedule_hitmap_bycommand[*,cc]) gt 0. then begin
           hitmap_plotted[cc] = 1
           rot                = rotang_maxval(schedule_hitmap_bycommand[*,cc],maxval=maxval)
           if abs(rot[1]) lt 80 then grat = 5. else grat = [30,5]
           if maxval gt maxval_command then begin
              maxval_command     = maxval
              rot_maxval[0:1,cc] = rot
           endif
           map              = schedule_hitmap_bycommand[*,cc]
           total_area_sqdeg = 41253. * float(n_elements(where(map ne 0.)))/float_npix
           map[where(map eq 0)] = !healpix.bad_value
           gnomview,map,/flip,$
                    rot=rot,window=window,grat=grat,glsize=1.5,coord=['C','C'],res=5,$
                    title='Total integration time: '+commands[cc],$
                    subtitle='Coverage [sq deg] = '+$
                    number_formatter(total_area_sqdeg,dec=1),factor=mission.tsamp_sec,$
                    units='s ('+number_formatter(pixsize,dec=1)+"' pixels)",$ ;'
                    ps=outputdir+'/ps/'+subdir+'/schedule_hits_'+commands[cc]+'.ps',/silent,outline=outline
           mollview,map,$
                    window=window,grat=grat,glsize=1.5,coord=['C','C'],$
                    title='Total integration time: '+commands[cc],$
                    subtitle='Coverage [sq deg] = '+$
                    number_formatter(total_area_sqdeg,dec=1),factor=mission.tsamp_sec,$
                    units='s ('+number_formatter(pixsize,dec=1)+"' pixels)",$ ;'
                    ps=outputdir+'/ps/'+subdir+'/schedule_hits_moll_'+commands[cc]+'.ps',/silent,outline=outline
           delvarx,map
        endif
     endfor
  endif

  ;-------------------------------------------------------------
  ;Make histograms of integration time and sqrt integration time
  ;-------------------------------------------------------------  
  index = where(schedule_hitmap gt 0.)
  schedule_hitmap[index]             = schedule_hitmap[index]*mission.tsamp_sec
  for tt = 0, ncommandtype - 1 do begin
     index = where(schedule_hitmap_bycommand[*,tt] gt 0.)
     if index[0] ne -1 then schedule_hitmap_bycommand[index,tt] = schedule_hitmap_bycommand[index,tt]*mission.tsamp_sec
  endfor
  plot_integrationtime_histograms,schedule_hitmap_bycommand,outputdir=outputdir,net=mission.net,subdir=subdir


  ;-----------------------------------
  ;Write integration time maps to disk
  ;-----------------------------------
  tint_file           = mapdir+'/tint_'+fsc_base_filename(schedule.filename)+'.fits'
  tint_bycommand_file = mapdir+'/tint_bycommand_'+fsc_base_filename(schedule.filename)+'.fits'
  print,'Writing integration time map to '+tint_file
  write_fits_map,tint_file,schedule_hitmap,order='ring',coord='C'
  print,'Writing integration time map (by command) to '+tint_bycommand_file
  schedule_hitmap_bycommand(where(schedule_hitmap_bycommand eq 0.)) = !healpix.bad_value
  write_tqu,tint_bycommand_file,schedule_hitmap_bycommand,order='ring',coord='C'

  ;---------------------------
  ; Make battery lifetime plot
  ;---------------------------
  if plot_level ge 1 then begin
     battery_psfile = 'battery_lifetime.ps'
     get_batterylifetime_plot,outputdir+'/ps/'+battery_psfile,pointing_dirfilename,$
                              solar_module_temp_celsius=mission.solar_module_temp_celsius,$
                              pointingfile=outputdir+'/batterySimulation.py.out'
  endif

  ;-------------------------------------------------------------------
  ; Output an ascii file to disk with a list of commands and their RJD
  ;-------------------------------------------------------------------
  outfile = outputdir+'/commandlist.dat'
  print,'Writing a command list to '+outfile
  asc_write,outputdir+'/commandlist.dat',jd_start-!constant.rjd0,$
            jd_start - !constant.rjd0,schedule.command.name,$
            header = '# RJD_start [day], RJD_start [day], Command name.  RJD offset = '+$
            strtrim(double(!constant.rjd0))
  
  ;-----------------------------------
  ;Plot dust map for each command type
  ;-----------------------------------
  for cc = 0, ncommandtype - 1 do begin
     psfile = outputdir+'/ps/'+subdir+'/schedule_dust_'+commands[cc]+'.ps'
     gnomview,dust150,/flip,$
              rot=rot_maxval[0:1,cc],window=window+1,grat=grat,glsize=1.5,coord=['C','C'],res=5,$
              title='Dust at 150 GHz',$
              ps=psfile,$
              units=textoidl('\muK_{CMB}'),max= dustmax,$
              factor=conversion_factor('uK_RJ','uK_CMB',150*1e9),/silent,outline=outline,/log
  endfor

  ;------------------------------------------
  ; Plot visibility map for each command type
  ;------------------------------------------
  duration_hr                 = 24.
  vismap                      = get_visibilitymap(jd_start[0],duration_hr,lon[0],lat[0],$
                                                  minel=mission.elevation_lowerlimit_deg,$
                                                  maxel=mission.elevation_upperlimit_deg,nside=64,$
                                                  vismap_firsthalf=vismap_firsthalf)
  jd2lst,jd_start[0],lon[0],lst_start & jd2lst,jd_start[0]+duration_hr/24.,lon[0],lst_end
  
  datelocation = jd2dateandtime(jd_start[0])+$
                 ', Lon, lat [deg] =  ['+number_formatter(lon[0],dec=1)+$
                 ', '+number_formatter(lat[0],dec=1)+']'
  title    = 'Visibility map, '+textoidl('LST_0')+' [hr] = '+number_formatter(lst_start,dec=1)  
  units    = 'hrs/day'
  subtitle = datelocation
  vismap[where(vismap eq 0.)] = !healpix.bad_value
  schedule_outline = outline_schedule(schedule,mission,noutline=noutline)
  outline = [schedule_outline,outline_galacticplane()]
  mollview,vismap,1,$
           window=window,grat=grat,glsize=1.5,coord=['C','C'],$
           title=title,subtitle=subtitle,units=units,$
           ps=outputdir+'/ps/'+subdir+'/visibility_moll.ps',/silent,outline=outline
  for cc = 0, ncommandtype - 1 do begin
     psfile = outputdir+'/ps/'+subdir+'/visibility_'+commands[cc]+'.ps'
     gnomview,vismap,1,/flip,$
              window=window,grat=grat,glsize=1.5,coord=['C','C'],$
              title=title,subtitle=subtitle,units=units,$
              ps=psfile,/silent,outline=outline,rot=rot_maxval[*,cc],res=5;,$
;              charsize=1.5
  endfor
    
  vis_file = mapdir+'/visibility_'+fsc_base_filename(schedule.filename)+'.fits'
  write_fits_map,vis_file,vismap,order='ring',coord='C' & vismap = 0.
  
  ;--------------------------------
  ; Get solar panel attenuation map
  ;--------------------------------
  panel_el_deg = 23.5
  amap = get_solarpanel_attenuation_map(jd_start[0],duration_hr,lon[0],lat[0],panel_el_deg=panel_el_deg,nside=64)
  amap[where(amap eq 0.)] = !healpix.bad_value
  title    = 'Solar attenuation, '+textoidl('LST_0')+' [hr] = '+number_formatter(lst_start,dec=1)
  subtitle = datelocation
  units = ' '
  mollview,amap,1,$
           window=window,grat=grat,glsize=1.5,coord=['C','C'],$
           title=title,subtitle=subtitle,units=units,$
           ps=outputdir+'/ps/solar_attenuation_moll.ps',/silent,outline=outline  
  
  for cc = 0, ncommandtype - 1 do begin
     psfile = outputdir+'/ps/'+subdir+'/solar_attenuation_'+commands[cc]+'.ps'     
     gnomview,amap,1,/flip,$
              window=window,grat=grat,glsize=1.5,coord=['C','C'],$
              title=title,subtitle=subtitle,units=units,$
              ps=psfile,/silent,outline=outline,rot=rot_maxval[*,cc],res=5;,$
;              charsize=1.5
  endfor
     delvarx,amap

  ;--------------------------------------------------------------
  ;Get cosIncidenceAngle for the moon for first and last commands
;  ;--------------------------------------------------------------
;  moontolerance_deg = 180. - antimoon_constraint
;  mmap     = get_cosmooninc_map(jd_start[0],lon[0],lat[0],moontolerance_deg=moontolerance_deg) ; First command
;  title    = 'cosIncidenceAngle of Moon, '+textoidl('LST_0')+' [hr] = '+number_formatter(lst_start,dec=1)
;  subtitle = datelocation
;  mollview,mmap,1,$
;           window=window,grat=grat,glsize=1.5,coord=['C','C'],$
;           title=title,subtitle=subtitle,units=units,$
;           ps=outputdir+'/ps/moonincidenceangle_firstcommand_moll.ps',/silent,outline=outline


  cc       = schedule.ncommands - 1
  mmap     = get_cosmooninc_map(jd_start[cc],lon[cc],lat[cc],moontolerance_deg=moontolerance_deg) ; Last command
  jd2lst,jd_start[cc],lon[cc],lst_last
  datelocation = jd2dateandtime(jd_start[cc])+$
                 ', Lon, lat [deg] =  ['+number_formatter(lon[schedule.ncommands-1],dec=1)+$
                 ', '+number_formatter(lat[cc],dec=1)+']'
  title    = 'cosIncidenceAngle of Moon, '+textoidl('LST_0')+' [hr] = '+number_formatter(lst_last,dec=1)
  subtitle = datelocation
  mollview,mmap,1,$
           window=window,grat=grat,glsize=1.5,coord=['C','C'],$
           title=title,subtitle=subtitle,units=units,$
           ps=outputdir+'/ps/moonincidenceangle_lastcommand_moll.ps',/silent,outline=outline
  
  ;------------------------------------
  ; Optionally get condition number map
  ;------------------------------------
  if(get_conditionnumber) then begin
     map_cond                        = get_conditionnumbermap(schedule_hitmap,qu=1)
     map_cond(where(map_cond eq 0.)) = !healpix.bad_value
     mollview,map_cond,$
              window=window,grat=grat,glsize=1.5,coord=['C','C'],$
              title='Condition number',factor=1.,$
              subtitle='Total time = '+total_duration+' hrs ; Coverage [sq deg] = '+$
              number_formatter(total_area_sqdeg,dec=1),$
              units='('+number_formatter(pixsize,dec=1)+"' pixels)",$
              ps=outputdir+'/ps/schedule_conditionnumber_moll.ps',/silent,outline=outline,min=mincond,max=10
     gnomview,map_cond,/flip,$
              rot=rot_maxval[*,cc],window=window+1,grat=grat,glsize=1.5,coord=['C','C'],res=gnomres,$
              title='Condition number',$
              subtitle='Max integration time region',$
              units='('+number_formatter(pixsize,dec=1)+"' pixels)",$
              ps=outputdir+'/ps/schedule_conditionnumber.ps',$
              min=mincond,max=10,outline=field,/silent,pxsize=1000,pysize=500
  endif



  ;-------------------------------------------
  ;Make az/el plots of repointings and targets
  ;------------------------------------------- 
  elevation_step          = make_array(schedule.ncommands,value=0.)
  elevation_of_command    = make_array(schedule.ncommands,2,value=0.)
  focalplane_orientation  = make_array(schedule.ncommands,value=0.)
  recommended_ra_saturn   = make_array(schedule.ncommands,value=0.)
  recommended_dec_saturn  = make_array(schedule.ncommands,value=0.)
  recommended_ra_jupiter  = make_array(schedule.ncommands,value=0.)
  recommended_dec_jupiter = make_array(schedule.ncommands,value=0.)
  recommended_ra_moon     = make_array(schedule.ncommands,value=0.)
  recommended_dec_moon    = make_array(schedule.ncommands,value=0.)
  recommended_ra_casa     = make_array(schedule.ncommands,value=0.)
  recommended_dec_casa    = make_array(schedule.ncommands,value=0.) 
  az_command              = make_array(schedule.ncommands,value=0.)   & el_command = az_command
  az_sun                  = make_array(schedule.ncommands,2,value=0.) & el_sun     = az_sun
  az_moon                 = make_array(schedule.ncommands,2,value=0.) & el_moon    = az_moon
  antisun_azdist          = make_array(schedule.ncommands,2,value=0.)
  antimoon_azdist         = make_array(schedule.ncommands,2,value=0.)
  galacticplane_coords,ra_gal,dec_gal
  for cc = 0,schedule.ncommands -1  do begin
      jd_end      = jd_start[cc] + schedule.command[cc].expected_duration/24.
      jd          = [jd_start[cc],jd_end]

     ;-------------------------------------- 
     ; Get position of Sun and other targets
     ;-------------------------------------- 
      sunpos, jd,ra_sun, dec_sun
      moonpos,jd,ra_moon,dec_moon
      planet_coords, jd, ra_jup, dec_jup, planet='JUPITER', /jd, /jpl
      planet_coords, jd, ra_sat, dec_sat, planet='SATURN', /jd, /jpl

      eq2hor, ra_sun,  dec_sun,  jd, el_sun_tmp,  az_sun_tmp, lon=lon[cc],lat=lat[cc]
      eq2hor, ra_moon, dec_moon, jd, el_moon_tmp, az_moon_tmp,lon=lon[cc],lat=lat[cc]
      el_sun[cc,*]  = el_sun_tmp
      az_sun[cc,*]  = az_sun_tmp
      el_moon[cc,*] = el_moon_tmp
      az_moon[cc,*] = az_moon_tmp
      eq2hor, ra_jup,  dec_jup,  jd, el_jup,  az_jup, lon=lon[cc],lat=lat[cc]
      eq2hor, ra_sat,  dec_sat,  jd, el_sat,  az_sat, lon=lon[cc],lat=lat[cc]
      eq2hor, ra_gal,  dec_gal,  jd[0], el_gal_start,  az_gal_start, lon=lon[cc],lat=lat[cc]
      eq2hor, ra_gal,  dec_gal,  jd[1], el_gal_end,  az_gal_end, lon=lon[cc],lat=lat[cc]
      eq2hor, ra_polaris*[1.,1.],  dec_polaris*[1.,1.],  jd, el_polaris,  az_polaris, lon=lon[cc],lat=lat[cc]
      eq2hor, ra_cena*[1.,1.],  dec_cena*[1.,1.],  jd, el_cena,  az_cena, lon=lon[cc],lat=lat[cc]
      eq2hor, ra_rcw38*[1.,1.],  dec_rcw38*[1.,1.],  jd, el_rcw38,  az_rcw38, lon=lon[cc],lat=lat[cc]
      eq2hor, ra_pks0537*[1.,1.],  dec_pks0537*[1.,1.],  jd, el_pks0537,  az_pks0537, lon=lon[cc],lat=lat[cc]
      
      ;---------------------------------------------------------------
      ;Work out where the boresight should point so that the centre of
      ;of detectors in the focalplane scans the target.
      ;---------------------------------------------------------------
      aim_the_boresight,ra_sat[0],dec_sat[0],jd[0],lon[cc],lat[cc],$
                        focalplane_average_az,focalplane_average_el,ra,dec
      recommended_ra_saturn[cc]  = ra & recommended_dec_saturn[cc] = dec
      aim_the_boresight,ra_jup[0],dec_jup[0],jd[0],lon[cc],lat[cc],$
                        focalplane_average_az,focalplane_average_el,ra,dec
      recommended_ra_jupiter[cc]  = ra & recommended_dec_jupiter[cc] = dec
      aim_the_boresight,ra_moon[0],dec_moon[0],jd[0],lon[cc],lat[cc],$
                        focalplane_average_az,focalplane_average_el,ra,dec
      recommended_ra_moon[cc]  = ra & recommended_dec_moon[cc] = dec
      aim_the_boresight,ra_casa,dec_casa,jd[0],lon[cc],lat[cc],$
                        focalplane_average_az,focalplane_average_el,ra,dec
      recommended_ra_casa[cc]  = ra & recommended_dec_casa[cc] = dec
      
      if schedule.command[cc].name eq 'cmb_dipole' then begin
         az_pointing = make_array(2,value=0.)
         el_pointing = make_array(2,value=schedule.command[cc].parameters[3])
      endif else begin
         asc_read,outputdir+'/hexsky_outfiles/command'+strtrim(cc+1,2)+'_azel_repointings.dat',az_pointing,el_pointing,/silent
      endelse

      az_command[cc] = az_pointing[0] & el_command[cc] = el_pointing[0]
      
      nrepointing                = n_elements(el_pointing)
      focalplane_orientation[cc] = $
         get_focalplane_orientation(az_pointing[0],el_pointing[0],jd[0],lon[cc],lat[cc],/horizon_coords)
      focalplane_orientation[cc] = modpos(focalplane_orientation[cc],wrap=!pi,/zero_cent)
      jd_pointing = jd_start[cc] + findgen(nrepointing)*(jd_end-jd_start[cc])/float(nrepointing-1)

      if(nrepointing gt 1) then elevation_step[cc] = (el_pointing[1]-el_pointing[0])*60.
      elevation_of_command[cc,0] = el_pointing[0]
      elevation_of_command[cc,1] = el_pointing[n_elements(el_pointing)-1]

      ;------------------------------------------------------------
      ;Get distance from anti-sun direction and anti-moon direction
      ;------------------------------------------------------------
      antisun               = (az_sun[cc,*] + 180.) mod 360.
      antimoon              = (az_moon[cc,*]+ 180.) mod 360.
      antisun_azdist[cc,0]  = abs(modpos(antisun[0] - az_pointing[0],wrap=180,/zero_cent))
      antisun_azdist[cc,1]  = abs(modpos(antisun[1] - az_pointing[nrepointing-1],wrap=180,/zero_cent))
      antimoon_azdist[cc,0] = abs(modpos(antimoon[0] - az_pointing[0],wrap=180,/zero_cent))
      antimoon_azdist[cc,1] = abs(modpos(antimoon[1] - az_pointing[nrepointing-1],wrap=180,/zero_cent))

      psfile = outputdir+'/ps/command'+strtrim(cc+1,2)+'_azel_repointings.ps'
      ps_start,filename=psfile,/quiet
      plot,az_pointing,el_pointing,/nodata,xrange=[-5,365],yrange=[-10,90],charsize=1.7,$
           xstyle=1,ystyle=1,$
           XTicklen=1.0, YTicklen=1.0, XGridStyle=1, YGridStyle=1,$
           xtitle='Azimuth [deg]',ytitle='Elevation [deg]',psym=1,$
           title='Elevation step = '+$
           number_formatter(elevation_step[cc],dec=2)+"'" ;'
      oplot,az_pointing,el_pointing,psym=1
      oplot,az_sun[cc,*], el_sun[cc,*], psym=4
      oplot,az_moon[cc,*],el_moon[cc,*],psym=6
      a = sort(az_gal_start)
      b = sort(az_gal_end)
      oplot, az_gal_start[a],   el_gal_start[a], line=1
      oplot, az_gal_end[b],   el_gal_end[b], line=1
      oplot, [az_gal_start[0]],   [el_gal_start[0]], psym=2 ; Galactic centre
      oplot, [az_gal_end[0]],   [el_gal_end[0]], psym=2     ; Galactic centre
      al_legend,['Galactic plane','Galactic centre'],$
             line=[1,1],psym=[0,2],box=0,/bottom,/right,charsize=1.3
      al_legend,['Repointings','Sun position','Moon position'],$
             psym=[1,4,6],box=0,/top,/right,charsize=1.3

      ;NA targets
;      oplot,[az_jup], [el_jup], psym=5
;      oplot,[az_sat], [el_sat], psym=7
;      oplot,[az_polaris], [el_polaris], psym=sym(6)
;      al_legend,['Jupiter, [RA, Dec] = ['+$
;              number_formatter(ra_jup[0]/15.,dec=2)+', '+$
;              number_formatter(dec_jup[0],dec=2)+'] [hr,deg]',$
;              'Saturn, [RA, Dec] = ['+$
;              number_formatter(ra_sat[0]/15.,dec=2)+', '+$
;              number_formatter(dec_sat[0],dec=2)+'] [hr,deg]',$
;              'Polaris'],$      
;             psym=[5,7,sym(6)],box=0,/top,/left,charsize=1.3

      ;LDB targets
      oplot,[az_rcw38], [el_rcw38], psym=5
      oplot,[az_cena], [el_cena], psym=7
      oplot,[az_pks0537], [el_pks0537], psym=sym(6)
      al_legend,['RCW 38, [RA, Dec] = ['+$
              number_formatter(ra_rcw38[0]/15.,dec=2)+', '+$
              number_formatter(dec_rcw38[0],dec=2)+'] [hr,deg]',$
              'Cen A, [RA, Dec] = ['+$
              number_formatter(ra_cena[0]/15.,dec=2)+', '+$
              number_formatter(dec_cena[0],dec=2)+'] [hr,deg]',$
              'PKS0537-441 [RA, Dec] = ['+$
              number_formatter(ra_pks0537[0]/15.,dec=2)+', '+$
              number_formatter(dec_pks0537[0],dec=2)+'] [hr,deg]'],$
              psym=[5,7,sym(6)],box=0,/top,/left,charsize=1.3
      ps_end
  endfor
  onskyscanspeed_deg = get_onskyscanspeed_from_schedule(schedule,elevation_of_command[*,0])

  ;-----------------------
  ;Make plot of focalplane
  ;-----------------------
  psfile = outputdir+'/ps/focalplane.ps'
  ps_start,filename=psfile
  view_focalplane,focalplane
  ps_end

  ;------------------------
  ;Make latex documentation
  ;------------------------
  docdir = outputdir+'/doc/'+subdir+'/'
  spawn,'mkdir -p '+docdir
  unit       = 55
  latex_file = 'scanning_doc_'+fsc_base_filename(schedule.filename)
  strreplace,latex_file,'.sch',''
  latex_open_article,unit,docdir+latex_file+'.tex'
  
  ;Title
  printf,unit,'\title{Scanning strategy simulation documentation}'
  printf,unit,'%\author{Sam Leach,\\SISSA}'

  ;--------------
  ;Begin document
  ;--------------
  printf,unit,'\begin{document} \maketitle'
  
  ;---------------------
  ;Print commands syntax
  ;---------------------
  printf,unit,'\section{Command syntax}'
  printf,unit,'\begin{verbatim}'
  for cc = 0,n_elements(command)-1 do begin
      printf,unit,commandsyntax[cc]
  endfor
  printf,unit,'\end{verbatim}'

  ;-------------------------------------
  ;Print out schedule file warnings file
  ;-------------------------------------
  printf,unit,'\newpage'
  printf,unit,'\section{Schedule file warnings}'
  printf,unit,'\begin{verbatim}'
  printf,unit,'# Warning code, command number, warning parameters # Comment'
  printf,unit,warning_file
  printf,unit,'\end{verbatim}'
  printf,unit,'\verbatiminput{'+'../../'+warning_file+'}'
						  
  ;---------------------------------------------
  ;Print out schedule file with UTC style timing
  ;---------------------------------------------
  printf,unit,'\newpage'
  printf,unit,'\section{Schedule file - UTC timing}'
  printf,unit,'\begin{verbatim}'
  printf,unit,schedule.filename
  printf,unit,'\end{verbatim}'
  printf,unit,'\verbatiminput{'+'../../../'+schedule.filename+'}'

	
  printf,unit,'\newpage'
  printf,unit,'\section{Schedule file - LST timing}'
  printf,unit,'\begin{verbatim}'
  printf,unit,lstschedulefile
  printf,unit,'\end{verbatim}'
  printf,unit,'\verbatiminput{'+lstschedulefile+'}'
  
  ;----------------------
  ;Print out mission file
  ;----------------------
  printf,unit,'\newpage'
  printf,unit,'\section{Mission file - simulation parameters}'
  printf,unit,'\begin{verbatim}'
  printf,unit,missionfile
  printf,unit,'\end{verbatim}'
  printf,unit,'\verbatiminput{'+missionfile+'}'

  printf,unit,'\newpage'
  printf,unit,'\section{Overview of scanning strategy}'

  ;-----------------------------------------------
  ; Show az/el of repointings of scanning strategy
  ;-----------------------------------------------
  commands = get_command_list()
  printf,unit,'\begin{center}'
  printf,unit,'%\begin{figure}'
  for cc = 0,n_elements(commands) -1 do begin
     command = commands[cc]
     if command ne 'cmb_dipole' then begin
        psfile = '../../ps/schedule_azel_'+command+'.ps'
        printf,unit,'\includegraphics[width=100mm,angle=270]{'+psfile+'}'
     endif
  endfor
  printf,unit,'%\end{figure}'
  printf,unit,'\end{center}'
  printf,unit,'\newpage'



  if plot_level ge 1 then begin
     ;Show battery lifetime plot
     printf,unit,'\begin{center}'
     printf,unit,'%\begin{figure}'
     psfile = '../../ps/battery_lifetime.ps'
     printf,unit,'\includegraphics[width=100mm,angle=270]{'+psfile+'}'
     printf,unit,'%\end{figure}'
     printf,unit,'\end{center}'
     printf,unit,'\newpage'
  endif

  commands = get_command_list()
  for cc = 0,n_elements(commands) -1 do begin
     command = commands[cc]
     if hitmap_plotted[cc] then begin
        printf,unit,'\begin{center}'
        printf,unit,'%\begin{figure}'
        psfile = '../../ps/schedule_histogram_'+command+'.ps'
        printf,unit,'\includegraphics[width=60mm,angle=270]{'+psfile+'}'
        psfile = '../../ps/schedule_histogram_sqrtsec_'+command+'.ps'
        printf,unit,'\includegraphics[width=60mm,angle=270]{'+psfile+'}'
        psfile = '../../ps/schedule_cumulhistogram_'+command+'.ps'
        printf,unit,'\includegraphics[width=60mm,angle=270]{'+psfile+'}'
        psfile = '../../ps/schedule_cumulhistogram_sqrtsec_'+command+'.ps'
        printf,unit,'\includegraphics[width=60mm,angle=270]{'+psfile+'}'
        printf,unit,'%\end{figure}'
        printf,unit,'\end{center}'
        printf,unit,'\newpage'
     endif
  endfor

  
  printf,unit,'\begin{center}'
  printf,unit,'%\begin{figure}'
  for cc = 0, ncommandtype -1 do begin
     if hitmap_plotted[cc] then begin
        psfile = '../../ps/'+subdir+'/schedule_hits_'+commands[cc]+'.ps'
        printf,unit,'\includegraphics[width=70mm]{'+psfile+'}'
        psfile = '../../ps/'+subdir+'/visibility_'+commands[cc]+'.ps'
        printf,unit,'\includegraphics[width=70mm]{'+psfile+'}'
        psfile = '../../ps/'+subdir+'/schedule_dust_'+commands[cc]+'.ps'
        printf,unit,'\includegraphics[width=70mm]{'+psfile+'}'
        psfile = '../../ps/'+subdir+'/solar_attenuation_'+commands[cc]+'.ps'
        printf,unit,'\includegraphics[width=70mm]{'+psfile+'}'
     endif
  endfor
  psfile = '../../ps/'+subdir+'/visibility_moll.ps'
  printf,unit,'\includegraphics[width=100mm,angle=90]{'+psfile+'}'
;  psfile = '../../ps/schedule_hits_moll.ps'
;  printf,unit,'\includegraphics[width=100mm,angle=90]{'+psfile+'}'
;  psfile = '../../ps/solar_attenuation_gnom.ps'
;  printf,unit,'\includegraphics[width=80mm]{'+psfile+'}'
  psfile = '../../ps/solar_attenuation_moll.ps'
  printf,unit,'\includegraphics[width=100mm,angle=90]{'+psfile+'}'
  printf,unit,'%\end{figure}'
  printf,unit,'\end{center}'


  ;-----------------
  ;Focalplane figure
  ;-----------------
  printf,unit,'\newpage'
  printf,unit,'\section{Focalplane}'
  printf,unit,'\begin{center}'
  printf,unit,'%\begin{figure}'
  psfile = '../../ps/focalplane.ps'
  printf,unit,'\includegraphics[width=90mm,angle=270]{'+psfile+'}'
  if plot_level ge 1 then begin
     if calibrator_scans then begin
        psfile = '../../ps/'+subdir+'/focalplane_integrationtime.ps'
        printf,unit,'\includegraphics[width=90mm,angle=270]{'+psfile+'}'
     endif
  endif
  printf,unit,'%\end{figure}'
  printf,unit,'\end{center}'
  printf,unit,'\begin{verbatim}'
  printf,unit,'Number of detectors           = '+strtrim(ndet,2)
  printf,unit,'Average az of detectors [deg] = '+number_formatter(focalplane_average_az,dec=2)
  printf,unit,'Average el of detectors [deg] = '+number_formatter(focalplane_average_el,dec=2)
  printf,unit,'\end{verbatim}'

  ;-----------------------------------------------------------
  ;Show az/el repointings, hitmap and dustmap for each command
  ;-----------------------------------------------------------
  for cc = 0,schedule.ncommands -1  do begin
      nn     = int2filestring(cc+1,3)
      printf,unit,'\newpage'
      printf,unit,'\begin{center}'
      if plot_level ge 1 then begin
         printf,unit,'%\begin{figure}'
         psfile = '../../ps/command'+nn+'_hits.ps'
         printf,unit,'\includegraphics[width=70mm]{'+psfile+'}'
         if plot_level ge 2 then begin
            psfile='../../ps/command'+nn+'_dust.ps'
            printf,unit,'\includegraphics[width=70mm]{'+psfile+'}'
         endif
      endif
      psfile = '../../ps/command'+strtrim(cc+1,2)+'_azel_repointings.ps'
      printf,unit,'\includegraphics[width=90mm,angle=270]{'+psfile+'}'
      printf,unit,'%\end{figure}'
      printf,unit,'\end{center}'
      printf,unit,'\begin{verbatim}'
      printf,unit,command_to_string(schedule.command[cc])
      printf,unit,'Scan period [s] = '+number_formatter(get_scan_period_estimate(schedule.command[cc],mission),dec=1)
      printf,unit,'\end{verbatim}'
      printf,unit,' '
      printf,unit,'\begin{verbatim}'
      ;-------------------------
      ;Check anti-sun constraint
      ;-------------------------
      horizon_at_float = -10.
      if (antisun_azdist[cc,0] gt antisun_constraint) or (antisun_azdist[cc,1] gt antisun_constraint) then begin
         if (el_sun[cc,0] gt horizon_at_float) or (el_sun[cc,1] gt horizon_at_float) then begin
            antisun_warning =' [ ANTI-SUN WARNING: DAY TIME ]'
            warning_message,antisun_warning,warning_file=outputdir+'/'+warning_file,type=5,index=(cc+1),$
                            parameter=[antisun_azdist[cc,0],antisun_azdist[cc,1]],/silent
         endif else begin
            antisun_warning =' [ ANTI-SUN okay: Night time ]'
         endelse
      endif else begin
         antisun_warning = ''
      endelse
      ;--------------------------
      ;Check anti-moon constraint
      ;--------------------------
      if (antimoon_azdist[cc,0] gt antimoon_constraint) or (antimoon_azdist[cc,1] gt antimoon_constraint) then begin
	 moonset_elevation = horizon_at_float
         if (el_moon[cc,0] gt moonset_elevation) or (el_moon[cc,1] gt moonset_elevation) then begin
            antimoon_warning = ' [ ANTI-MOON WARNING ]'
            warning_message,antimoon_warning,warning_file=outputdir+'/'+warning_file,type=6,index=(cc+1),$
                            parameter=[antimoon_azdist[cc,0],antimoon_azdist[cc,1]],/silent
         endif else begin
            antimoon_warning = ' [ ANTI-MOON okay: moon below '+$
                               number_formatter(moonset_elevation,dec=0)+' deg ]'
         endelse
      endif else begin
          antimoon_warning = ''
      endelse
      ;---------------------------
      ;Check elevation constraints
      ;---------------------------
      if ((elevation_of_command[cc,0] gt mission.elevation_upperlimit_deg) or $
          (elevation_of_command[cc,1] gt mission.elevation_upperlimit_deg) or $
          (elevation_of_command[cc,0] lt mission.elevation_lowerlimit_deg) or $
          (elevation_of_command[cc,1] lt mission.elevation_lowerlimit_deg)) then begin
         elevation_warning = ' [ ELEVATION RANGE WARNING ]'
      endif else begin
         elevation_warning = ''
      endelse


      printf,unit,'At Start / End of command: Az distance from anti-sun [deg] = '+$
	      number_formatter(antisun_azdist[cc,0],dec=1)+' / '+$
	      number_formatter(antisun_azdist[cc,1],dec=1)+antisun_warning
      printf,unit,'                    Az distance from anti-moon [deg] = '+$
	      number_formatter(antimoon_azdist[cc,0],dec=1)+' / '+$
	      number_formatter(antimoon_azdist[cc,1],dec=1)+antimoon_warning
      printf,unit,'                          Approximate [Az, El] [deg] = '+$
	      '['+number_formatter(az_command[cc],dec=1)+', '+number_formatter(el_command[cc],dec=1)+']'
      printf,unit,'                         [longitude, latitude] [deg] = '+$
	      '['+number_formatter(lon[cc],dec=1)+', '+number_formatter(lat[cc],dec=1)+']'
      printf,unit,'                                     elevation [deg] = '+$
             number_formatter(elevation_of_command[cc,0],dec=1)+' / '+$
             number_formatter(elevation_of_command[cc,1],dec=1)+elevation_warning
      printf,unit,'                                     cos(elevation)  = '+$
             number_formatter(cos(elevation_of_command[cc,0]*!dtor),dec=2)+' / '+$
             number_formatter(cos(elevation_of_command[cc,1]*!dtor),dec=2)+elevation_warning
      printf,unit,'                          On-sky scan speed [deg/s]  = '+$
             number_formatter(onskyscanspeed_deg[cc],dec=2)
      printf,unit,'                Focalplane orientation on-sky [deg]  = '+$
             number_formatter(focalplane_orientation[cc]*!radeg,dec=2)
      printf,unit,'\end{verbatim}'
      printf,unit,' '
;      printf,unit,'\begin{verbatim}'
;      printf,unit,'For Saturn scanning,  recommended boresight [RA,Dec] [hr,deg] = ['+$
;        number_formatter(recommended_ra_saturn[cc]/15.,dec=3)+', '+$
;        number_formatter(recommended_dec_saturn[cc],dec=3)+']'
;      printf,unit,'For Jupiter scanning, recommended boresight [RA,Dec] [hr,deg] = ['+$
;        number_formatter(recommended_ra_jupiter[cc]/15.,dec=3)+', '+$
;        number_formatter(recommended_dec_jupiter[cc],dec=3)+']'
;      printf,unit,'For Moon scanning,    recommended boresight [RA,Dec] [hr,deg] = ['+$
;        number_formatter(recommended_ra_moon[cc]/15.,dec=3)+', '+$
;        number_formatter(recommended_dec_moon[cc],dec=3)+']'
;      printf,unit,'For Cas A scanning,   recommended boresight [RA,Dec] [hr,deg] = ['+$
;        number_formatter(recommended_ra_casa[cc]/15.,dec=3)+', '+$
;        number_formatter(recommended_dec_casa[cc],dec=3)+']'
;      printf,unit,'\end{verbatim}'
      
  endfor

;   for cc = 0,schedule.ncommands -1  do begin
;       nn     = int2filestring(cc+1,3)
;       ;Show integration time and beam maps for calibrator commands
;       if schedule.command[cc].name eq 'calibrator_scan' then begin
;          det_index = where(focalplane.power eq 1)
;          ndet      = n_elements(det_index)
;          printf,unit,'\newpage'
;          printf,unit,'\begin{center}'
;          printf,unit,'%\begin{figure}'
;          nn           = int2filestring(cc+1,3)
;          plotrootname = 'command'+nn
;          psfile = '../../ps/'+plotrootname+'_integrationtime.ps'
;          printf,unit,'\includegraphics[width=90mm,angle=90]{'+psfile+'}'
;          printf,unit,'\begin{verbatim}'
;          printf,unit,command_to_string(schedule.command[cc])
;          printf,unit,'\end{verbatim}'
;          if ndet le 75 then begin
;             printf,unit,'\newpage'
;             for dd=0, ndet-1 do begin
;                index    = det_index(dd)
;                det_id   = strtrim(floor(focalplane[index].index),2)
;                psfile   = '../../ps/command'+nn+'_beammap_'+det_id+'.ps'
;                printf,unit,'\includegraphics[width=22mm,angle=90]{'+psfile+'}'
;             endfor
;          endif
;          printf,unit,'%\end{figure}'
;          printf,unit,'\end{center}'
;       endif
;    endfor
      
  ;Include dipole scan plots.
;  for cc = 0,schedule.ncommands -1  do begin
;     if schedule.command[cc].name eq 'cmb_dipole' then begin
;        nn           = int2filestring(cc+1,3)
;        plotrootname = 'command'+nn
;        printf,unit,'\begin{center}'
;        psfile = '../../ps/'+plotrootname+'_dipolescan.ps'
;        printf,unit,'\includegraphics[width=90mm,angle=90]{'+psfile+'}'
;        psfile = '../../ps/'+plotrootname+'_dipolescan_integrationtime.ps'
;        printf,unit,'\includegraphics[width=90mm,angle=90]{'+psfile+'}'
;        printf,unit,'\end{center}'
;        printf,unit,'\begin{verbatim}'
;        printf,unit,command_to_string(schedule.command[cc])
;        printf,unit,'\end{verbatim}'     
;     endif
;  endfor

  if(get_conditionnumber) then begin
     ; Plot condition number maps for each command
     printf,unit,'\newpage'
     printf,unit,'\begin{center}'
     psfile = '../../ps/schedule_conditionnumber.ps'
     printf,unit,'\includegraphics[width=80mm]{'+psfile+'}'
     printf,unit,'\end{center}'

     for cc = 0,schedule.ncommands -1  do begin
        nn     = int2filestring(cc+1,3)
        printf,unit,'\newpage'
        printf,unit,'\begin{center}'
        psfile='../../ps/command'+nn+'_conditionnumber.ps'
        printf,unit,'\includegraphics[width=80mm]{'+psfile+'}'
        printf,unit,'\end{center}'
        printf,unit,'\begin{verbatim}'
        printf,unit,command_to_string(schedule.command[cc])
        printf,unit,'\end{verbatim}'
     endfor
  endif

  ;--------------------
  ;Close the latex file
  ;--------------------
  latex_close_article,unit

  ;-----------------------------------------
  ;Compile the latex file and convert to pdf
  ;-----------------------------------------
  message,'Converting '+latex_file+'.dvi to pdf/ps',/continue
  spawn, 'cd '+docdir+' ; latex '+latex_file+'.tex'+redirect_string()+latex_file+'.log'
  spawn, 'cd '+docdir+' ; dvips '+latex_file+'.dvi'+redirect_string()+'dvips.log'  
;  spawn, 'cd '+outputdir+' ; dvipdf '+latex_file+'.dvi'  

end
