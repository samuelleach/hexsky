;=========================================================
;=         CDUST dust level visulization tool            =
;=                  Author: C.Bao                        =
;=    Purpose: 1.Outline available region on the sky on  =
;=              top of Healpix mollview map              =
;=             2.Zoom in on desired small patch of sky   =
;=             3.Calculate statistics of desired patch   =
;=========================================================
FUNCTION UPDATE_TIME

 COMMON cdust_block, latitude_w,longitude_w,year_w,month_w,day_w,$
                     hour_w,tz_w,ctr_ra_w,ctr_dec_w,resolution_w,$
                     pxsize_w,pysize_w,max_w,min_w,mean_w,sdev_w,$
                     dat_min_w,dat_max_w,rot_angle,sites_list,$
                     timestyle_list,timestyle_droplist,other_time_w,$
                     pac_ra_w,pac_dec_w,pac_value_w,field,$
                     utcschedfile,showvis,mission_file


       widget_control,latitude_w,get_value=latitude_v
       widget_control,longitude_w,get_value=longitude_v
       widget_control,year_w,get_value=year_v
       widget_control,month_w,get_value=month_v
       widget_control,day_w,get_value=day_v
       widget_control,hour_w,get_value=hour_v
       widget_control,tz_w,get_value=tz_v

       latitude = float(latitude_v[0])
       longitude = float(longitude_v[0])
       year = float(year_v[0])
       month = fix(month_v[0])
       day = fix(day_v[0])
       hour = float(hour_v[0])
       tz = fix(tz_v[0])

       ts_select = widget_info(timestyle_droplist,/droplist_select)
       if ts_select eq 0 then begin

        ct2lst,lst, longitude, tz, hour, day, month, year
        widget_control,other_time_w,set_value='LST: '+$
                       string(lst,format='(f7.4)')
        return, -1
       endif else begin

        loct = lst2ct(hour,longitude,tz,day,month,year)
        widget_control,other_time_w,set_value='LT: '+$
                       string(loct,format='(f7.4)')
        return, loct
      endelse
 
  END


PRO CDUST_EVENT,event

 COMMON cdust_block, latitude_w,longitude_w,year_w,month_w,day_w,$
                     hour_w,tz_w,ctr_ra_w,ctr_dec_w,resolution_w,$
                     pxsize_w,pysize_w,max_w,min_w,mean_w,sdev_w,$
                     dat_min_w,dat_max_w,rot_angle,sites_list,$
                     timestyle_list,timestyle_droplist,other_time_w,$
                     pac_ra_w,pac_dec_w,pac_value_w,field,$
                     utcschedfile,showvis,mission_file

                     

  widget_control,event.id,get_uvalue = uval

  inmap = !HEXSKYROOT+'/data/dust_carlo_150ghz_512_radec.fits'
  
  read_fits_map,inmap,map

  factor = conversion_factor('uK_RJ','uK_CMB',150)
  map    = map*factor ; Convert from RJ to Thermodynamic units

  case uval of

   'tslist': begin

   result = update_time()

   end

   'site_list': begin

       site_index = event.index
       if sites_list[site_index].name eq 'User Defined' then begin
        widget_control,latitude_w,set_value='0.00'
        widget_control,longitude_w,set_value='0.00'
        widget_control,tz_w,set_value = '0'
       endif else begin
        widget_control,latitude_w,$
                       set_value=sites_list[site_index].latitude
        widget_control,longitude_w,$
                       set_value=sites_list[site_index].longitude
        tz = calc_tz(sites_list[site_index].longitude)
        widget_control,tz_w,set_value = tz
    endelse

    result = update_time()
   
   end

   'dustmap':begin

      showvis=0

       widget_control,latitude_w,get_value=latitude_v
       widget_control,longitude_w,get_value=longitude_v
       widget_control,year_w,get_value=year_v
       widget_control,month_w,get_value=month_v
       widget_control,day_w,get_value=day_v
       widget_control,hour_w,get_value=hour_v
       widget_control,tz_w,get_value = tz_v

       latitude  = float(latitude_v[0])
       longitude = float(longitude_v[0])
       year      = float(year_v[0])
       month     = fix(month_v[0])
       day       = fix(day_v[0])
       hour      = float(hour_v[0])
       tz        = fix(tz_v[0])

       result    = update_time()

       if result ne -1 then hour_hex = sixty(result) else hour_hex = sixty(hour)

       hour_i   = hour_hex[0]
       minute_i = hour_hex[1]
       second   = fix(hour_hex[2])
       minute   = ten([minute_i,second,0])

       if rot_angle[0] eq -1 then begin
          juldate,[year,month,day,hour_i,minute,0],jd
          jd = double(jd - tz/24.) + 2400000d
          hor2eq,90.,0.,jd,zenith_ra,zenith_dec,lat=lat_deg,lon=lon_deg
          rot_angle = [zenith_ra,zenith_dec,0.]
          find_region,latitude,longitude,tz,year,month,day,hour_i,minute,$
                      window = 4,field=field,$
                      utcschedfile=utcschedfile,show_visibility=showvis,missionfile=mission_file
       endif else begin
          find_region,latitude,longitude,tz,year,month,day,hour_i,minute,$
                      rot_ang = rot_angle,window = 4,field=field,$
                      utcschedfile=utcschedfile,show_visibility=showvis,missionfile=mission_file
     endelse

