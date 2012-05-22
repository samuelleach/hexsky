pro simulate_pointing,schedule,mission,outputdir=outputdir,$
                      no_cleanup=no_cleanup,no_pointing=no_pointing,$
                      without_pendulations=without_pendulations,$
                      warning_file=warning_file,$
                      first_command=first_command,last_command=last_command
  

; INPUT: schedule is the output struct from read_schedulefile.pro
;        mission is a struct containing all other relevant mission and
;        gondola parameters

  if n_elements(outputdir) eq 0    then outputdir    = './output'
  if n_elements(warning_file) eq 0 then warning_file = 'WARNINGS_readme'
  if n_elements(first_command) eq 0 then first_command = 1
  
 spawn,'mkdir -p '+outputdir+'/hexsky_outfiles'
 
 ncommand = schedule.ncommands
 print, 'Number of commands = ',ncommand

 if (n_elements(last_command) eq 0) or last_command eq -1 then last_command = ncommand

 ;------------------------------------------
 ;Read in template parameter file for hexsky
 ;------------------------------------------
 hexsky_template                    = read_parameterfile(!HEXSKY_TEMPLATE_PARFILE)
 hexsky_template.timebetweensamples = mission.tsamp_sec
 hexsky_template.stopt              = mission.starcamstop_sec
 hexsky_template.elevationlimit     = 85.
 if(keyword_set(without_pendulations)) then begin
    hexsky_template.wantazipendulation = 0 
    hexsky_template.wantelependulation = 0 
 endif

 hexsky_parameters = make_array(ncommand,value=hexsky_template)


 ;-------------------------------------------------------------
 ;Get Julian day of launch date - needed for balloon trajectory
 ;-------------------------------------------------------------
 JDCNV, mission.year, mission.month, mission.day,$
        mission.launch_utc, jd_launch
 
 ;----------------------------------------------------------------------------
 ;Set up hexsky parameters - Conversion between commands and hexsky parameters
 ;----------------------------------------------------------------------------
; for cc = 0, ncommand-1 do begin
 for cc = first_command-1, last_command-1 do begin
    azthrow = 0.;Default value
    
    hexsky_parameters[cc].output_dir  = outputdir 
    hexsky_parameters[cc].outfileroot = outputdir+'/hexsky_outfiles/command'+strtrim(cc+1,2)
    hexsky_parameters[cc].year        = schedule.year
    hexsky_parameters[cc].month       = schedule.month
    azaccel                           = mission.maxaccel_deg
        
    startday = schedule.day + schedule.command[cc].parameters[0] -1

    hexsky_parameters[cc].startday  = fix(startday)
    hexsky_parameters[cc].starthour = schedule.hour_utc + $
                                      schedule.command[cc].parameters[1] ; = starttime (UTC)
    tag = 'startra_day_'+strtrim(round(startday),2)
    index = Where(Tag_Names(hexsky_parameters[cc]) EQ strupcase(tag), count)
    IF count NE 0 THEN hexsky_parameters[cc].(index[0]) = $
       schedule.command[cc].parameters[2]*360./24. ; startRa


    ;---------------------------------------
    ;Get Julian day and longitude of command
    ;---------------------------------------
    JDCNV, schedule.year, schedule.month, startday, $
	   hexsky_parameters[cc].starthour, jd_command

    hexsky_parameters[cc].latitude_deg        = mission.latitude_deg
    hexsky_parameters[cc].longitude_start_deg = $
       get_gondola_longitude(mission.longitude_start_deg,jd_launch,jd_command,$
                             mission.orbitspeed)

    hexsky_parameters[cc].orbitspeed = mission.orbitspeed
    hexsky_parameters[cc].totaldays  = 1
    hexsky_parameters[cc].numberscan = 1
 
    case strlowcase(schedule.command[cc].name) of
        ;-----------
        'cmb_scan': begin
        ;-----------
            tag   = 'startra_day_'+strtrim(round(startday),2)
            index = Where(Tag_Names(hexsky_parameters[cc]) EQ strupcase(tag), count)
            IF count NE 0 THEN hexsky_parameters[cc].(index[0]) = $
               schedule.command[cc].parameters[2]*360./24. ; startRa
            hexsky_parameters[cc].startdec_center = $
               schedule.command[cc].parameters[3] ; startDec
            azspeed       = schedule.command[cc].parameters[4]
            azthrow       = schedule.command[cc].parameters[5]
            deltaDec      = schedule.command[cc].parameters[6]
            decstepnumber = schedule.command[cc].parameters[7]    
            azrepeat      = schedule.command[cc].parameters[8]-1  
	    hexsky_parameters[cc].targetdecrange    = deltadec
            hexsky_parameters[cc].numberchop        = azrepeat/2
            hexsky_parameters[cc].numberelestep     =  decstepnumber
