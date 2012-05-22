;----------------------------------------------------------------------------
; Gondola Pointing Simulator v1.0
;
; By Chaoyun Bao, bao@physics.umn.edu
;
;----------------------------------------------------------------------------


;---------------- Update all the parameters----------------------------------

PRO UPDATE_PARAMETERS
   COMMON easypoint_old_block,year_w,month_w,day_w,utc_w,lat_w,lon_w,$
	   gon_spd_w,gon_maxa_w,gon_starcamstop_w,elev_lo_w,$
	   elev_up_w,antisun_r_w,tsamp_w,taubolo_w,fknee_w,$
	   alpha_w,net_1_w,net_2_w,net_3_w,fwhm_w,fhwp_w,schd_w,$
	   outputdir_w,datafile_w,plotoption_w,session_name_w,$
	   svd_session_w,plottype,mission,default_session,session,flag,$
           buttons_base,schdfile,xmin_w,xmax_w,ymin_w,ymax_w,resize_base_w,$
           x_data,y_data,x_title,y_title,allowed_plot_range
  
   
   widget_control,year_w,get_value=year_u
   widget_control,month_w,get_value=month_u
   widget_control,day_w,get_value=day_u
   widget_control,utc_w,get_value=utc_u
   widget_control,lat_w,get_value=lat_u
   widget_control,lon_w,get_value=lon_u
   widget_control,gon_spd_w,get_value=gon_spd_u
   widget_control,elev_lo_w,get_value=elev_lo_u
   widget_control,elev_up_w,get_value=elev_up_u
   widget_control,antisun_r_w,get_value=antisun_r_u
   widget_control,gon_maxa_w,get_value=gon_maxa_u
   widget_control,gon_starcamstop_w,get_value=gon_starcamstop_u
   widget_control,tsamp_w,get_value=tsamp_u
   widget_control,taubolo_w,get_value=taubolo_u
   widget_control,fknee_w,get_value=fknee_u
   widget_control,alpha_w,get_value=alpha_u
   widget_control,net_1_w,get_value=net_1_u
   widget_control,net_2_w,get_value=net_2_u
   widget_control,net_3_w,get_value=net_3_u
   widget_control,fwhm_w,get_value=fwhm_u
   widget_control,fhwp_w,get_value=fhwp_u


   mission.year = year_u
   mission.month = month_u
   mission.day = day_u
   mission.launch_utc = utc_u
   mission.latitude_deg = lat_u
   mission.longitude_start_deg = lon_u
   mission.orbitspeed = gon_spd_u
   mission.elevation_lowerlimit_deg = elev_lo_u
   mission.elevation_upperlimit_deg = elev_up_u
   mission.antisun_radius_deg = antisun_r_u
   mission.maxaccel_deg = gon_maxa_u
   mission.starcamstop_sec = gon_starcamstop_u
   mission.tsamp_sec = tsamp_u
   mission.taubolo_sec = taubolo_u
   mission.fknee_hz = fknee_u
   mission.alpha = alpha_u
   mission.net_1 = net_1_u
   mission.net_2 = net_2_u 
   mission.net_3 = net_3_u
   mission.net = mission.net_1+' '+mission.net_2+' '+mission.net_3
   mission.fwhm = fwhm_u
   mission.fhwp_hz = fhwp_u
   
END



;----------- send the saved parameters to the GUI----------------------