;     xmanager,'CDUST_EVENT',4,event_handler = 'POINT_CLICK'

   end

   'vismap':begin

      showvis=1


       widget_control,latitude_w,get_value=latitude_v
       widget_control,longitude_w,get_value=longitude_v
       widget_control,year_w,get_value=year_v
       widget_control,month_w,get_value=month_v
       widget_control,day_w,get_value=day_v
       widget_control,hour_w,get_value=hour_v
       widget_control,tz_w,get_value = tz_v

       latitude  = float(latitude_v[0])
       longitude = float(longitude_v[0])
       year      = float(year_v[0])
       month     = fix(month_v[0])
       day       = fix(day_v[0])
       hour      = float(hour_v[0])
       tz        = fix(tz_v[0])

       result    = update_time()

       if result ne -1 then hour_hex = sixty(result) else hour_hex = sixty(hour)

       hour_i   = hour_hex[0]
       minute_i = hour_hex[1]
       second   = fix(hour_hex[2])
       minute   = ten([minute_i,second,0])

       if rot_angle[0] eq -1 then begin
          juldate,[year,month,day,hour_i,minute,0],jd
          jd = double(jd - tz/24.) + 2400000d
          hor2eq,90.,0.,jd,zenith_ra,zenith_dec,lat=lat_deg,lon=lon_deg
          rot_angle = [zenith_ra,zenith_dec,0.]
          find_region,latitude,longitude,tz,year,month,day,hour_i,minute,$
                      window = 4,field=field,$
                      utcschedfile=utcschedfile,show_visibility=showvis,missionfile=mission_file
       endif else begin
          find_region,latitude,longitude,tz,year,month,day,hour_i,minute,$
                      rot_ang = rot_angle,window = 4,field=field,$
                      utcschedfile=utcschedfile,show_visibility=showvis,missionfile=mission_file
     endelse

;     xmanager,'CDUST_EVENT',4,event_handler = 'POINT_CLICK'

   end


   'point_click': begin

       wset,4

  ; Algorithm 1: single click allowed whenever 'point_click'
  ;              button is selected. The coord of selected
  ;              point will be passed to zoom in panel

