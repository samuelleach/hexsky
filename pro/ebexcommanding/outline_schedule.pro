function outline_schedule,schedule,mission,noutline=noutline


  ;AUTHOR: S. Leach
  ;PURPOSE: Make an array of outlines corresponding to a UTC schedulefile.

  ; The mission file is required for working out the geographical location of the gondola
  ; as well as for estimating the scan period and expected duration of
  ; each command.

  ncommands         = schedule.ncommands
  jd_start          = get_jd_from_utcschedule(schedule)
  get_earthpos_from_utcschedule,schedule,mission,lon,lat
  schedule_outline  = make_array(ncommands,value={outline})

  noutline = 0
  for cc = 0L, ncommands -1L do begin
     case (schedule.command[cc].name) of
        'cmb_scan': begin           
           noutline   = noutline + 1
           centralRA  = schedule.command[cc].parameters[2]*15.
           centralDec = schedule.command[cc].parameters[3]
           azwidth    = schedule.command[cc].parameters[5]
           decrange   = schedule.command[cc].parameters[6]
	   eq2hor,centralRA,centralDec,jd_start[cc],centralel,centralaz,lon=lon[cc],lat=lat[cc]
           if decrange eq 0 then begin
              ;Drift scan case
               period            =  get_scan_period_estimate(schedule.command[cc],mission)
               expected_duration = (period*(schedule.command[cc].parameters[8]-1)/2. +$
                                    mission.trepointing_sec)/60./60.*$
				  schedule.command[cc].parameters[7]
               
	       beta   = get_focalplane_orientation(centralRA,centralDec,jd_start[cc],lon[cc],lat[cc])
	       alpha  = beta - !pi	      
	       height = azwidth * sin(alpha) * cos(centralel*!dtor) 
	       slant  = azwidth * cos(alpha) * cos(centralel*!dtor) 

	       ra_parallelogram    = make_array(5,value=0.0)
	       dec_parallelogram   = make_array(5,value=0.0)
	       ra_parallelogram[0] = centralRA - slant/2.
	       ra_parallelogram[1] = centralRA + slant/2.
	       ra_parallelogram[2] = centralRA + slant/2. + 15.*expected_duration
	       ra_parallelogram[3] = centralRA - slant/2. + 15.*expected_duration
	       ra_parallelogram[4] = ra_parallelogram[0]
            
	       dec_parallelogram[0] = centralDec - height/2
	       dec_parallelogram[1] = centralDec + height/2. 
	       dec_parallelogram[2] = centralDec + height/2
	       dec_parallelogram[3] = centralDec - height/2. 
	       dec_parallelogram[4] = dec_parallelogram[0]
            
	       outline_temporary = outline_polygon(ra_parallelogram,dec_parallelogram)	       
           endif else begin
              ;Raster scan
              az_min     = centralAz - 0.5*azwidth 
              az_max     = centralAz + 0.5*azwidth 
              el_min     = centralEl - 0.5*decrange ;delta dec is not delta el
              el_max     = centralEl + 0.5*decrange ;delta dec is not delta el
              outline_temporary = outline_annulus(az_min,az_max,el_min,el_max,$
                                                  jd=jd_start[cc],lon=lon[cc],lat=lat[cc],$
                                                  /convert_azel_to_radec)
           endelse                         
           schedule_outline[noutline-1] = outline_temporary
        end
        'calibrator_scan': begin
            noutline   = noutline+1

            period =  get_scan_period_estimate(schedule.command[cc],mission)
            expected_duration = (period*(schedule.command[cc].parameters[8]-1)/2. +$
                                 mission.trepointing_sec)/60./60.*$
			       schedule.command[cc].parameters[7]            
            centralRA  = schedule.command[cc].parameters[2]*15.
            centralDec = schedule.command[cc].parameters[3]
            azwidth    = schedule.command[cc].parameters[5]
            elstep     = schedule.command[cc].parameters[6]
            numstep    = schedule.command[cc].parameters[7]

	   ;Make parallelogram in RA/Dec
            beta  = get_focalplane_orientation(centralRA,centralDec,jd_start[cc],lon[cc],lat[cc])
            alpha = beta - !pi
            
            width     = azwidth * cos(alpha) 
            slant     = azwidth * sin(alpha) 

            declength = expected_duration * 15.* tan(alpha)*cos(centralDec*!dtor) +$
              numstep * elstep /60. * cos(alpha)
            declength = declength /2. ; Fudge factor

            ra_parallelogram  = make_array(5,value=0.0)
            dec_parallelogram = make_array(5,value=0.0)
            
            ra_parallelogram[0] = centralRA + width/2.
            ra_parallelogram[1] = centralRA - width/2.
            ra_parallelogram[2] = centralRA - width/2.
            ra_parallelogram[3] = centralRA + width/2.
            ra_parallelogram[4] = ra_parallelogram[0]
            
            dec_parallelogram[0] = centralDec + declength/2. + slant/2
            dec_parallelogram[1] = centralDec + (declength-slant)/2. 
            dec_parallelogram[2] = centralDec - declength/2. - slant/2
            dec_parallelogram[3] = centralDec - (declength-slant)/2. 
            dec_parallelogram[4] = dec_parallelogram[0]
            
            outline_temporary            = outline_polygon(ra_parallelogram,dec_parallelogram)            
            schedule_outline[noutline-1] = outline_temporary
        end
        'cmb_dipole': begin
            noutline   = noutline+1
            outline_temporary = outline_target('rcw38',0.1); Dummy outline : need to fix this.
            schedule_outline[noutline-1] = outline_temporary
         end
        else: message,schedule.command[cc].name+' not implemented.',/continue
     endcase
  endfor


  return,schedule_outline[0:noutline-1]
 

end