PRO SET_PARAMETERS

   COMMON easypoint_old_block,year_w,month_w,day_w,utc_w,lat_w,lon_w,$
	   gon_spd_w,gon_maxa_w,gon_starcamstop_w,elev_lo_w,$
	   elev_up_w,antisun_r_w,tsamp_w,taubolo_w,fknee_w,$
	   alpha_w,net_1_w,net_2_w,net_3_w,fwhm_w,fhwp_w,$
	   schd_w,outputdir_w,datafile_w,plotoption_w,$
	   session_name_w,svd_session_w,plottype,mission,$
	   default_session,session,flag,buttons_base,schdfile,$
           xmin_w,xmax_w,ymin_w,ymax_w,resize_base_w,x_data,y_data,$
           x_title,y_title,allowed_plot_range  
   
   widget_control,year_w,set_value=mission.year
   widget_control,month_w,set_value=mission.month
   widget_control,day_w,set_value=mission.day
   widget_control,utc_w,set_value=mission.launch_utc
   widget_control,lat_w,set_value=mission.latitude_deg
   widget_control,lon_w,set_value=mission.longitude_start_deg
   widget_control,gon_spd_w,set_value=mission.orbitspeed
   widget_control,elev_lo_w,set_value=mission.elevation_lowerlimit_deg
   widget_control,elev_up_w,set_value=mission.elevation_upperlimit_deg
   widget_control,antisun_r_w,set_value=mission.antisun_radius_deg
   widget_control,gon_maxa_w,set_value=mission.maxaccel_deg
   widget_control,gon_starcamstop_w,set_value=mission.starcamstop_sec
   widget_control,tsamp_w,set_value=mission.tsamp_sec
   widget_control,taubolo_w,set_value=mission.taubolo_sec
   widget_control,fknee_w,set_value=mission.fknee_hz
   widget_control,alpha_w,set_value=mission.alpha
   widget_control,net_1_w,set_value=mission.net_1
   widget_control,net_2_w,set_value=mission.net_2
   widget_control,net_3_w,set_value=mission.net_3
   widget_control,fwhm_w,set_value=mission.fwhm
   widget_control,fhwp_w,set_value=mission.fhwp_hz
   
END
 




;---------------- Plot the desired data in the draw window----------------


PRO PLOT_DATA,drawid

  COMMON easypoint_old_block,year_w,month_w,day_w,utc_w,lat_w,$
	  lon_w,gon_spd_w,gon_maxa_w,gon_starcamstop_w,$
	  elev_lo_w,elev_up_w,antisun_r_w,tsamp_w,taubolo_w,$
	  fknee_w,alpha_w,net_1_w,net_2_w,net_3_w,fwhm_w,$
	  fhwp_w,schd_w,outputdir_w,datafile_w,plotoption_w,$
	  session_name_w,svd_session_w,plottype,mission,$
	  default_session,session,flag,buttons_base,schdfile,$
          xmin_w,xmax_w,ymin_w,ymax_w,resize_base_w,x_data,y_data,$
          x_title,y_title,allowed_plot_range  

  allowed_plot_range = fltarr(4)
  
  widget_control,datafile_w,get_value=pointing_dirfilename
  
  wset, drawid

  case plottype of

;----DEC vs RA------
      0: begin
          xfield  = 'RA'
          yfield  = 'DEC'
          xfactor = !radeg
          yfactor = !radeg
          x_title = 'RA [deg]'
          y_title = 'DEC [deg]'
      end
;----EL vs AZ------------
      1: begin
          xfield  = 'AZ'
          yfield  = 'EL'
          xfactor = !radeg
          yfactor = !radeg
          x_title = 'AZ [deg]'
          y_title = 'EL [deg]'
      end
;------DEC vs LST----------------    
      2: begin
          xfield  = 'LST'
          yfield  = 'DEC'
          xfactor = 1.
          yfactor = !radeg
          x_title = 'LST [hr]'
          y_title = 'DEC [deg]'
      end
;------RA vs LST----------    
      3: begin
          xfield  = 'LST'
          yfield  = 'RA'
          xfactor = 1.
          yfactor = !radeg
          x_title = 'LST [hr]'
          y_title = 'RA [deg]'
      end
;-------EL vs LST----------    
      4: begin
          xfield  = 'LST'
          yfield  = 'EL'
          xfactor = 1.
          yfactor = !radeg
          x_title = 'LST [hr]'
          y_title = 'EL [deg]'
      end
;-------AZ vs LST------------    
      5: begin
          xfield  = 'LST'
          yfield  = 'AZ'
          xfactor = 1.
          yfactor = !radeg
          x_title = 'LST [hr]'
          y_title = 'AZ [deg]'
      end
;-------DEC vs RJD-----------    
      6: begin
          xfield  = 'RJD'
          yfield  = 'DEC'
          xfactor = 1.
          yfactor = !radeg
          x_title = 'Julian Day - '+strtrim(long(!constant.rjd0),2)
          y_title = 'DEC [deg]'
      end