;       cursor,xpos,ypos,/wait,/data
;       moll2pix,xpos,ypos,id_pix,lon_deg,lat_deg,value
;       ra = strtrim(string(lon_deg / 15.,format='(f7.4)'),2)
;       dec = strtrim(string(lat_deg,format='(f8.4)'),2)
;       temp = strtrim(string(value,format='(f9.2)'),2)
;       widget_control,pac_ra_w,set_value = ra
;       widget_control,pac_dec_w,set_value = dec
;       widget_control,pac_value_w,set_value = temp
;       ra_deg = strtrim(string(lon_deg,format='(f8.4)'),2)
;       widget_control,ctr_ra_w,set_value = ra_deg
;       widget_control,ctr_dec_w,set_value = dec


  ; Algorithm 2: right click to pick and examine points
  ;              when find a desired point, left click
  ;              to end and send the coord to zoom in
  ;              panel

       mouse_status = 4
 
       while(mouse_status eq 4) do begin
       xpos = 0.0
       ypos = 0.0
       id_pix = -1
       lon_deg = 0.0
       lat_deg = 0.0
       value = 0.0
       cursor,xpos,ypos,/wait,/data
       moll2pix,xpos,ypos,id_pix,lon_deg,lat_deg,value
       ra = strtrim(string(lon_deg / 15.,format='(f7.4)'),2)
       dec = strtrim(string(lat_deg,format='(f8.4)'),2)
       temp = strtrim(string(value,format='(f9.2)'),2)
       widget_control,pac_ra_w,set_value = ra
       widget_control,pac_dec_w,set_value = dec
       widget_control,pac_value_w,set_value = temp
       mouse_status = !mouse.button

       endwhile

       ra_deg = strtrim(string(lon_deg,format='(f8.4)'),2)
       widget_control,ctr_ra_w,set_value = ra_deg
       widget_control,ctr_dec_w,set_value = dec


   end


   'toggle':begin

       widget_control,latitude_w,get_value=latitude_v
       widget_control,longitude_w,get_value=longitude_v
       widget_control,year_w,get_value=year_v
       widget_control,month_w,get_value=month_v
       widget_control,day_w,get_value=day_v
       widget_control,hour_w,get_value=hour_v
       widget_control,tz_w,get_value = tz_v

       latitude = float(latitude_v[0])
       longitude = float(longitude_v[0])
       year = float(year_v[0])
       month = fix(month_v[0])
       day = fix(day_v[0])
       hour = float(hour_v[0])
       tz = fix(tz_v[0])

       result = update_time()

       if result ne -1 then hour_hex = sixty(result) $    
       else hour_hex = sixty(hour)
       hour_i = hour_hex[0]
       minute_i = hour_hex[1]
       second = fix(hour_hex[2])
       minute = ten([minute_i,second,0])

       juldate,[year,month,day,hour_i,minute,0],jd
       jd = double(jd - tz/24.) + 2400000d
       hor2eq,90.,0.,jd,zenith_ra,zenith_dec,lat=lat_deg,lon=lon_deg
       rot_angle = [zenith_ra,zenith_dec,0.]
       find_region,latitude,longitude,tz,year,month,day,hour_i,minute,$
                   window = 4,$
                   utcschedfile=utcschedfile,show_visibility=showvis,missionfile=mission_file
       
    end

    'toggle_radec':begin

       widget_control,latitude_w,get_value=latitude_v
       widget_control,longitude_w,get_value=longitude_v
       widget_control,year_w,get_value=year_v
       widget_control,month_w,get_value=month_v
       widget_control,day_w,get_value=day_v
       widget_control,hour_w,get_value=hour_v
       widget_control,tz_w,get_value = tz_v

       latitude = float(latitude_v[0])
       longitude = float(longitude_v[0])
       year = float(year_v[0])
       month = fix(month_v[0])
       day = fix(day_v[0])
       hour = float(hour_v[0])
       tz = fix(tz_v[0])

       result = update_time()

       if result ne -1 then hour_hex = sixty(result) $    
       else hour_hex = sixty(hour)
       hour_i = hour_hex[0]
       minute_i = hour_hex[1]
       second = fix(hour_hex[2])
       minute = ten([minute_i,second,0])

       juldate,[year,month,day,hour_i,minute,0],jd
       jd = double(jd - tz/24.) + 2400000d
       hor2eq,90.,0.,jd,zenith_ra,zenith_dec,lat=lat_deg,lon=lon_deg
       rot_angle = [0.,0.,0.]
       find_region,latitude,longitude,tz,year,month,day,hour_i,minute,$
                     window = 4,rot_ang=rot_angle,$
                     utcschedfile=utcschedfile,show_visibility=showvis,missionfile=mission_file
       
    end


   'gnom':begin


      widget_control,ctr_ra_w,get_value=ctr_ra_v
      widget_control,ctr_dec_w,get_value=ctr_dec_v
      widget_control,resolution_w,get_value=reso_v
      widget_control,pxsize_w,get_value=pxsize_v
      widget_control,pysize_w,get_value=pysize_v
      widget_control,max_w,get_value=max_v
      widget_control,min_w,get_value=min_v

      ctr_ra =float(ctr_ra_v[0])
      ctr_dec=float(ctr_dec_v[0])
      reso   =float(reso_v[0])
      pxsize =fix(pxsize_v[0])
      pysize =fix(pysize_v[0])
      max    =fix(max_v[0])
      min    =fix(min_v[0])


      gnomview,map,graticule=[5,5],rot=[ctr_ra,ctr_dec,0],units='!4l!3K',$
           title='Zoom in dust map centered on RA:'+ctr_ra_v[0]+' DEC:'+$
           ctr_dec_v[0],pxsize=pxsize,pysize=pysize,$
           coord=['C','C'],max=max,min=min,/glsize,window=3,outline=field,/flip

  end

   'calc':begin

      widget_control,ctr_ra_w,get_value=ctr_ra_v
      widget_control,ctr_dec_w,get_value=ctr_dec_v
      widget_control,resolution_w,get_value=reso_v
      widget_control,pxsize_w,get_value=pxsize_v
      widget_control,pysize_w,get_value=pysize_v

      ctr_ra =float(ctr_ra_v[0])
      ctr_dec=float(ctr_dec_v[0])
      resol  =float(reso_v[0])
      pxsize =fix(pxsize_v[0])
      pysize =fix(pysize_v[0])
      
      ctr_ra_rad = ctr_ra / !radeg
      ctr_dec_rad= !pi/2-ctr_dec/ !radeg

      half_x_ang = resol/60.*pxsize/2/!radeg
      half_y_ang = resol/60.*pysize/2/!radeg
      
      vertex_theta = [ctr_dec_rad-half_y_ang,ctr_dec_rad-half_y_ang,$
                      ctr_dec_rad+half_y_ang,ctr_dec_rad+half_y_ang]
      vertex_phi = [ctr_ra_rad-half_x_ang,ctr_ra_rad+half_x_ang,$
                    ctr_ra_rad+half_x_ang,ctr_ra_rad-half_x_ang]
  
      ang2vec,vertex_theta,vertex_phi,vertex_vec

      query_polygon,512,vertex_vec,pixels
  
      result = moment(map[pixels,0],SDEV=sdev)

      minmax = minmax(map[pixels,0])

      min = strtrim(string(minmax[0]),2)
      max = strtrim(string(minmax[1]),2)

      sdev = strtrim(string(sdev),2)
      mean = strtrim(string(result[0]))

      widget_control,mean_w,set_value=mean
      widget_control,sdev_w,set_value=sdev
      widget_control,dat_min_w,set_value=min
      widget_control,dat_max_w,set_value=max
    end


  endcase

