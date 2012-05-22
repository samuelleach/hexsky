;----------------------------------------------------------------------------
; Gondola Pointing Simulator v1.1
;
; By Chaoyun Bao, bao@physics.umn.edu
;
;----------------------------------------------------------------------------


       
FUNCTION UPDATE_TEST_CMD,type_list_w,time_w,pars_w,comment_w

  cmd_type_list = ['other',get_command_list()]
  test_command = {command}

  cmd_type = widget_info(type_list_w,/droplist_select)

  test_command.name=cmd_type_list[cmd_type]

  widget_control,time_w,get_value=time
  widget_control,pars_w,get_value=pars
  widget_control,comment_w,get_value=comment

  command_par = time+pars

  test_command.parameters = get_parameters(['',command_par],nparameters=nparameters)
  test_command.nparameters = nparameters

  test_command.comment = comment

; need to update on this part, but follow read_schedule.pro right now

  test_command.time_to_next_command = 24.
  test_command.expected_duration = 4.
    
  return,test_command  

END



PRO PLOT_DATA,drawid,x_name,y_name,pointing_dirfilename
  COMMON easypoint_block,command_date_w,start_date_w,command_loc_w,$
                         launch_loc_w,orbit_speed_w,sites_list,min_elev_w,$
                         max_elev_w,antisun_w,cur_cmd_num_w,tot_cmd_num_w,$
                         cur_cmd_w,cmd_type_list,test_cmd_type_w,test_cmd_sttime_w,$
                         test_cmd_par_w,test_cmd_comment_w,targets_list,target_ra_w,$
                         target_dec_w,calibrators_list,calibrator_ra_w,$
                         calibrator_dec_w,expt_duration_w,time_till_next_w,$
                         cmd_tsamp_w,cmd_warning_w,misn_drn_w,misn_tsamp_w,$
                         misn_warning_w,cali_offset_w,proj_list,rot_ang_w,load_schd_w,$
                         save_schd_w,save_image_w,open_ses_w,test_cmd_type,$
                         schedule,current_cmd_num,current_command,test_command,mission,$
                         test_schedule

   wset,drawid

   if x_name eq 'LST' then x_title = x_name+' [day]' $
   else x_title = x_name+' [deg]'

   y_title = y_name+' [deg]'
   x_factor = !radeg
   y_factor = !radeg

   x_data = readfields(pointing_dirfilename,x_name)
   y_data = readfields(pointing_dirfilename,y_name)
   x_data = x_data*x_factor
   y_data = y_data*y_factor
   ;Plot data
   plot,x_data,y_data,psym=3,xtitle=x_title,ytitle=y_title,$
     position = [0.08,0.14,0.46,0.90],/ynozero

END


PRO UPDATE_CMD_TIME

  COMMON easypoint_block,command_date_w,start_date_w,command_loc_w,$
                         launch_loc_w,orbit_speed_w,sites_list,min_elev_w,$
                         max_elev_w,antisun_w,cur_cmd_num_w,tot_cmd_num_w,$
                         cur_cmd_w,cmd_type_list,test_cmd_type_w,test_cmd_sttime_w,$
                         test_cmd_par_w,test_cmd_comment_w,targets_list,target_ra_w,$
                         target_dec_w,calibrators_list,calibrator_ra_w,$
                         calibrator_dec_w,expt_duration_w,time_till_next_w,$
                         cmd_tsamp_w,cmd_warning_w,misn_drn_w,misn_tsamp_w,$
                         misn_warning_w,cali_offset_w,proj_list,rot_ang_w,load_schd_w,$
                         save_schd_w,save_image_w,open_ses_w,test_cmd_type,$
                         schedule,current_cmd_num,current_command,test_command,mission,$
                         test_schedule

  hour = current_command.parameters[1]+schedule.hour_utc
  day  = current_command.parameters[0]+schedule.day -1
  day  = fix(day + fix(hour/24))
  hour = hour mod 24

  utc = string(hour,format='(f5.2)')
  day = strtrim(string(day),2)
  month = strtrim(string(schedule.month),2)
  year = strtrim(string(schedule.year),2)

  widget_control,command_date_w,set_value=utc+' '+day+' '+month+' '+year  

END

       

