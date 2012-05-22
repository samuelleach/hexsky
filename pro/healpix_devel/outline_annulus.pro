function outline_annulus, ra_min,ra_max,dec_min,dec_max, $
			  convert_azel_to_radec=convert_azel_to_radec,$
			  jd=jd,lon_deg=lon_deg,lat_deg=lat_deg,$
                          galactic=galactic,linestyle=linestyle
			  
  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct (annulus) for use with
  ;         the Healpix plotting command outline_coord2uv


  if(n_elements(linestyle) eq 0 ) then linestyle = -1

  outline = {outline}
  nvert   = n_elements(outline.ra)
         
  dummy = findgen(nvert/4)/float(nvert/4-1)
  one   = dummy*0.+1.

  ra = ra_min+(ra_max-ra_min)*dummy
  ra = [ra,one*ra_max]
  ra = [ra,ra_max+(ra_min-ra_max)*dummy]
  ra = [ra,ra_min*one]

  dec = one*dec_max
  dec = [dec,dec_max+(dec_min-dec_max)*dummy]
  dec = [dec,dec_min*one]
  dec = [dec,dec_min+(dec_max-dec_min)*dummy]

  if (keyword_set(convert_azel_to_radec)) then begin
    az = ra
    el = dec
    hor2eq,el,az,jd,ra,dec,lat=lat_deg,lon=lon_deg
  endif
  

  outline.coord     = 'C'
  outline.ra        = ra
  outline.dec       = dec
  outline.linestyle = linestyle
  outline.psym      = 0
  outline.symsize   = 1

  if( keyword_set(galactic) ) then begin
      outline.coord     = 'G' 
  endif

  return, outline

END