END



PRO CDUST,utc_schedulefile=utc_schedulefile,missionfile=missionfile

 COMMON cdust_block, latitude_w,longitude_w,year_w,month_w,day_w,$
                     hour_w,tz_w,ctr_ra_w,ctr_dec_w,resolution_w,$
                     pxsize_w,pysize_w,max_w,min_w,mean_w,sdev_w,$
                     dat_min_w,dat_max_w,rot_angle,sites_list,$
                     timestyle_list,timestyle_droplist,other_time_w,$
                     pac_ra_w,pac_dec_w,pac_value_w,field,$
                     utcschedfile,showvis,mission_file
                     
  loadct,39

  sites_list = read_coord_data(!HEXSKYROOT+'/data/sites.dat',1)
  tz         = calc_tz(sites_list(0).longitude,DST='on')


  base = widget_base(/column,title='CDUST dust level simulator',/base_align_center)

  if n_elements(missionfile) gt 0 then mission_file = missionfile

  if n_elements(utc_schedulefile) gt 0 then begin
      utcschedfile = utc_schedulefile
      schedule     = read_schedulefile(utcschedfile)
      jd           = get_jd_from_schedule(schedule)     
      jd0          = jd[0] + tz/24.
      delvarx,schedule
  endif else begin
      jd0 = systime(/Julian)
  endelse
  daycnv,jd0,year,month,day,hour


  moll_input_base = widget_base(base,/column,/base_align_center,frame=3)
  moll_title = widget_label(moll_input_base,value='Antisun Region Search Input')

  ;daycnv,systime(/Julian),year,month,day,hour
  year  = strtrim(string(year),2)
  month = strtrim(string(month),2)
  day   = strtrim(string(day),2)
  hour  = strtrim(string(hour,format='(f7.4)'),2)

  date_base = widget_base(moll_input_base,/row,/base_align_center)
  year_w = cw_field(date_base,title='Year:',value=year,xsize=8)
  month_w = cw_field(date_base,title='Month:',value=month,xsize=8)
  day_w = cw_field(date_base,title='Day:',value=day,xsize=8)

  time_base = widget_base(moll_input_base,/row,/base_align_center)

  timestyle_list = ['LT','LST']
  timestyle_droplist = widget_droplist(time_base,value = timestyle_list,uvalue = 'tslist')

  hour_w = cw_field(time_base,title='Decimal Hour:',value=hour,xsize=8)
  other_time_w = cw_field(time_base,title='Corresponding:',value='',/noedit,$
                          xsize = 20)

  location_base = widget_base(moll_input_base,/row,/base_align_center)

  loc_droplist = widget_droplist(location_base,value=sites_list.name,$
                                 uvalue='site_list')
  latitude_w = cw_field(location_base,title='Site Lat:',$
                        value=sites_list(0).latitude,xsize=8)
  longitude_w = cw_field(location_base,title='Site Lon:',$
                        value=sites_list(0).longitude,xsize=8)
  tz_w = cw_field(location_base,title = 'Time Zone',$
                  value = tz, xsize = 3)
  result = update_time()

  moll_button = widget_button(moll_input_base,$
                      value='Show dust map',uvalue='dustmap')

  moll_button2 = widget_button(moll_input_base,$
                      value='Show visibility map',uvalue='vismap')

  toggle_btn_base = widget_base (moll_input_base,/row)
  toggle_btn = widget_button(toggle_btn_base,$
			     value='Recenter map at current zenith',$
			     uvalue='toggle')
  
  toggle_btn2 = widget_button(toggle_btn_base,$
			     value='Recenter map in RA/Dec coords',$
			     uvalue='toggle_radec')

  pac_base = widget_base(base,/column,/base_align_center,frame = 3)
  pac_button = widget_button(pac_base, value = 'Point and Click',$
                             uvalue = 'point_click')
  pac_coord_base = widget_base(pac_base,/row,/base_align_center)
  pac_ra_w = cw_field(pac_coord_base,title='point RA(hr):', value='',xsize=9,/noedit)
  pac_dec_w = cw_field(pac_coord_base,title='point DEC(deg):',value='',xsize=9,/noedit)

  pac_value_w = cw_field(pac_base,title='pixel temp(microK CMB Temp):', value='',$
                         xsize=10,/noedit)

  gnom_input_base = widget_base(base,/column,/base_align_center,frame=3)
  gnom_title = widget_label(gnom_input_base,value='Dust Level of Sky Patch Input')

  center_base = widget_base(gnom_input_base,/row)
  ctr_ra_w = cw_field(center_base,title='Central RA [deg]:',value='0.0',xsize=8)
  ctr_dec_w = cw_field(center_base,title='Central DEC [deg]:',value='0.0',$
                       xsize=8)

  gnom_par_base = widget_base(gnom_input_base,/row)
  resolution_w = cw_field(gnom_par_base,title='Map Resl. [arcmin]:',$
                          value = '1.5',xsize=5)
  pxsize_w = cw_field(gnom_par_base,title='x pixel #:',value='1000',xsize=6)
  pysize_w = cw_field(gnom_par_base,title='y pixel #:',value='800',xsize=6)

  scale_par_base = widget_base(gnom_input_base,/row)
  max_w = cw_field(scale_par_base,title='Max plotted signal:',value='4000',$
                   xsize=8)
  min_w = cw_field(scale_par_base,title='Min plotted signal:',value='0',$
                   xsize=8)

  button_base = widget_base(gnom_input_base,/row,/base_align_center)
  gnom_button = widget_button(button_base,$
                      value='Zoom in on desired region',uvalue='gnom',$
                      xsiz=200)
  calc_button = widget_button(button_base,value='Stat of desired region',$
                      uvalue='calc',xsize = 150)

  calc_base = widget_base(base,/column,/base_align_center,frame=3)
  calc_label = widget_label(calc_base,value='Statistics of the Region')
  
  m_base = widget_base(calc_base,column=2,/base_align_center)
  mean_w = cw_field(m_base,title='Mean [micro K]:',value='0.0',xsize=8)
  dat_min_w = cw_field(m_base,title='Min [micro K]:',value='0.0',xsize=8)
  sdev_w = cw_field(m_base,title='Std Dev [micro K]:',value='0.0',xsize=8)
  dat_max_w = cw_field(m_base,title='Max [micro K]:',value='0.0',xsize=8)

  rot_angle = [-1,0,0]

  widget_control,base,/realize

  xmanager,'CDUST',base,/no_block

END