FUNCTION COMMAND_TYPE,cmd_type

  cmd_type_list = get_command_list()

  for i=0,n_elements(cmd_type_list)-1 do begin
   if cmd_type_list(i) eq cmd_type then $
    return,i+1
  endfor

;for future reference, if none of the scan modes, return 0
  return,0
  
END


FUNCTION COMMAND_LOC,start_lon,obt_spd,cmd_day,cmd_hr

  day = cmd_day-1+cmd_hr/24.
  delta_lon = obt_spd * day *360
  final_lon = strtrim(string(start_lon+delta_lon),2)

  return,final_lon

END

  



PRO INITIALIZE_TEST_CMD,command,type_wlist,time_w,par_w,comment_w

;  cmd_type_list = ['other','calibrator','CMB','cmb_dipole','science_scan']
  cmd_type_list = ['other',get_command_list()]
  widget_control,type_wlist,set_droplist_select = $
		  command_type(command.name)
 
  ;Extract the parameter format substring from the command format.
  cmd_format       = command_format(command.name)
  firstcomma       = strpos(cmd_format,',')
  secondcomma      = strpos(cmd_format,',',firstcomma+1)
  thirdcomma      = strpos(cmd_format,',',secondcomma+1)
  fourthcomma      = strpos(cmd_format,',',thirdcomma+1)
  parameter_format ='(' + strmid(cmd_format,fourthcomma+1)

  if command.nparameters gt 0 then begin
    time = strtrim(string(fix(command.parameters[0])),2)+' '+$
           strtrim(string(command.parameters[1],format='(f6.2)'),2)

    par =  strtrim(string(command.parameters[2:command.nparameters-1],$
                          format=parameter_format),2)
  endif else begin
    time = ''
    par = ''
  endelse


  comment = command.comment
  
  widget_control,time_w,set_value = time
  widget_control,par_w,set_value = par
  widget_control,comment_w,set_value=comment

END


PRO EASYPOINT_EVENT,event

  COMMON easypoint_block,command_date_w,start_date_w,command_loc_w,$
                         launch_loc_w,orbit_speed_w,sites_list,min_elev_w,$
                         max_elev_w,antisun_w,cur_cmd_num_w,tot_cmd_num_w,$
                         cur_cmd_w,cmd_type_list,test_cmd_type_w,test_cmd_sttime_w,$
                         test_cmd_par_w,test_cmd_comment_w,targets_list,target_ra_w,$
                         target_dec_w,calibrators_list,calibrator_ra_w,$
                         calibrator_dec_w,expt_duration_w,time_till_next_w,$
                         cmd_tsamp_w,cmd_warning_w,misn_drn_w,misn_tsamp_w,$
                         misn_warning_w,cali_offset_w,proj_list,rot_ang_w,load_schd_w,$
                         save_schd_w,save_image_w,open_ses_w,test_cmd_type,$
                         schedule,current_cmd_num,current_command,test_command,mission,$
                         test_schedule

   widget_control,event.id, get_uvalue=uval
   widget_control,event.top,get_uvalue=drawid

   case uval of

    'site_list':begin

       site_index = event.index
       if sites_list[site_index].name eq 'User Defined' then begin
        widget_control,launch_loc_w,set_value='0.00  0.00'
       endif else begin
        site_loc = sites_list[site_index].latitude+' '+$
                   sites_list[site_index].longitude
        widget_control,launch_loc_w,set_value=site_loc
       endelse

    end

    'target_list':begin

       target_index = event.index
       if targets_list[target_index].name eq 'User Defined' then begin
        widget_control,target_ra_w,set_value='0.00'
        widget_control,target_dec_w,set_value='0.00'
       endif else $
         if targets_list[target_index].RA eq -1 then begin