;------RA vs RJD---------------
      7: begin
          xfield  = 'RJD'
          yfield  = 'RA'
          xfactor = 1.
          yfactor = !radeg
          x_title = 'Julian Day - '+strtrim(long(!constant.rjd0),2)
          y_title = 'RA [deg]'
      end
;--------EL vs RJD-------------
      8: begin
          xfield  = 'RJD'
          yfield  = 'EL'
          xfactor = 1.
          yfactor = !radeg
          x_title = 'Julian Day - '+strtrim(long(!constant.rjd0),2)
          y_title = 'EL [deg]'
      end
;--------AZ vs RJD---------------
      9: begin
          xfield  = 'RJD'
          yfield  = 'AZ'
          xfactor = 1.
          yfactor = !radeg
          x_title = 'Julian Day - '+strtrim(long(!constant.rjd0),2)
          y_title = 'AZ [deg]'
      end
  endcase
  
  ;Read in data and rescale
  x_data = readfields(pointing_dirfilename,xfield)
  y_data = readfields(pointing_dirfilename,yfield)
  x_data = x_data*xfactor
  y_data = y_data*yfactor
  ;Plot data
  plot,x_data,y_data,psym=3,xtitle=x_title,ytitle=y_title,$
    position = [0.08,0.14,0.46,0.90],/ynozero
  
  allowed_plot_range[0]=floor(min(x_data))
  allowed_plot_range[1]=ceil(max(x_data))
  allowed_plot_range[2]=floor(min(y_data))
  allowed_plot_range[3]=ceil(max(y_data))
  
  widget_control,xmin_w,set_value=allowed_plot_range[0]
  widget_control,xmax_w,set_value=allowed_plot_range[1]
  widget_control,ymin_w,set_value=allowed_plot_range[2]
  widget_control,ymax_w,set_value=allowed_plot_range[3]
         
  widget_control,resize_base_w,sensitive = 1


END 





;----------------------Event Handler-------------------------------

PRO EASYPOINT_OLD_EVENT,event
  COMMON easypoint_old_block,year_w,month_w,day_w,utc_w,lat_w,$
	  lon_w,gon_spd_w,gon_maxa_w,gon_starcamstop_w,$
	  elev_lo_w,elev_up_w,antisun_r_w,tsamp_w,taubolo_w,$
	  fknee_w,alpha_w,net_1_w,net_2_w,net_3_w,fwhm_w,$
	  fhwp_w,schd_w,outputdir_w,datafile_w,plotoption_w,$
	  session_name_w,svd_session_w,plottype,mission,$
	  default_session,session,flag,buttons_base,schdfile,$
          xmin_w,xmax_w,ymin_w,ymax_w,resize_base_w,x_data,y_data,$
          x_title,y_title,allowed_plot_range  
  
  widget_control,event.id, get_uvalue=uval
  widget_control,event.top,get_uvalue=drawid

  
  case uval of

;--------update desired plot type---------

    'plot_list':begin
      plottype=event.index
  end




;--------generate schedulefile, run and plot--------

    'gen_schd':begin

     ;-----deactivates the buttons-----

      widget_control,/hourglass

      widget_control,buttons_base,sensitive = 0

      widget_control,resize_base_w,sensitive = 0

     ;-----update all the parameters-----

      update_parameters
      
     ;-----generating schedule file here-----

     ;-----set the save session flag-----

      flag=0

     ;-----after job done reactivate the bunttons-----

     widget_control,buttons_base,sensitive = 1

     widget_control,resize_base_w,sensitive = 1

 end





;--------run existing schedule and plot--------


    'run_schd':begin

     ;-----deactivates the buttons-----

      widget_control,/hourglass

      widget_control,buttons_base,sensitive = 0

      widget_control,resize_base_w,sensitive = 0

     ;-----get the mission parameters-----
      
      update_parameters
      
     ;-----get the schedulefile-----
      
      widget_control, schd_w, get_value=schdfile
      schedule=read_schedulefile(schdfile)

     ;-----Get desired output directory-----
      
      widget_control,outputdir_w,get_value=output

     ;-----simulate pointing-----

      simulate_pointing,schedule,mission

     ;-----set save session flag-----

      flag=1

     ;-----update existing data file to the just produced-----
 
      widget_control,datafile_w,set_value=output+'/output/dirfile'

      plot_data,drawid

      print,'Job Done'

     ;-----reactivate the buttons-----

      widget_control,buttons_base,sensitive = 1

      widget_control,resize_base_w,sensitive = 1
  end




