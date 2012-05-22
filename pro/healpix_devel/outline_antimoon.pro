FUNCTION OUTLINE_ANTIMOON,jd,lat_deg,lon_deg,$
                          constraint=constraint,$
                          el_lower=el_lower,el_upper=el_upper

  ;AUTHOR : S. Leach
  ;PURPOSE: Creates an outline struct of antimoon region at specified
  ;         time for the Healpix plotting command outline_coord2uv

  ;COMMENT: Too much code overlap with outline_antisun.pro.

    if n_elements(constraint) eq 0 then constraint = 90. ; degrees from anti-moon direction
    if n_elements(el_lower)   eq 0 then el_lower   = 30.
    if n_elements(el_upper)   eq 0 then el_upper   = 60.
  
    moonpos,jd,moon_ra,moon_dec
    eq2hor,moon_ra,moon_dec,jd,moon_alt,moon_az,lat=lat_deg,lon=lon_deg
    antimoon_az = (moon_az+180.) mod 360.

    outline = {outline}
    nvert   = n_elements(outline.ra)
    
    region_el = fltarr(nvert)
    region_az = fltarr(nvert)

    nside = nvert/4

    region_el(0:nside-1)           = el_lower+findgen(nside)*el_lower/nside
    region_el(nside:(2*nside-1))   = el_upper
    region_el(2*nside:(3*nside-1)) = el_upper-findgen(nside)*el_lower/nside
    region_el(3*nside:(nvert-1))   = el_lower

    region_az(0:nside-1)           = antimoon_az-constraint
    region_az(nside:(2*nside-1))   = antimoon_az-constraint+$
	       findgen(nside)*constraint*2./nside
    region_az(2*nside:(3*nside-1)) = antimoon_az+constraint
    region_az(3*nside:nvert-1)     = antimoon_az+constraint-$
	       findgen(nside)*constraint*2./nside
    
    hor2eq,region_el,region_az,jd,region_ra,region_dec,lat=lat_deg,lon=lon_deg

    outline.coord     ='C'
    outline.ra        = region_ra
    outline.dec       = region_dec
    outline.linestyle = -1
    outline.psym      = 0
    outline.symsize   = 1

    return,outline

END
    
    
