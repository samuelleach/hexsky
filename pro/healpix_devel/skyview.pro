pro skyview,inmap , select_in, field=field,color_field=color_field,$
            projection=projection,rot_ang=rot_ang,$
            rot_code=rot_code,$
            nside_vis=nside_vis,$
            _extra=extra

  ;AUTHOR: S. Leach
  ;PURPOSE: Illustrate plotting of healpix maps with target areas.
  ;
  ;         inmap is a healpix map (array or filename).          

  ;         target is an array of Healpix 'outline' structs for plotting with
  ;         outline_coord2uv.pro below. See eg outline__define.pro for
  ;         an example. Coordinates for plotting should be in Celestial.

  ;         outline_col is an array of integers for determining the plot
  ;         color of the outlines.

  ;         projection may be 'orth', 'moll' or 'gnom'

  ;         rot_ang is an array of three Euler angles.

  ;         rot_code is 'e2c', 'e2g', 'c2g','c2e', 'g2c','g2e'
  ;         and is used for rotating the original map and targets.

   nested   = 0
   coord    = 'G'
   case datatype(inmap) of
       'STR': begin             ; fits file
           message,'Reading '+inmap,/con
           read_fits_map,inmap,map,order=order_in,coord=coord_in,nside=nside_in
           if strlowcase(order_in) eq 'nested' then nested = 1
           read_map = 1
       end
       else : begin
           map      = inmap
           nside_in = npix2nside(n_elements(map[*,0])) 
           read_map = 0
           if n_elements(order_in) eq 0 then order_in = 'ring'
       endelse
   endcase

   if n_elements(nside_vis) eq 0 then nside_vis = nside_in
   if nside_vis lt nside_in then begin
      map_save = map
      ud_grade,map,map,nside_out=nside_vis,order_in=order_in
   endif

   if n_elements(projection) eq 0 then projection = 'moll'
   if n_elements(rot_ang) eq 0    then rot_ang    = [0,0,0]
   if n_elements(select_in) eq 0  then select_in  = 1

   if n_elements(rot_ang) gt 2 then begin
      eul_mat = euler_matrix_new(rot_ang[0],-rot_ang[1],rot_ang[2],/Deg, /ZYX)
   endif
   if n_elements(rot_code) eq 0 then begin
       rot_code = ''
       if read_map then begin
          coord    = [coord_in,coord_in]
       endif else begin
          coord    = ['C','C']
       endelse
   endif else begin
       case strlowcase(strtrim(rot_code,2)) of
           'c2e':  coord=['C','E']
           'e2c':  coord=['E','C']
           'c2g':  coord=['C','G']
           'g2c':  coord=['G','C']
           'e2g':  coord=['E','G']
           'g2e':  coord=['G','E']
           else:  begin
               message,'Not a valid rotation code: ',rot_code 
           end
       endcase
       eul_mat = eul_mat # invert(get_rot_matrix(rot_code))
   endelse

   if n_elements(field) gt 0 then begin
       if n_elements(color_field) eq 0 then $
          color_field = make_array(n_elements(field),value=1)
   endif

;   title=' '    
   charsize=1.4                 ; PS plots
   
   half_sky=1
;   units= textoidl('\muK')
;   units='!4l!3K
   case strlowcase(strtrim(projection,2)) of
       'orth': begin
           orthview,map,select_in,rot=rot_ang,nested=nested,$
             title=title,charsize=charsize,pxsize=500,coord = coord,$
             _extra=extra,half_sky=half_sky,/silent
       end
       'moll': begin
           mollview,map,select_in,rot=rot_ang,nested=nested,$
             title=title,charsize=charsize,coord = coord,$
             _extra=extra,/silent
       end
       'gnom': begin
           gnomview,map,select_in,rot=rot_ang,nested=nested,$
             title=title,charsize=charsize,pxsize=500,coord = coord,$
             _extra=extra,/silent
       end
   endcase


   thick=3.0


   ;Plot targets
   for ff=0, n_elements(field)-1L do begin
      outline_coord2uv,field[ff],coord_out,eul_mat,$
                       projection=projection,/show,thick=thick,$
                       col=color_field[ff],$
                       half_sky=half_sky
   endfor
   
   
end