;           juldate,[schedule.year,schedule.month,$
;                    schedule.day+current_command.parameters[0]-1],jd
            juldate,[mission.year,mission.month,$
                     mission.day+current_command.parameters[0]-1],jd
           planet_coords,jd+2400000,ra,dec,planet=targets_list[target_index].name,/jd
           
           widget_control,target_ra_w,set_value = strtrim(string(ra/15,format='(f6.3)'),2)
           widget_control,target_dec_w,set_value = strtrim(string(dec,format='(f7.3)'),2)
       endif else begin
        widget_control,target_ra_w, set_value=targets_list[target_index].RA
        widget_control,target_dec_w,set_value=targets_list[target_index].DEC      
       endelse

    end

    'calibrator_list':begin

       calibrator_index = event.index
       if calibrators_list[calibrator_index].name eq 'User Defined' then begin
        widget_control,calibrator_ra_w,set_value='0.00'
        widget_control,calibrator_dec_w,set_value='0.00'
       endif else $

         if calibrators_list[calibrator_index].RA eq -1 then begin
;           juldate,[schedule.year,schedule.month,$
;                    schedule.day+current_command.parameters[0]-1],jd
            juldate,[mission.year,mission.month,$
                     mission.day+current_command.parameters[0]-1],jd
           planet_coords,jd+2400000,ra,dec,planet=calibrators_list[calibrator_index].name,/jd
           
           widget_control,calibrator_ra_w,set_value = strtrim(string(ra/15,format='(f6.3)'),2)
           widget_control,calibrator_dec_w,set_value = strtrim(string(dec,format='(f7.3)'),2)
        endif else begin
        widget_control,calibrator_ra_w, $
                       set_value=calibrators_list[calibrator_index].RA
        widget_control,calibrator_dec_w,$
                       set_value=calibrators_list[calibrator_index].DEC      
       endelse

    end

    'projection_list':begin

      proj_type = proj_list[event.index]

    end

    'goto_cmd':begin

      widget_control,cur_cmd_num_w,get_value=cmd_num_str
      cmd_num = fix(cmd_num_str)

      widget_control,tot_cmd_num_w,get_value=tot_num_str
      tot_num = fix(tot_num_str)

      if cmd_num ge 1 AND cmd_num le tot_num then begin      
       current_command = schedule.command[cmd_num-1]
       cur_command = command_to_string(current_command)      
       widget_control,cur_cmd_w,set_value = cur_command

       test_command = current_command

       current_cmd_num = cmd_num

       initialize_test_cmd,test_command,test_cmd_type_w,$
                           test_cmd_sttime_w,test_cmd_par_w,$
                           test_cmd_comment_w

      endif else begin
       answer = dialog_message('Invalid command number!',$
                             dialog_parent=event.top)
      endelse

      update_cmd_time

      cur_command_loc = mission.latitude_deg+' '+$
                    command_loc(float(mission.longitude_start_deg),float(mission.orbitspeed),$
                            current_command.parameters[0],current_command.parameters[1])
      
      widget_control,command_loc_w,set_value=cur_command_loc

    end



    'append_cmd':begin

     current_command = {command}
     test_command = current_command

     schedule.command[schedule.ncommands] = current_command
     schedule.ncommands+=1

     widget_control,cur_cmd_num_w,set_value=schedule.ncommands
     widget_control,tot_cmd_num_w,set_value=schedule.ncommands
     widget_control,cur_cmd_w,set_value=command_to_string(current_command)
     initialize_test_cmd,test_command,test_cmd_type_w,$
                         test_cmd_sttime_w,test_cmd_par_w,$
                         test_cmd_comment_w


    end

    'new_date':begin

      widget_control,start_date_w,get_value=new_start_date

      utc = 0.0
      day = 0
      month = 0
      year = 0

      reads,new_start_date,utc,day,month,year


      mission.launch_utc = utc
      mission.day = day
      mission.month = month
      mission.year = year

      schedule.hour_utc = utc
      schedule.day = day
      schedule.month = month
      schedule.year = year

      update_cmd_time

    end

    'insert_target':begin
 
      test_command = update_test_cmd(test_cmd_type_w,test_cmd_sttime_w,$
                                         test_cmd_par_w,test_cmd_comment_w)
    
      if test_command.name eq 'CMB' OR test_command.name eq 'science_scan'$
        then begin
         widget_control,target_ra_w, get_value = ra
         widget_control,target_dec_w,get_value = dec

         test_command.parameters[2] = float(ra)*15
         test_command.parameters[3] = float(dec)

         initialize_test_cmd,test_command,test_cmd_type_w,$
                             test_cmd_sttime_w,test_cmd_par_w,$
                             test_cmd_comment_w
      endif else begin

        warng = dialog_message('Wrong command type!',$
                                dialog_parent=event.top)
      endelse


    end

    'insert_calibrator':begin
      test_command = update_test_cmd(test_cmd_type_w,test_cmd_sttime_w,$
                                         test_cmd_par_w,test_cmd_comment_w)

      if test_command.name eq 'calibrator' then begin
         widget_control,calibrator_ra_w, get_value = ra
         widget_control,calibrator_dec_w,get_value = dec

         test_command.parameters[2] = float(ra)*15
         test_command.parameters[3] = float(dec)

         initialize_test_cmd,test_command,test_cmd_type_w,$
                             test_cmd_sttime_w,test_cmd_par_w,$
                             test_cmd_comment_w
      endif else begin

        warng = dialog_message('Wrong command type!',$
                                dialog_parent=event.top)
      endelse
      

    end

    'reset_test_cmd':begin

       initialize_test_cmd,current_command,test_cmd_type_w,$
                           test_cmd_sttime_w,test_cmd_par_w,$
                           test_cmd_comment_w
      
    end

    'replace_cmd':begin

      current_command = test_command
      schedule.command[current_cmd_num-1] = current_command
      widget_control,cur_cmd_w,set_value=command_to_string(current_command)
      

    end

    'cmd_help':begin
    
     cmd_structure_base = widget_base(title='Gondola scan command structure',$
                                      /column,/base_align_center)
     cmd_strc_label = widget_label(cmd_structure_base,$
                                  value='Command list [deg] and [deg/s] units')
     cmd_strc_sub_base = widget_base(cmd_structure_base,/column,$
                                     /base_align_left)

     ;Loop over available commands and print to the widget
     command=get_command_list()
     for cc=0,n_elements(command)-1 do begin
         cmd_format=command_format(command[cc],syntax=syntax)
         commandstring='                '
         strput,commandstring,command[cc],0
         cmd_cmb_label=widget_label(cmd_strc_sub_base,$
                      value=commandstring+syntax)
     endfor


     widget_control,cmd_structure_base,/realize
   

    end

    'simulate_cur_cmd':begin

      test_schedule = schedule
      test_schedule.ncommands = 1
      test_schedule.command[0]=current_command

      simulate_pointing,test_schedule,mission

      file = './output/dirfile'
      x_name = 'AZ'
      y_name = 'EL'
      plot_data,drawid,x_name,y_name,file

    end

    'simulate_test_cmd':begin

      test_command = update_test_cmd(test_cmd_type_w,test_cmd_sttime_w,$
                                         test_cmd_par_w,test_cmd_comment_w)

      test_schedule = schedule
      test_schedule.ncommands = 1
      test_schedule.command[0]=test_command

      simulate_pointing,test_schedule,mission
      file = './output/dirfile'
      x_name = 'AZ'
      y_name = 'EL'
      plot_data,drawid,x_name,y_name,file


    end

    'simulate_mission':begin

      test_schedule = schedule
      simulate_pointing,test_schedule,mission
      file = './output/dirfile'
      x_name = 'AZ'
      y_name = 'EL'
      plot_data,drawid,x_name,y_name,file


    end
    
    'elev_plot':begin

      file = './output/dirfile'
      x_name = 'LST'
      y_name = 'EL'
      plot_data,drawid,x_name,y_name,file

    end

    'az_el_plot':begin

      file = './output/dirfile'
      x_name = 'AZ'
      y_name = 'EL'
      plot_data,drawid,x_name,y_name,file

    end

    'calibrator_map':begin

     read_tqu,!HEXSKYROOT+'/data/dust_carlo_150ghz_512_radec.fits',dust150

     outputdir = './output'
     pointing_dirfilename = './output/dirfile' 
     focalplane = get_boresight()

     for cc = 0,test_schedule.ncommands -1  do begin

      command_hitmap = get_hitmap(pointing_dirfilename, focalplane,nside_hitmap=512,$
                                  first_sample=test_schedule.command[cc].first_sample_index,$
                                  nsample=test_schedule.command[cc].nsample)
      
      RA       = test_schedule.command[cc].parameters[2]
      Dec      = test_schedule.command[cc].parameters[3]
      rot      = [ra,dec]
      nn       = int2filestring(cc+1,3)
      duration = number_formatter(test_schedule.command[cc].expected_duration,dec=2)
      ;Plot hits
      gnomview,command_hitmap,$
        rot=rot,window=2,grat=5,glsize=1.5,coord=['C','C'],res=3,$
        title='Command '+strtrim(cc+1,2)+ ' ('+test_schedule.command[cc].name+') hits',$
        subtitle='Total time = '+duration+' hrs',$
        png=outputdir+'/png/command'+nn+'_hits.png'

      endfor
      

    end

    'sky_plot':begin
    end

    'new_schd':begin
    end

    'load_schd':begin
    end

    'save_schd':begin
    end

    'save_image':begin
    end

    'open_session':begin
    end

    'save_session':begin
    end

    'write_hex_par':begin
    end

    'quit':begin
     answer = dialog_message('All unsaved information will be lost!',$
                             dialog_parent=event.top)

     answer = dialog_message('   Really Quit?   ',/question, $
			     dialog_parent=event.top,title='Quit Easypoint?',$
                             /default_no)

     if answer eq 'Yes' then begin

     print,'Easypoint closed'
     widget_control, event.top, /destroy

     endif

    end       


