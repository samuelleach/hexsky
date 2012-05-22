pro check_pointing_constraints,pointing_dirfilename,mission

  ;AUTHOR: S. Leach
  ;PURPOSE: Check that the pointing satisfies the constraints
  ;         encoded in the mission file (elevation and anti-sun proximity)
  ;         as well as distance from the moon.


  ;Factor by which we will reduce the number of samples that are checked.
  ;Bottleneck below is determination of the moon position (moonpos.pro).
  compression_factor = 10.

  ;------------------------------
  ;; Check elevation constraints:
  ;------------------------------
  error  = readfield(pointing_dirfilename,'EL',nsn, dtrt, el, nfifu)
  error  = readfield(pointing_dirfilename,'RJD',nsn, dtrt, rjd, nfifu)
  minmax_rjd = minmax(rjd)
  minmax_el  = minmax(el)

  ;-----------------------------
  ;Reduce the number of samples:
  ;-----------------------------
  nsn_compressed = floor(nsn/compression_factor)
  print,'Compressing Julian day and elevation samples by a factor '+strtrim(compression_factor,2)
  rjd = congrid(rjd,nsn_compressed)
  el  = congrid(el,nsn_compressed)
  
  if((minmax_el[0] gt mission.elevation_lowerlimit_deg*!dtor) and $
     (minmax_el[1] lt mission.elevation_upperlimit_deg*!dtor)) then begin
      title='Elevation okay: '+strtrim(mission.elevation_lowerlimit_deg,2)+$
        ' < el [deg] < '+strtrim(mission.elevation_upperlimit_deg,2)
      print,title
  endif else begin
      index_toohigh = where(el gt mission.elevation_upperlimit_deg,count_toohigh)
      index_toolow  = where(el lt mission.elevation_lowerlimit_deg,count_toolow)
      title='Elevation limits violated'

     if(count_toohigh gt 0) then begin
         print,'Elevation upper limit violated '
     endif

     if(count_toolow gt 0) then begin
         print,'Elevation lower limit violated '
     endif
  endelse
  xtitle='Julian Day - '+strtrim(long(!constant.rjd0),2)
  window,1
  plot,RJD,el*!radeg,title=title,xtitle=xtitle,$
    ytitle='Elevation of scan [deg]',yrange=[min(el)*0.7,max(el)*1.1]*!radeg,$
    xrange=minmax_rjd,xstyle=1,ystyle=1,charsize=1.8
  oplot,minmax_rjd,[mission.elevation_lowerlimit_deg,mission.elevation_lowerlimit_deg],$
    line=2
  oplot,minmax_rjd,[mission.elevation_upperlimit_deg,mission.elevation_upperlimit_deg],$
    line=2
  delvarx,el

  ;--------------------------------------
  ;Check RA and Dec as a function of time
  ;--------------------------------------
  error  = readfield(pointing_dirfilename,'RA',nsn, dtrt, ra_rad, nfifu)
  error  = readfield(pointing_dirfilename,'DEC',nsn, dtrt, dec_rad, nfifu)
  print,'Compressing RA and dec samples by a factor '+strtrim(compression_factor,2)
  ra_rad= congrid(ra_rad,nsn_compressed)
  dec_rad = congrid(dec_rad,nsn_compressed)

  window,2
  plot,RJD,dec_rad*!radeg,xtitle=xtitle,$;title=title,$
    ytitle='Declination [deg]',xrange=minmax_rjd,xstyle=1,charsize=1.8
;  plot,RJD,ra_rad*!radeg,xtitle=xtitle,$;title=title,$
;    ytitle='RA [deg]',xrange=minmax_rjd,xstyle=1,charsize=1.8,$
;    yrange=minmax(ra_rad*!radeg)

  ;---------------------------------------
  ; Check proximity to anti-sun direction:
  ;---------------------------------------  
  nsn = n_elements(ra_rad)
  v = fltarr( nsn, 3)
  cosdec_rad = cos(dec_rad)
  v[*,0] = cos(ra_rad)*cosdec_rad
  v[*,1] = sin(ra_rad)*cosdec_rad
  v[*,2] = sin(dec_rad)
  delvarx, cosdec_rad

  antisunpos,!constant.rjd0+RJD,ra_rad,dec_rad,/radian
  vs = fltarr( nsn, 3)
  cosdec_rad = cos(dec_rad)
  vs[*,0] = cos(ra_rad)*cosdec_rad
  vs[*,1] = sin(ra_rad)*cosdec_rad
  vs[*,2] = sin(dec_rad)
  delvarx, cosdec_rad
  delvarx, ra_rad
  delvarx, dec_rad

  print,'Getting angular distance between boresight and the anti-sun direction [deg]'
  angdist_prenorm2, v, vs, dist_to_antisun
  delvarx,vs
  minmax_dist_to_antisun = minmax(dist_to_antisun)
  if (minmax_dist_to_antisun[1] lt mission.antisun_radius_deg*!dtor) then begin
      title='Anti-sun okay: anti-sun distance [deg] < '+$
        strtrim(mission.antisun_radius_deg,2)
  endif else begin
      title='Anti-sun violated: anti-sun distance [deg] > '+$
        strtrim(mission.antisun_radius_deg,2)
  endelse
  print,title
  window,0
  plot,RJD,dist_to_antisun*!radeg,xtitle=xtitle,title=title,$
    ytitle='Distance from anti-sun direction [deg]',yrange=minmax_dist_to_antisun*!radeg,$
    xrange=minmax_rjd,xstyle=1,charsize=1.8
  delvarx,dist_to_antisun

  ;---------------------------
  ;; Check distance from moon:
  ;---------------------------
  moonpos,!constant.rjd0+RJD,ra_rad,dec_rad,dis, geolong, geolat,/RADIAN
  delvarx,dis
  delvarx,geolong
  delvarx,geolat

  vm = fltarr( nsn, 3)
  cosdec_rad = cos(dec_rad)
  vm[*,0] = cos(ra_rad)*cosdec_rad
  vm[*,1] = sin(ra_rad)*cosdec_rad
  vm[*,2] = sin(dec_rad)
  delvarx, cosdec_rad
  delvarx, ra_rad
  delvarx, dec_rad

  print,'Getting angular distance between boresight and the moon direction [deg]'
  angdist_prenorm2, v, vm, dist_to_moon
  delvarx,vm
  minmax_dist_to_moon = minmax(dist_to_moon)
;  if (minmax_dist_to_moon[1] lt mission.antisun_radius_deg*!dtor) then begin
;      title='Anti-sun okay: anti-sun distance [deg] < '+$
;        strtrim(mission.antisun_radius_deg,2)
;  endif else begin
;      title='Anti-sun violated: anti-sun distance [deg] > '+$
;        strtrim(mission.antisun_radius_deg,2)
;  endelse
;  print,title
  window,3
  title='Distance between boresight and moon direction'
  plot,RJD,dist_to_moon*!radeg,xtitle=xtitle,title=title,$
    ytitle='Distance from moon direction [deg]',yrange=minmax_dist_to_moon*!radeg,$
    xrange=minmax_rjd,xstyle=1,charsize=1.8
  delvarx,dist_to_moon
  
  delvarx,v
  delvarx,rjd


end
