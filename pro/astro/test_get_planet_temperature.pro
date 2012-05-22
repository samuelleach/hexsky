pro test_get_planet_temperature

  ;  AUTHOR: S. Leach
  ;  PURPOSE: Test the get_planet_temperature.pro code.
  ;
  ;  Depends on the IDL astrolibs.
  ;  Make sure that the JPL ephemeris file is present, i.e.
  ;  set the ASTRO_DATA environment flag to the directory where
  ;  JPLEPH.405 is found. Can be downloaded from
  ;  http://idlastro.gsfc.nasa.gov/ftp/data/JPLEPH.405
  

   ;Set parameters
   PLANET   = 'JUPITER'
;   PLANET   = 'SATURN'
   FWHM     = 8.
   FREQ_GHZ = 150.

   year     = 2009
   month    = 5
   hour_utc = 10.5

   ;Calculation for May 1st 2009
   day      = 1
   JDCNV, year, month, day, hour_utc, jd
   temp = get_planet_temperature(JD, PLANET, FWHM, FREQ_GHZ,$
                                 planet_diameter_arcmin=planet_diameter_arcmin,$
				 planet_distance_km=planet_distance_km)
   print,strtrim(day,2)+' '+themonths(month)+' '+strtrim(year)
   print,PLANET+' antenna temperature = '+strtrim(temp)+' K'
   print,'('+strtrim(FWHM,2)+'arcmin beam @'+strtrim(freq_ghz)+' GHz)'
   print,PLANET+' angular diameter [arcsec] = '+strtrim(planet_diameter_arcmin*60.,2)+ ' (used above)'
   print,PLANET+' distance from earth  [km] = '+strtrim(planet_distance_km,2)+ ' (used above)'
   print,'Jupiter angular diameter [arcsec] = '+strtrim(36.6,2)+ ' (From Dan P.)'
   print,' '

   ;Calculation for May 30th 2009
   day=30
   JDCNV, year, month, day, hour_utc, jd
   temp = get_planet_temperature(JD, PLANET, FWHM, FREQ_GHZ,$
                                 planet_diameter_arcmin=planet_diameter_arcmin,$
				 planet_distance_km=planet_distance_km)
   print,strtrim(day,2)+' '+themonths(month)+' '+strtrim(year)
   print,PLANET+' antenna temperature = '+strtrim(temp)+' K'
   print,'('+strtrim(FWHM,2)+'arcmin beam @'+strtrim(freq_ghz)+' GHz)'
   print,PLANET+' angular diameter [arcsec] = '+strtrim(planet_diameter_arcmin*60.,2)+ ' (used above)'
   print,PLANET+' distance from earth  [km] = '+strtrim(planet_distance_km,2)+ ' (used above)'
   print,'Jupiter angular diameter [arcsec] = '+strtrim(40.1,2)+ ' (From Dan P.)'


end
