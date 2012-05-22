pro hexsky_write_sunazel_fields,hexsky_dirfile,moonazel=moonazel

  ;AUTHOR: S. Leach
  ;PURPOSE: Read in pointing data from a hexsky dirfile and write out the Sun az and
  ;         el in degrees.

  
  ;-------------------------------------------------
  ; Check to see if AZ_SUN already exists in dirfile
  ;-------------------------------------------------
  if (dirfile_fieldexists(hexsky_dirfile,'AZ_SUN')) then begin
     message,'Warning: AZ_SUN field already exists in dirfile '+hexsky_dirfile,/continue
     return
  endif

  rjd   = readfields(hexsky_dirfile,'RJD')
  lon   = readfields(hexsky_dirfile,'LON')  
  lat   = readfields(hexsky_dirfile,'LAT')  
  nsamp = n_elements(lon[0,*])
  

  ;DOWNSAMPLE JD here
  sample_rate        = ((rjd[1]-rjd[0])*24.*3600)^(-1) ; Hz
  target_sample_rate = 0.05                            ; Hz
  compression_factor = sample_rate/target_sample_rate
  nsamp_compressed   = floor(nsamp/compression_factor)
  rjd_compressed     = congrid(reform(rjd),nsamp_compressed)
  lon_compressed     = congrid(reform(lon),nsamp_compressed)
  lat_compressed     = congrid(reform(lat),nsamp_compressed)

  
  print,'Getting Sun position in RA/Dec'
  sunpos, !constant.rjd0 + rjd_compressed, ra_sun, dec_sun

  print,'Converting Sun position to Az/El'
  eq2hor_veclonlat, ra_sun,  dec_sun,  !constant.rjd0+rjd_compressed,$
                    el_sun,  az_sun, lon=lon_compressed,lat=lat_compressed,$
                    refract_=0,nutate_=0,abberation_=0,precess_=0
    

  ;Uncompress az and el
  el_sun = congrid(el_sun,nsamp)
  az_sun = congrid(az_sun,nsamp)

  message,'Writing AZ_SUN field',/continue
  err = writefield(hexsky_dirfile,'AZ_SUN',az_sun)
  message,'Writing EL_SUN field',/continue
  err = writefield(hexsky_dirfile,'EL_SUN',el_sun)


  ;----------------------
  ;Get the moon az and el
  ;----------------------
  if(keyword_set(moonazel)) then begin
     print,'Getting Moon position in RA/Dec'
     moonpos, !constant.rjd0 + rjd_compressed, ra_moon, dec_moon

     print,'Converting Moon position to Az/El'
     eq2hor_veclonlat, ra_moon,  dec_moon,  !constant.rjd0+rjd_compressed,$
                       el_moon,  az_moon, lon=lon_compressed,lat=lat_compressed,$
                       refract_=0,nutate_=0,abberation_=0,precess_=0


    ;Uncompress az and el
     el_moon = congrid(el_moon,nsamp)
     az_moon = congrid(az_moon,nsamp)

     message,'Writing AZ_MOON field',/continue
     err = writefield(hexsky_dirfile,'AZ_MOON',az_moon)
     message,'Writing EL_MOON field',/continue
     err = writefield(hexsky_dirfile,'EL_MOON',el_moon)
  endif

end