endcase



    
END




PRO EASYPOINT

  COMMON easypoint_block,command_date_w,start_date_w,command_loc_w,$
                         launch_loc_w,orbit_speed_w,sites_list,min_elev_w,$
                         max_elev_w,antisun_w,cur_cmd_num_w,tot_cmd_num_w,$
                         cur_cmd_w,cmd_type_list,test_cmd_type_w,test_cmd_sttime_w,$
                         test_cmd_par_w,test_cmd_comment_w,targets_list,target_ra_w,$
                         target_dec_w,calibrators_list,calibrator_ra_w,$
                         calibrator_dec_w,expt_duration_w,time_till_next_w,$
                         cmd_tsamp_w,cmd_warning_w,misn_drn_w,misn_tsamp_w,$
                         misn_warning_w,cali_offset_w,proj_list,rot_ang_w,load_schd_w,$
                         save_schd_w,save_image_w,open_ses_w,test_cmd_type,$
;before: widgets and lists, after: command structures etc
                         schedule,current_cmd_num,current_command,test_command,mission,$
                         test_schedule


 
  currentdir = cwd()

  screen_size = get_screen_size()

;  base = widget_base(column=2,title='Easypoint Gondola Pointing Simulator v1.1',$
;               scr_xsize=screen_size[0],scr_ysize=screen_size[1]-80,/scroll)
  
 
  base = widget_base(column=2,title='Easypoint Gondola Pointing Simulator v1.1',$
                     /base_align_center)
  left = widget_base(base,/column,/base_align_center)
  right = widget_base(base,/column,/base_align_center)

 ;-----Read default session information-----

  session = read_parameterfile(!HEXSKYROOT+'/schedulefiles/.default.ses')
  for i=0,n_tags(session)-1 do begin
    session.(i)=!HEXSKYROOT+'/'+session.(i)
  endfor 


 ;-----Store default session information-----

  default_session=session

 ;-----Read default files-----

  mission = read_parameterfile(session.parameterfile)
  schedule = read_schedulefile(session.schedulefile)

  current_cmd_num = 1
  current_command = schedule.command[current_cmd_num-1]
  
 ;-----widget for mission parameters-----

  mission_input_base = widget_base(left,/column,/base_align_center,frame=2)
  mission_input_label = widget_label(mission_input_base,$
                                     value='Mission date and location')
  mission_par_base = widget_base(mission_input_base,/row)


 ;---widget for date---

  date_base = widget_base(mission_par_base,/column,/base_align_right)
  date_unit_label = widget_label(date_base,value='UTC dd mm yyyy   ')

  cur_command_date = strtrim(string(schedule.hour_utc,format='(f5.2)'),2)+' '+$
                     strtrim(string(schedule.day),2)+' '+$
                     strtrim(string(schedule.month),2)+' '+$
                     strtrim(string(schedule.year),2)

  command_date_w = cw_field(date_base,title='Command time:',$
                            value=cur_command_date,/noedit,xsize=15)

  start_date = mission.launch_utc+' '+mission.day+' '+$
                       mission.month+' '+mission.year

  start_date_w = cw_field(date_base,title='Launch time:',$
                          value=start_date,xsize=15)


 ;---widget for location coordinate---

  loc_base = widget_base(mission_par_base,/column,/base_align_right)
  loc_unit_label = widget_label(loc_base,value='Lat N Lon E [deg]')

  cur_command_loc = mission.latitude_deg+' '+$
                    command_loc(float(mission.longitude_start_deg),float(mission.orbitspeed),$
                            current_command.parameters[0],current_command.parameters[1])

  command_loc_w = cw_field(loc_base,title='Command loc:',$
                           value=cur_command_loc,/noedit,xsize=15)

  launch_location = mission.latitude_deg+' '+mission.longitude_start_deg
  launch_loc_w = cw_field(loc_base,title='Launch loc:',$
                          value=launch_location,xsize=15)



 ;---widget for location option and orbit speed-----

  loc_obtspd_base = widget_base(mission_par_base,/column)

  orbit_unit_label = widget_label(loc_obtspd_base,value='Orbits/day')
  orbit_speed_w = cw_field(loc_obtspd_base,title='Isolat orbit spd',$
                           value=mission.orbitspeed,xsize=5)

  sites_list = read_coord_data(!HEXSKYROOT+'/data/sites.dat',1)
  loc_droplist = widget_droplist(loc_obtspd_base,value=sites_list.name,$
                                 uvalue='site_list')



 ;-----widget for scanning constraints-----

  scan_constr_base = widget_base(left,/column,frame=2)
  scan_constr_label = widget_label(scan_constr_base,value='Scanning constraints [deg]')
  scan_par_base = widget_base(scan_constr_base,/row)
  min_elev_w = cw_field(scan_par_base,title='Min elevation:',$
                        value=mission.elevation_lowerlimit_deg,xsize=10)
  max_elev_w = cw_field(scan_par_base,title='  Max elevation:',$
                        value=mission.elevation_upperlimit_deg,xsize=10)
  antisun_w = cw_field(scan_par_base,title='  Antisun distance:',$
                        value=mission.antisun_radius_deg,xsize=10)


 ;-----widget for chopping constraints-----

 ; chop_constr_base = widget_base(left,/column,frame=2)
 ; chop_constr_label = widget_label(chop_constr_base,value='Chopping constraints')
 ; chop_par_base = widget_base(chop_constr_base,/row)
 ; starcam_stop_w = cw_field(chop_par_base,title='Starcam stop [s]:',$
 ;                           value=mission.starcamstop_sec,xsize=15)
 ; max_accel_w = cw_field(chop_par_base,title='      Max accel [deg/s/s]:',$
 ;                           value=mission.maxaccel_deg,xsize=15)


 ;----widget for command editor-----

  cmd_editor_base = widget_base(left,/column,/base_align_center,frame=2)
  cmd_editor_label = widget_label(cmd_editor_base,value='Command Editor')

 ;----top line: command no. and two buttons----

  top_line_base = widget_base(cmd_editor_base,/row)

  cmd_n_base = widget_base(top_line_base,/row,/align_left)

  cur_cmd_num_w = cw_field(cmd_n_base,title='Cmd #',$
                           value=strtrim(string(current_cmd_num),2),xsize=5)

  tot_cmd_num = schedule.ncommands 

  tot_cmd_num_w = cw_field(cmd_n_base,title='Out of',$
                 value=tot_cmd_num,xsize=5)

  insert_btn_base = widget_base(top_line_base,/row,/align_center)
  insert_btn_label = widget_label(insert_btn_base,value='     ')
  goto_cmd_btn = widget_button(insert_btn_base,value='Go to command',$
                               uvalue='goto_cmd')
  append_cmd_btn = widget_button(insert_btn_base,value='Append new command',$
                                 uvalue='append_cmd')
  new_date_btn = widget_button(insert_btn_base,value='New launch date',$
                                 uvalue='new_date')


 ;----showing current command (not editable)-----
  cur_cmd_w = cw_field(cmd_editor_base,title='Current Command',$
                 value=command_to_string(current_command),/noedit)


 ;----widget for test command-----

  test_cmd_base = widget_base(cmd_editor_base,/row)

  test_cmd_label = widget_label(test_cmd_base,value='Test command:')  