;            hexsky_parameters[cc].elestepmin_arcmin = -26.
;            hexsky_parameters[cc].elestepmax_arcmin =  26.
;            hexsky_parameters[cc].noofelestepstotry =  53
;            hexsky_parameters[cc].elestepmin_arcmin = -10.
;            hexsky_parameters[cc].elestepmax_arcmin =  10.
;            hexsky_parameters[cc].noofelestepstotry =  21
            hexsky_parameters[cc].elestepmin_arcmin = -10.
            hexsky_parameters[cc].elestepmax_arcmin =  10.
            hexsky_parameters[cc].noofelestepstotry =  41
            hexsky_parameters[cc].totalt = $
               get_scan_period_estimate(schedule.command[cc],mission)
            message,'Chopping period [s] = '+number_formatter(hexsky_parameters[cc].totalt),/continue
            expected_duration = (hexsky_parameters[cc].totalt*azrepeat/2. + $
                                 mission.trepointing_sec )/60./60.* $
                                hexsky_parameters[cc].numberelestep
            elevation_repointing_duration = $
               mission.trepointing_sec/60./60.*hexsky_parameters[cc].numberelestep
         end
        ;------------------
        'calibrator_scan': begin             
        ;------------------
           tag   = 'startra_day_'+strtrim(round(startday),2)
           index = Where(Tag_Names(hexsky_parameters[cc]) EQ strupcase(tag), count)
           IF count NE 0 THEN hexsky_parameters[cc].(index[0]) = $
              schedule.command[cc].parameters[2]*360./24. ; startRa
           hexsky_parameters[cc].startdec_center = $
              schedule.command[cc].parameters[3] ; startDec
           azspeed       = schedule.command[cc].parameters[4]
           azthrow       = schedule.command[cc].parameters[5]
           elevationstep = schedule.command[cc].parameters[6]
           noofsteps     = schedule.command[cc].parameters[7]
           azrepeat      = schedule.command[cc].parameters[8] - 1
            
            if(azrepeat eq 1) then begin
                hexsky_parameters[cc].wantcalibratorscan = 1
                hexsky_parameters[cc].numberchop         = 1
            endif else begin
                hexsky_parameters[cc].wantcalibratorscan = 0                 
                hexsky_parameters[cc].numberchop         = azrepeat/2
            endelse
            hexsky_parameters[cc].elestepmin_arcmin = elevationstep+0.0001
            hexsky_parameters[cc].elestepmax_arcmin = elevationstep-0.0001 
            hexsky_parameters[cc].noofelestepstotry = 2  
            hexsky_parameters[cc].numberelestep     = noofsteps
            hexsky_parameters[cc].totalt = $
               get_scan_period_estimate(schedule.command[cc],mission)
            message,'Chopping period [s] = '+number_formatter(hexsky_parameters[cc].totalt),/continue
            expected_duration = (hexsky_parameters[cc].totalt*azrepeat/2. + $
                                 mission.trepointing_sec )/60./60.*$
                                hexsky_parameters[cc].numberelestep
            elevation_repointing_duration = $
               mission.trepointing_sec/60./60.*hexsky_parameters[cc].numberelestep            
        end
        ;------------------
        'cmb_dipole': begin             
        ;------------------
            azspeed       = schedule.command[cc].parameters[2]
            elevation     = schedule.command[cc].parameters[3]
            totaltime     = schedule.command[cc].parameters[4]
            finalaz       = schedule.command[cc].parameters[5]
            finalel       = schedule.command[cc].parameters[6]
            
            hexsky_parameters[cc].wantcmbdipolescan     = 1                  
            hexsky_parameters[cc].cmbdipolescan_startel = elevation                  
            hexsky_parameters[cc].wantcalibratorscan    = 0                 
            hexsky_parameters[cc].numberchop            = 1
            hexsky_parameters[cc].elestepmin_arcmin     = +0.00001
            hexsky_parameters[cc].elestepmax_arcmin     = -0.00001 
            hexsky_parameters[cc].noofelestepstotry     = 2  
            hexsky_parameters[cc].numberelestep         = 1
            hexsky_parameters[cc].totalt                = totaltime
            azrepeat                                    = 1
            expected_duration = hexsky_parameters[cc].totalt/60./60. ; + slewing at the end of the command
            elevation_repointing_duration = 0.
         end
        else: begin
            message,'Command called "'+schedule.command[cc].name+ '" not implemented.'
        end
    endcase
    hexsky_parameters[cc].maxaccel_rad           = azaccel*2.*!pi/360.
    hexsky_parameters[cc].maxspeed_deg           = azspeed
    hexsky_parameters[cc].append_data_to_dirfile = 1

    numberchop = float(hexsky_parameters[cc].numberchop)
    if(abs(floor(numberchop)-numberchop) gt 1.e-4) then begin
       message,'WARNING: Choose numstarcam to be 2, or an odd number'
    endif

    ;----------------------------------
    ;Make a check on the command length
    ;----------------------------------
    schedule.command[cc].expected_duration = expected_duration
    startday  = strtrim(fix(schedule.command[cc].parameters[0]),2)
    starttime = strtrim(schedule.command[cc].parameters[1],2)
    print,'Command ',cc+1,' (',schedule.command[cc].name+' '+startday+' '+starttime+')'
    print,'Time to next command      (hr) = ', schedule.command[cc].time_to_next_command
    print,'Expected duration         (hr) = ', schedule.command[cc].expected_duration
    print,'of which is el repointing (hr) = ', elevation_repointing_duration

    ;-----------------------------------------------------------------
    ; Is the expected duration shorter than the time to next command ?
    ;-----------------------------------------------------------------
    if ((schedule.command[cc].expected_duration lt 0.9*schedule.command[cc].time_to_next_command) and $
        (cc ne ncommand-1)) then begin
       message,'The last command looks too short',/continue
       wait,1
       warn_mess = 'Expected duration of command is shorter than time to next command'
       underrun_factor   = -(schedule.command[cc].expected_duration - schedule.command[cc].time_to_next_command)/$
                           schedule.command[cc].time_to_next_command

       warning_message,warn_mess,warning_file=outputdir+'/'+warning_file,type=2,index=(cc+1),$
                       parameter=underrun_factor,/silent

    endif


    ;-----------------------------------------------------------------
    ; Is the expected duration greater than the time to next command ?
    ;-----------------------------------------------------------------
    if(schedule.command[cc].expected_duration gt $
       schedule.command[cc].time_to_next_command) then begin
       overrun_factor   = (schedule.command[cc].expected_duration - schedule.command[cc].time_to_next_command)/$
                          schedule.command[cc].time_to_next_command
       unhappy_command  = command_to_string(schedule.command[cc])
       format           = command_format(schedule.command[cc].name,$
                                         syntax=syntax,numelestep_index=numelestep_index,$
                                         numstarcam_index=numstarcam_index)
       if numelestep_index ne -1 then begin
           ;Estimate the number of elevations steps that will
           ;satisfy the time constraint.
          reduced_elevationsteps = floor(schedule.command[cc].parameters[numelestep_index]*$
                                         schedule.command[cc].time_to_next_command/$
                                         schedule.command[cc].expected_duration)
           ;Estimate the number of turnarounds that will
           ;satisfy the time constraint.                                          
          reduced_throws = floor((schedule.command[cc].parameters[numstarcam_index]-1.)*$
                                 schedule.command[cc].time_to_next_command/$
                                 schedule.command[cc].expected_duration)+1
          if reduced_throws/2. eq floor(reduced_throws/2.) then   reduced_throws = reduced_throws -1 ; Make sure is an odd number
       endif

       message,'-------------------------------------------------------------------',$
               /continue
       warn_mess = 'Expected duration of command is longer than time to next command.'
       message,'WARNING :  '+$
               warn_mess,/continue
       if schedule.filename ne '' then begin
          message,'Please inspect the following command in:',/continue
          message,schedule.filename,/continue
       endif	  
       message,'Command: '+unhappy_command,  /continue
       message,'Syntax: '+syntax,/continue
       message,'Chopping period [s] of this command: ~'+$
               strtrim(hexsky_parameters[cc].totalt,2),/continue
       if schedule.command[cc].name ne 'cmb_dipole' then begin
          message,'Try reducing the number of elevation steps from '+$
                  strtrim(fix(schedule.command[cc].parameters[numelestep_index]),2)+' to '+$
                  strtrim(reduced_elevationsteps,2),$
                  /continue
          message,'or try reducing (number of throws + 1) from '+$
                  strtrim(fix(schedule.command[cc].parameters[numstarcam_index]),2)+' to '+$
                  strtrim(reduced_throws,2),$
                  /continue
       endif
       message,'-------------------------------------------------------------------',/cont

       ;----------------------------------
       ; Write out warning message to disk
       ;----------------------------------
       warning_message,warn_mess,warning_file=outputdir+'/'+warning_file,type=1,index=(cc+1),$
                       parameter=overrun_factor,/silent

    endif    
 endfor
 
 ;----------------------------
 ;Write hexsky parameter files
 ;----------------------------
 if(not keyword_set(no_pointing)) then begin
    spawn,'mkdir -p '+outputdir+'/parfiles'
    command='rm -rf '+outputdir+'/dirfile'
    print, 'simulate_pointing.pro: Removing dirfile directory with'
    print, command
    spawn, command
    for cc = 0L,ncommand-1L do begin
       parfile = outputdir+'/parfiles/hexsky_command'+strtrim(cc+1,2)+'.par'
       write_parameterfile,parfile,hexsky_parameters[cc]
    endfor
  endif


 ;--------------------------------------------------------------------
 ; For convenience, write hexsky parameter files with full sample rate
 ;--------------------------------------------------------------------
 if(not keyword_set(no_pointing)) then begin
    outputdir2  = outputdir+'/fullsamplerate/' 
    command='rm -rf '+outputdir2
    print, 'simulate_pointing.pro: Removing dirfile directory with'
    print, command
    spawn, command
    hexsky_parameters_copy                    = hexsky_parameters
    hexsky_parameters_copy.timebetweensamples = mission.tsamp_fast_sec
    spawn,'mkdir -p '+outputdir2

    
    script = outputdir+'/hexsky_fullsamplerate_tasks.txt'
    spawn , 'rm -rf '+script

    hexskybin = getenv('HEXSKY')+'/bin/hexsky'
    message,'Making hexsky full sample rate script in '+script,/continue 
    openw, lun, script, /get_lun
    printf, lun, 'rm -rf '+outputdir2+'/dirfile'
    for cc = 0L,ncommand-1L do begin
       hexsky_parameters_copy[cc].output_dir  = outputdir2
       hexsky_parameters_copy[cc].outfileroot = outputdir2+'/command'+strtrim(cc+1,2)
       parfile = outputdir+'/parfiles/hexsky_fullsamplerate_command'+strtrim(cc+1,2)+'.par'
       write_parameterfile,parfile,hexsky_parameters_copy[cc]
       printf, lun, hexskybin+' '+parfile
    endfor
    printf, lun, 'rm -rf '+outputdir2+'/*.bin'
    free_lun, lun 

 endif

  
 ;-------------------------------------------------------
 ;Run hexsky parameter files to simulate pointing to disk
 ;-------------------------------------------------------
 if(not keyword_set(no_pointing)) then begin
     spawn,'mkdir -p '+outputdir+'/logfiles'
     hexskybin = getenv('HEXSKY')+'/bin/hexsky'
     if(file_exists(hexskybin)) then begin