;--------Save current session--------

    'save':begin

     widget_control,/hourglass

     ;-----Updates parameters-----

      update_parameters

     ;-----Get desired session name-----

      widget_control,session_name_w,get_value=sessionname

     ;---if no specified session name, 'easypoint' will be used---

      if sessionname eq '' then $
	  sessionname = 'easypoint'

     ; Get desired output directory

      widget_control,outputdir_w,get_value=output

     ; If just changed the parameters and nothing else has been done
     ; current parameter will be saved in sessionname.par file
     ; schedule and data will be current value in corresponding widget

      if flag eq 2 then begin

      ;-----update schedule and data files-----

        widget_control,schd_w,get_value=schdfile
        widget_control,datafile_w,get_value=datafile

      ;-----write session info-----

	session.parameterfile = output+'/'+sessionname+'.par'
        session.schedulefile = schdfile
        session.datafile = datafile

	write_parameterfile,output+'/'+sessionname+'.par',mission
	write_parameterfile,output+'/'+sessionname+'.ses',session            

      endif
      
     ; If an existing schedule file was run
     ; with indicated parameters and data was generated
     ; current parameter will be saved in sessionname.par file
     ; data will be saved in sessionname_output directory
     ; schedulefile info will be the location of the existing sch file

      if flag eq 1 then begin

       ;With the line below: the schdfile will be whatever current value
       ;it is in the schd_w widget, not necessarily the one corresponding
       ;to the current datafile
       ;Without the line below: since the run_sch function will update
       ;the schdfile, in that case the schedulefile and generated
       ;data in the session will match

        ;widget_control,schd_w,get_value=schdfile

       ;-----write session info-----


	session.parameterfile = output+'/'+sessionname+'.par'
	session.schedulefile = schdfile
	session.datafile = output+'/'+sessionname+'_output'

	write_parameterfile,output+'/'+sessionname+'.par',mission
	write_parameterfile,output+'/'+sessionname+'.ses',session

       ;-----rename the output directory-----

	spawn,'mv output/ '+sessionname+'_output/'

       ;-----after save file, update current existing files-----

        widget_control,datafile_w,set_value=session.datafile+'/dirfile'

      endif

      if flag eq 0 then begin

       ;-----write session info-----

	session.parameterfile = output+'/'+sessionname+'.par'
	session.shcedulefile = output+'/'+sessionname+'.sch'
	session.datafile = output+'/'+sessionname+'_output'

	write_parameterfile,output+'/'+sessionname+'.par',mission
	write_schedulefile,output+'/'+sessionname+'.sch',schedule
	write_parameterfile,output+'/'+sessionname+'.ses',session

       ;-----rename the output directory-----

	spawn,'mv output/ '+sessionname+'_output/'

       ;-----after save session, update current existing files-----

        widget_control,schd_w,set_value = session.schedulefile
        widget_control,datafile_w,set_value = session.datafile

    endif


     widget_control,svd_session_w,set_value = output+'/'+sessionname+'.ses'

     flag = 2

     ;-----indicate session saved-----
      
      print,'Session Saved'

    end




;--------open saved session--------

    'open':begin

      widget_control,/hourglass

      ;-----get desired session file location-----

        widget_control,svd_session_w,get_value=sessionfile

      ;-----read session info-----

        session = read_parameterfile(sessionfile)

      ;-----send session info to GUI-----

      mission = read_parameterfile(session.parameterfile)
      set_parameters
      
      widget_control,schd_w,set_value = session.schedulefile
      widget_control,datafile_w,set_value = session.datafile+'/dirfile'

      ;-----indicate session opened-----

      print,'session opened'

   end



;--------plot the desired data--------

   'plot_dt':begin

     ;-----deactivates the buttons-----

      widget_control,/hourglass
      widget_control,buttons_base,sensitive = 0
      widget_control,resize_base_w,sensitive = 0

      ;flag=2

      print,'reading files....'
     
      plot_data,drawid
     
      print,'Finished Plotting'        
     
      widget_control,buttons_base,sensitive = 1
      widget_control,resize_base_w,sensitive = 1

  end