;  cmd_type_list = ['other','calibrator','CMB','cmb_dipole','science_scan']
  cmd_type_list = ['other',get_command_list()]

 ;----initial value of test command to be current command----

  test_command = current_command  
  test_cmd_type = command_type(test_command.name)

  test_cmd_type_w = widget_droplist(test_cmd_base,value=cmd_type_list)

  test_cmd_sttime_w = cw_field(test_cmd_base,title='',value='start T',$
                    xsize=7)
  test_cmd_par_w = cw_field(test_cmd_base,title='',value='parameters',xsize=40)
  test_cmd_comment_w = cw_field(test_cmd_base,title='Comment:',xsize=10)

  initialize_test_cmd,test_command,test_cmd_type_w,test_cmd_sttime_w,$
                      test_cmd_par_w,test_cmd_comment_w

 ;----widget for object option----

  object_base = widget_base(cmd_editor_base,/column,/base_align_right)

  target_base = widget_base(object_base,/row)
  targets_list = read_coord_data(!HEXSKYROOT+'/data/targets.dat',2)
  target_droplist = widget_droplist(target_base,title='Target area:',$
                     value = targets_list.name,uvalue='target_list')  
  target_ra_w = cw_field(target_base,title='RA(hr):',$
                         value = targets_list(0).RA,xsize=8)
  target_dec_w = cw_field(target_base,title='DEC(deg):',$
                         value = targets_list(0).DEC,xsize=8)
  target_ist_btn = widget_button(target_base,uvalue='insert_target',$
                       value = 'Insert coord to command')



  calibrator_base = widget_base(object_base,/row)
  calibrators_list = read_coord_data(!HEXSKYROOT+'/data/calibrators.dat',3)
  calibrator_droplist = widget_droplist(calibrator_base,title='Calibrator:',$
                     value = calibrators_list.name,uvalue='calibrator_list')  
  calibrator_ra_w = cw_field(calibrator_base,title='RA(hr):',$
                             value = calibrators_list(0).RA,xsize=8)
  calibrator_dec_w = cw_field(calibrator_base,title='DEC(deg):',$
                             value = targets_list(0).DEC,xsize=8)
  calibrator_ist_btn = widget_button(calibrator_base,$
                       value = 'Insert coord to command',$
                       uvalue='insert_calibrator')

 ;----widget for command edit buttons----

  cmd_btn_base = widget_base(cmd_editor_base,/row)
 
  reset_test_cmd = widget_button(cmd_btn_base,value='Reset test command',$
                                 xsize=150,ysize=30,uvalue='reset_test_cmd')
  replace_cur_cmd = widget_button(cmd_btn_base,ysize=30, $
                    value='Replace current command with test command',$
                    uvalue='replace_cmd') 
  cmd_help_info = widget_button(cmd_btn_base,value='Show command syntax',$
                                xsize=150,ysize=30,uvalue='cmd_help')

 ;----widget for command simulator----

  cmd_siml_base = widget_base(left,/column,/base_align_center,frame=3)
  cmd_siml_label = widget_label(cmd_siml_base,value = 'Command simulator')

  siml_btn_base = widget_base(cmd_siml_base,/row,ysize=30)
  siml_cur_cmd = widget_button(siml_btn_base,value='Simulate current command',$
                               xsize=200,uvalue='simulate_cur_cmd')
  siml_test_cmd = widget_button(siml_btn_base,value='Simulate test command',$
                               xsize=200,uvalue='simulate_test_cmd')

  siml_constr_base = widget_base(cmd_siml_base,/row)

  expt_duration_w = cw_field(siml_constr_base,title='Expt duration[hr]:',$
                             value = current_command.expected_duration,$
                             xsize=6)
  time_till_next_w = cw_field(siml_constr_base,title='Till next cmd[hr]:',$
                     value = current_command.time_to_next_command,xsize=6)
  cmd_tsamp_w = cw_field(siml_constr_base,title='tsamp(sec)',value='0.05',$
                         xsize=6)

  cmd_warning_w = cw_field(cmd_siml_base,title='Warning messages',$
                           value=' ',xsize=80)


 ;----widget for mission simulator----

  misn_siml_base = widget_base(left,/column,/base_align_center,frame=3)
  misn_siml_label = widget_label(misn_siml_base,value='Mission simulator')

  siml_top_base = widget_base(misn_siml_base,/row,ysize=30)
  siml_misn_btn = widget_button(siml_top_base,value='Simulate mission',$
                                xsize=200,uvalue='simulate_mission')
  misn_drn_w = cw_field(siml_top_base,title='Mission Duration [hr]',$
                        value='23.3',xsize=6)
  misn_tsamp_w = cw_field(siml_top_base,title='tsamp(sec)',value='0.05',$
                          xsize=6)
  misn_warning_w = cw_field(misn_siml_base,title='Warning messages',$
                            value='',xsize=80)



