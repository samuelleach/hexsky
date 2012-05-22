function get_cossuninc_map,nside,jd,lon,lat,panel_el_deg,panel_az_offset_deg,$
                           sun_az_deg=sun_az_deg,sun_el_deg=sun_el_deg,pix_el_deg=pix_el_deg,$
                           moon=moon,scope=scope


  ;AUTHOR:   S. Leach
  ;PURPOSE:  Get a map of cos(sun incidence angle) where
  ;          where the sun incidence angle is the angle between
  ;          the sun and a given (solar) panel mounted in elevation 
  ;          at a fixed panel_az_deg and mounted in azimuth at an
  ;          offset panel_az_offset_deg to the required telescope azimuth.
  ;          Also handles case of moon angle onto a skyward telescope
  ;          as opposed to a fixed panel (with a badly written API..).

  ;--------------------------------
  ; Get the Sun (or moon) az and el
  ;--------------------------------
  if keyword_set(moon) then begin
     moonpos,jd,sun_ra,sun_dec
  endif else begin
     sunpos,jd,sun_ra,sun_dec
  endelse
  eq2hor,sun_ra,sun_dec,jd,sun_el_deg,sun_az_deg,lat=lat,lon=lon

  ;--------------------------------
  ; Get the az and el of the pixels
  ;--------------------------------
  listpix     = lindgen(nside2npix(nside))
  pix2ang_ring,  nside, listpix,pix_dec,pix_ra
  pix_dec_deg = (!pi/2.-pix_dec)* !radeg
  pix_ra_deg  = pix_ra* !radeg
  eq2hor,pix_ra_deg,pix_dec_deg,jd,pix_el_deg,pix_az_deg,lat=lat,lon=lon,abberation_=0,nutate_=0,precess_=0,refract_=0
  
  ;-----------------------------------
  ; Calculate cos(sun incidence angle)
  ;-----------------------------------
  panel_az_offset     = panel_az_offset_deg*!dtor
  panel_el            = panel_el_deg*!dtor
  sun_az              = sun_az_deg*!dtor
  sun_el              = sun_el_deg*!dtor
  pix_az              = pix_az_deg*!dtor
  pix_el              = pix_el_deg*!dtor
  if keyword_set(scope) then begin
     cosAngleOfIncidence = sin(sun_el)*cos(!dpi/2.-pix_el) + $
                           cos(sun_el)*sin(!dpi/2.-pix_el)*cos(sun_az - pix_az )
  endif else begin ; Panel
     cosAngleOfIncidence = sin(sun_el)*cos(!dpi/2.-panel_el) + $
                           cos(sun_el)*sin(!dpi/2.-panel_el)*cos(sun_az - (pix_az + panel_az_offset) )
  endelse

  return,cosAngleOfIncidence

end


pro test_get_cossuninc_map
  
  year  = 2011
  month = 12
  day   = 5 + dindgen(40)

  ind = -1
  read_fits_map,!HEXSKYROOT+'/data/dust_carlo_150ghz_512_radec.fits',dust150,order=order
  ud_grade,dust150,dust150,nside_out=128,order_in=order

  min     = 0.8
  max     = 0.98
  dustmax = 200.

  factor  = conversion_factor('uK_RJ','uK_CMB',150.e9)
  dust150 = dust150*factor 
  dust150 = (max-min)/200.*dust150 + min

  for dd = 0,n_elements(day)-1 do begin
     ind = ind + 1

     nside        = 128
     JDCNV, year, month, day[dd], 0, jd
     lon          = 0.
     lat          = -78.8
     panel_el_deg = 23.5
     panel_az_deg = 180.
     
     ra_centre = 82. & dec_centre = -44.5 & delta_ra = 25. & delta_dec = 19.
     ra_min    = ra_centre - delta_ra/2.   & ra_max  = ra_centre + delta_ra/2. 
     dec_min   = dec_centre - delta_dec/2. & dec_max = dec_centre + delta_dec/2 
     ebex_annulus1 = outline_annulus(ra_min,ra_max,dec_min,dec_max)
     
     outline = [ebex_annulus1,outline_ecliptic(),$
                outline_galacticplane(),$
                outline_target('rcw38',2),$
                outline_target('pks0537-441',2)]
     
     outstring = strtrim(year,2)+'_'+strtrim(month,2)+'_'+strtrim(floor(day[dd]),2)
     
     

     map = get_cossuninc_map(nside,jd,lon,lat,panel_el_deg,panel_az_deg,pix_el_deg=pix_el_deg)
     map[where(map le 0.8)]        = !healpix.bad_value
     map[where(pix_el_deg ge 60.)] = !healpix.bad_value
     map[where(pix_el_deg le 30.)] = !healpix.bad_value
     mollview,map,outline=[outline_sunpos(jd,diameter=15.),outline],$
              grat=[15,15],coord=['C','C'],glsize=1,min=min,max=max,$
              chars=1.7,subtitle=jd2dateandtime(jd),title='Solar panel illumination efficiency',$
              units = '',png='sun_'+int2filestring(ind,2)+'.png',window=1

     units = textoidl('[0-200 \muK_{CMB}]')
     index      = where(map eq !healpix.bad_value)
     map[index] = dust150[index]
     mollview,map,outline=[outline_sunpos(jd,diameter=15.),outline],$
              grat=[15,15],coord=['C','C'],glsize=1,min=min,max=max,$
              chars=1.7,subtitle=jd2dateandtime(jd),title='Solar panel illumination efficiency',$
              units = units,png='dust_'+int2filestring(ind,2)+'.png',window=1
     
     
     
     dummy = 0.
     map = get_cossuninc_map(nside,jd,lon,lat,dummy,dummy,/scope,/moon)
     map[where(map le -cos(135.*!dtor))] = !healpix.bad_value
     mollview,map,outline=[outline_sunpos(jd,diameter=15.),outline],$
              coord=['C','C'],grat=[15,15],$
              glsize=1.,chars=1.7,subtitle=jd2dateandtime(jd),title='Moon cos(incidence) angle',$
              png='moon_'+int2filestring(ind,2)+'.png',window=2
endfor


end