;--------resize the plot------------------

    'zoom_in':begin

      widget_control,xmin_w,get_value = x_min
      widget_control,xmax_w,get_value = x_max
      widget_control,ymin_w,get_value = y_min
      widget_control,ymax_w,get_value = y_max

      print,x_min,x_max,y_min,y_max


      if (x_min lt allowed_plot_range[0] Or x_max gt allowed_plot_range[1] $
          Or y_min lt allowed_plot_range[2] Or y_max gt allowed_plot_range[3])$
       
        then begin

        answer = dialog_message('Plot range beyond allowed range!',$
                  dialog_parent = event.top)
    endif else if (x_min ge x_max Or y_min ge y_max) then begin
        answer = dialog_message('Wrong minimum and maximum values!',$
                  dialog_parent = event.top)

        endif else begin

      wset,drawid
      plot,x_data,y_data,psym=3,xtitle=x_title,ytitle=y_title,$
           position = [0.08,0.14,0.46,0.90],xrange=[x_min,x_max],yrange=[y_min,y_max],/ynozero
  endelse


end



;--------return to the original size plot---------------

    'return_plot':begin

       wset,drawid
       plot,x_data,y_data,psym=3,xtitle=x_title,ytitle=y_title,$
           position = [0.08,0.14,0.46,0.90],/ynozero

   end




;--------quit the easypoint program--------

   'quit':begin
     answer = dialog_message('Make sure you save desired information before quit',$
                             dialog_parent=event.top)

     answer = dialog_message('   Really Quit?   ',/question, $
			     dialog_parent=event.top,title='Quit Easypoint?',/default_no)

     if answer eq 'Yes' then begin

     print,'Easypoint closed'
     widget_control, event.top, /destroy

 endif

end


endcase


END



;---------------Create a widget containing a output window and parameters---------------