; -----Output parameters-----

;  output_base = widget_base(left,column=1,frame=3,/align_center)


 ;-----Set up output plot region-----

  draw = widget_draw(right,xsize=700,ysize=360,frame=5)

 ;-----Plot option widget-----
 plot_opt_base = widget_base(right,/row)

 elev_plot_btn = widget_button(plot_opt_base,value='Elevation plot',xsize=120,$
                               ysize=35,uvalue='elev_plot')
 az_el_plot_btn = widget_button(plot_opt_base,value='Az-El plot',xsize=120,$
                                ysize=35,uvalue='az_el_plot')
 plot_sep_label = widget_label(plot_opt_base,value='     ')

 cali_map_btn = widget_button(plot_opt_base,value='Calibrator map',xsize=120,$
                              uvalue='calibrator_map')
 cali_offset_w = cw_field(plot_opt_base,title='Offset[deg]:',value='0.0 0.0')


 sky_plot_base = widget_base(right,/row)
 sky_plot_btn = widget_button(sky_plot_base,value='Sky plot',xsize=120,$
                              uvalue='sky plot')

 proj_list = ['Mollview','Orthview','Gnomview']
 proj_droplist = widget_droplist(sky_plot_base,title='Projection:',$
                                 value=proj_list,uvalue='projection_list')
 rot_ang_w = cw_field(sky_plot_base,title='Rotation [deg]:',value='RA DEC BETA')



 ;-----File menu-----

  file_menu_base = widget_base(right,/column,/base_align_center,frame=2)

  file_menu_label = widget_label(file_menu_base,value='File Menu')
  file_sub_base = widget_base(file_menu_base,column=2)

  new_schd_btn = widget_button(file_sub_base,$
			       value='New schedule file',$
			       uvalue='new_schd',xsize=170,ysize=35)

  load_schd_btn = widget_button(file_sub_base,$
                                value='Load shcedule file',$
                                uvalue='load_schd',xsize=170,ysize=37)

  save_schd_btn = widget_button(file_sub_base,value='Save schedule file',$
                                uvalue='save_schd',xsize=170,ysize=37)

  save_image_btn = widget_button(file_sub_base,value='Save image',$
                                uvalue='save_image',xsize=170,ysize=37)

  open_ses_btn = widget_button(file_sub_base,value='Open Saved Session',$
			       uvalue='open_session',xsize=170,ysize=37)

  save_session = widget_button(file_sub_base,value='Save Current Session',$
			       uvalue='save_session',xsize=170,ysize=35)

  hex_par_btn = widget_button(file_sub_base,$
                                value=' Write hexsky parameter file ',$
                                uvalue='write_hex_par',ysize=35,/align_right)

  load_schd_w = cw_field(file_sub_base,title='',$
                                value=session.schedulefile,xsize=65)

  save_schd_w = cw_field(file_sub_base,title='',$
                                value=session.schedulefile,xsize=65)

  save_image_w = cw_field(file_sub_base,title='',$
                                value='./image.png',xsize=65)

  open_ses_w = cw_field(file_sub_base,title='',$
                        value=currentdir+'easypoint.ese',xsize=65)

  doquit = widget_button(file_sub_base,value='  Save and quit  ',uvalue='quit',$
			 ysize=35,/align_right)

 
 ;-----Realize widgets and register-----
 
  widget_control,base,/realize

;  widget_control,resize_base_w,sensitive = 0

  widget_control,draw,get_value=drawID

  help,drawID

  widget_control,base,set_uvalue=drawID

  xmanager,'EASYPOINT',base

END