;         for cc = 0,ncommand-1L do begin
         for cc = first_command-1,last_command-1L do begin
             fileroot = 'hexsky_command'+strtrim(cc+1,2)
             parfile  = outputdir+'/parfiles/'+fileroot+'.par'
             logfile  = outputdir+'/logfiles/'+fileroot+'.log'
             command  = hexskybin+' '+parfile+redirect_string()+logfile
             message,'Spawning hexsky pointing code from IDL:',/continue
             message,command,/continue
             spawn,command

             ;-------------------------------------------------
             ;Get back information about first sample index,
             ;number of samples, and expected time for command.
             ;-------------------------------------------------
             hexskylog = read_parameterfile(hexsky_parameters[cc].outfileroot+'_hexsky_log.txt')
             schedule.command[cc].first_sample_index = hexskylog.df_first_frame
             schedule.command[cc].nsample            = $
                long(hexskylog.df_last_frame) - long(hexskylog.df_first_frame)+1L
             expected_duration  = schedule.command[cc].expected_duration
             simulated_duration = float(schedule.command[cc].nsample)*mission.tsamp_sec/3600.
             print,'Expected vs Simulated duration [hr]:',expected_duration,simulated_duration             
             schedule.command[cc].expected_duration = simulated_duration

             ;-------------------------------------
             ; Check elevation range of repointings
             ;-------------------------------------
             if schedule.command[cc].name ne 'cmb_dipole' then begin
                asc_read,outputdir+'/hexsky_outfiles/command'+strtrim(cc+1,2)+$
                         '_azel_repointings.dat',az_pointing,el_pointing,/silent
                if max(el_pointing) gt mission.elevation_upperlimit_deg then begin
                   print,' '
                   message,'WARNING: command '+strtrim(cc+1,2)+': repointing exceeding elevation upper limit by '+$
                           number_formatter(max(el_pointing)-mission.elevation_upperlimit_deg,dec=2)+' deg',/continue
                   print,' '
                   warn_mess = 'Exceeding max allowed elevation'
                   warning_message,warn_mess,warning_file=outputdir+'/'+warning_file,type=3,index=(cc+1),$
                                   parameter=max(el_pointing),/silent

                endif
                if min(el_pointing) lt mission.elevation_lowerlimit_deg then begin
                   print,' '
                   message,'WARNING: command '+strtrim(cc+1,2)+': repointing below elevation lower limit by '+$
                           number_formatter(mission.elevation_lowerlimit_deg-min(el_pointing),dec=2)+' deg',/continue
                   print,' '
                   warn_mess = 'Below min allowed elevation'
                   warning_message,warn_mess,warning_file=outputdir+'/'+warning_file,type=4,index=(cc+1),$
                                   parameter=min(el_pointing),/silent
                endif
             endif

         endfor
     endif else begin
         print  , 'Cannot find hexsky binary in '+hexskybin
         message, 'See hexsky/INSTALL for instructions.'
     endelse
     
     ;----------------------------------------------------------
     ;Delete non-dirfile binary output from hexsky (*.bin files) 
     ;----------------------------------------------------------
     if(keyword_set(no_cleanup)) then begin
        message,'Leaving hexsky .bin files in '+outputdir,/continue
     endif else begin
        message,'Deleting hexsky .bin files from '+outputdir,/continue
        spawn,'rm -rf '+outputdir+'/*.bin'
     endelse
     spawn,'rm -rf '+outputdir+'/azel.dat'

     ;----------------------------------------------------------
     ;Write first sample and nsample for each command to a table
     ;----------------------------------------------------------
     outputfile = outputdir+'/command_firstsample.dat'
     print, 'Writing first sample and nsample of each command to '+outputfile
     asc_write,outputfile,schedule.command[(first_command-1):(last_command-1)].first_sample_index,$
               schedule.command[(first_command-1):(last_command-1)].nsample,$
               header='# First sample and nsample for each command in dirfile'


 endif

end