PRO EASYPOINT_OLD

  COMMON easypoint_old_block,year_w,month_w,day_w,utc_w,lat_w,$
	  lon_w,gon_spd_w,gon_maxa_w,gon_starcamstop_w,$
	  elev_lo_w,elev_up_w,antisun_r_w,tsamp_w,taubolo_w,$
	  fknee_w,alpha_w,net_1_w,net_2_w,net_3_w,fwhm_w,$
	  fhwp_w,schd_w,outputdir_w,datafile_w,plotoption_w,$
	  session_name_w,svd_session_w,plottype,mission,$
	  default_session,session,flag,buttons_base,schdfile,$
          xmin_w,xmax_w,ymin_w,ymax_w,resize_base_w,x_data,y_data,$
          x_title,y_title,allowed_plot_range
 
  
  currentdir = cwd()

  screen_size = get_screen_size()

  if screen_size[0] ge 1440 And screen_size[1] ge 750 then begin

  base = widget_base(column=2,title='Easypoint Gondola Pointing Simulator v1.0',$
          scr_xsize=1440,scr_ysize=750)

  endif else if screen_size[0] lt 1440 And screen_size[1] ge 750 then begin

  print,'flag'

  base = widget_base(column=2,title='Easypoint Gondola Pointing Simulator v1.0',$
               scr_xsize=screen_size[0],scr_ysize=750,/scroll)

  endif else if screen_size[0] ge 1440 And screen_size[1] lt 750 then begin

  base = widget_base(column=2,title='Easypoint Gondola Pointing Simulator v1.0',$
               scr_xsize=1440,scr_ysize=screen_size[1],/scroll)
  
  endif else begin

  base = widget_base(column=2,title='Easypoint Gondola Pointing Simulator v1.0',$
               scr_xsize=screen_size[0],scr_ysize=screen_size[1],/scroll)
  

  endelse

  

  left = widget_base(base,/column)
  right = widget_base(base,/column)

  
 ;-----Read default session information-----

  session = read_parameterfile(!HEXSKYROOT+'/schedulefiles/.default.ses')
  for i=0,n_tags(session)-1 do begin
    session.(i)=!HEXSKYROOT+'/'+session.(i)
  endfor 


 ;-----Store default session information-----

  default_session=session

 ;-----Read default mission parameter file-----

  mission = read_parameterfile(session.parameterfile)



 ; save session flag
 ; flag=0:schedule file generated from the indicated parameter 
 ; flag=1:existing schedule file
 ; flag=2:no schedule file been run yet
 ; Default setting flag=2

  flag = 2


 ;-----widget for input parameters-----

  input_base = widget_base(left,frame=3,/column)

  input_base_label = widget_label(input_base,value='INPUT MISSION PARAMETERS',font='!5')


 ;-----observation date-----

  date_base = widget_base(input_base,row=1,/align_center)

  date_base_label = widget_label(date_base,value='Observation Date:')

  year_w = cw_field(date_base,title='Year:',value=mission.year,xsize=5)

  month_w = cw_field(date_base,title='Month:',value=mission.month,xsize=5)
  
  day_w = cw_field(date_base,title='Date:',value=mission.day,xsize=5)
  
  utc_w = cw_field(date_base,title='Launch UTC:',value=mission.launch_utc,xsize=5)
  

 ;-----initial coordinates-----
  
  cord_base = widget_base(input_base,row=1,/align_center)
  
  cord_base_label = widget_label(cord_base,value='Initial Coordinates:   ')
  
  lat_w = cw_field(cord_base,title='Latitude(deg North):',value=mission.latitude_deg,xsize=10)
  
  lon_w = cw_field(cord_base,title='Initial Longitude(deg East):',$
		   value=mission.longitude_start_deg,xsize=10)
  
 ;-----gondola parameters-----
  
  gon_par_base = widget_base(input_base,column=1,/align_center)
  
  gon_par_label = widget_label(gon_par_base,value='Gondola Parameters')
  
  gon_par_sbase = widget_base(gon_par_base,row=1,/align_center)
  
  gon_spd_w = cw_field(gon_par_sbase,title='OrbitSpeed(isolat. orbits/day):',$
		       value=mission.orbitspeed,xsize=5)
  
  gon_maxa_w = cw_field(gon_par_sbase,title='MaxAcceleration(deg/s/s):',$
			value=mission.maxaccel_deg,xsize=5)

  gon_starcamstop_w = cw_field(gon_par_sbase,title='StarCamStopTime(s):',$
			       value=mission.starcamstop_sec,xsize=5)
  
 ;-----scan constraints-----

  scan_cons_base = widget_base(input_base,column=1,/align_center)

  scan_cons_label = widget_label(scan_cons_base,value='Scanning Constraints')

  scan_cons_sbase = widget_base(scan_cons_base,row=1,/align_center)
  
  elev_lo_w = cw_field(scan_cons_sbase,title='Min elevation (deg):',$
		       value=mission.elevation_lowerlimit_deg,xsize=5)
  
  elev_up_w = cw_field(scan_cons_sbase,title='Max elevation (deg):',$
		       value=mission.elevation_upperlimit_deg,xsize=5)
  
  antisun_r_w = cw_field(scan_cons_sbase,title='Antisun direction(deg):',$
			 value=mission.antisun_radius_deg,xsize=5)
  
 ;-----Noise and instrument parameters-----
  
  ns_instr_base = widget_base(input_base,column=1,/align_center)

  ns_instr_label = widget_label(ns_instr_base,value='Noise and Instrument Parameters')

  ns_instr_sbase = widget_base(ns_instr_base,column=3,/align_center)
 
  tsamp_w = cw_field(ns_instr_sbase,title='Sampling time(sec):',$
		     value=mission.tsamp_sec,xsize=15)

  taubolo_w = cw_field(ns_instr_sbase,title='Bolometer Time Constant(sec):',$
		       value=mission.taubolo_sec,xsize=10)

  fknee_w = cw_field(ns_instr_sbase,title='Knee Frequency(Hz)P:',$
		     value=mission.fknee_hz,xsize=5)

  alpha_w = cw_field(ns_instr_sbase,title='Alpha:',value=mission.alpha,xsize=5)

  net_1_w = cw_field(ns_instr_sbase,title='NET_1:',value=mission.net_1,xsize=10)
 
  net_2_w = cw_field(ns_instr_sbase,title='NET_2:',value=mission.net_2,xsize=10)
 
  net_3_w = cw_field(ns_instr_sbase,title='NET_3:',value=mission.net_3,xsize=10)

  fwhm_w = cw_field(ns_instr_sbase,title='FWHM (space between each):',$
		    value=mission.fwhm,xsize=10)

  fhwp_w = cw_field(ns_instr_sbase,title='Frequency of HWP(Hz):',$
		    value=mission.fhwp_hz,xsize=5)


 ;-----Output parameters-----

  output_base = widget_base(left,column=1,frame=3,/align_center)

  output_base_label = widget_label(output_base,value='OUTPUT PARAMETERS')

  outputdir_w = cw_field(output_base,title=$
			 'Output Directory(Current directory by default):',$
			 value=currentdir,xsize=60)

  session_name_w = cw_field(output_base,title='Session Name:',value='easypoint',xsize=40)

 ;-----Plot Option-----

  plotoption=['DEC vs RA','EL vs AZ','DEC vs LST','RA vs LST',$
	      'EL vs LST','AZ vs LST','DEC vs JD','RA vs JD',$
	      'EL vs JD','AZ vs JD']

 ;-----Default plot is DEC vs RA-----

  plottype=0

  plotoption_w = widget_droplist(output_base,value=plotoption,$
				 title='Choose output plot type:',$
				 uvalue='plot_list')

 ;-----Dealing with existing files-----

  exist_file_base = widget_base(left,column=1,frame=3,/align_center)

  exist_file_label = widget_label(exist_file_base,value='Use Existing Files')

  svd_session_w = cw_field(exist_file_base,title='Use Saved Session:',$
			   value=currentdir+'/',xsize=80)

  schd_w = cw_field(exist_file_base,title='Use Existing Schedule File:',$
		    value=session.(1),xsize=80)
 
  datafile_w = cw_field(exist_file_base,title='Existing Data File:',$
			value=session.(2),xsize=80)
 

 ;-----Set up output plot region-----

  draw = widget_draw(right,xsize=720,ysize=360,frame=5)

 ;-----Plot Resize Option region------

  resize_base_w = widget_base(right,column=1,frame=3,/align_center)

  resize_label_w = widget_label(resize_base_w,value='Resize plot range')

  range_base_w = widget_base(resize_base_w,row=1,/align_center)

  xmin_w = cw_field(range_base_w,title='min x:',/float,xsize=18)
  xmax_w = cw_field(range_base_w,title='max x:',/float,xsize=18)
  ymin_w = cw_field(range_base_w,title='min y:',/float,xsize=18)
  ymax_w = cw_field(range_base_w,title='max y:',/float,xsize=18)

  resize_button_base_w = widget_base(resize_base_w,row=1,/align_center)

  resize_plot = widget_button(resize_button_base_w,value='Zoom in the plot',xsize=200,$
                 ysize=40,uval='zoom_in')
  
  return_plot = widget_button(resize_button_base_w,value='Return to original plot',$
                 xsize=200,ysize=40,uval='return_plot')


 ;-----Buttons-----

  buttons_base = widget_base(right,column=2,/align_center)

  gen_schedule = widget_button(buttons_base,$
			       value='Generate Schedule File and plot',$
			       uval='gen_schd',xsize=220,ysize=50)

  run_schedule = widget_button(buttons_base,$
			       value='Run Existing Schedule and plot',$
			       uval='run_schd',xsize=220,ysize=50)

  plot_data = widget_button(buttons_base,$
			    value='Plot Existing Simulation Data',$
			    uval='plot_dt',xsize=220,ysize=50)

  save_session = widget_button(buttons_base,value='Save Current Session',$
			       uvalue='save',xsize=220,ysize=50)

  open_session = widget_button(buttons_base,value='Open Saved Session',$
			       uvalue='open',xsize=220,ysize=50)

  doquit = widget_button(buttons_base,value='Quit',uval='quit',$
			 xsize=220,ysize=50)

 ;-----Realize widgets and register-----
 
  widget_control,base,/realize

  widget_control,resize_base_w,sensitive = 0

  widget_control,draw,get_value=drawID

  widget_control,base,set_uvalue=drawID

  xmanager,'EASYPOINT_OLD',base


END
