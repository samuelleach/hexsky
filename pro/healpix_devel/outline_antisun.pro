FUNCTION OUTLINE_ANTISUN,jd,lat_deg,lon_deg,$
                         el_lower=el_lower,el_upper=el_upper

  ;Author : C.Bao
  ;Purpose: Creates an outline struct of antisun region at specified
  ;         time with given sun position for use with
  ;         the Healpix plotting command outline_coord2uv

    if n_elements(el_lower) eq 0 then el_lower = 30.
    if n_elements(el_upper) eq 0 then el_upper = 60.

    antisun_constraint = 45.
    
    sunpos,jd,sun_ra,sun_dec
    eq2hor,sun_ra,sun_dec,jd,sun_alt,sun_az,lat=lat_deg,lon=lon_deg
  
    antisun_az = (sun_az + 180.) mod 360.

    outline = {outline}
    nvert   = n_elements(outline.ra)
    
    region_el = fltarr(nvert)
    region_az = fltarr(nvert)
    nside     = nvert/4

    region_el(0:nside-1)           = el_lower + findgen(nside)*el_lower/float(nside)
    region_el(nside:(2*nside-1))   = el_upper
    region_el(2*nside:(3*nside-1)) = el_upper - findgen(nside)*el_lower/float(nside)
    region_el(3*nside:(nvert-1))   = el_lower

    region_az(0:nside-1)           = antisun_az - antisun_constraint
    region_az(nside:(2*nside-1))   = antisun_az - antisun_constraint + $
                                     findgen(nside)*2.*antisun_constraint/float(nside)
    region_az(2*nside:(3*nside-1)) = antisun_az + antisun_constraint
    region_az(3*nside:nvert-1)     = antisun_az + antisun_constraint - $
                                     findgen(nside)*2.*antisun_constraint/float(nside)
    
    hor2eq,region_el,region_az,jd,region_ra,region_dec,lat=lat_deg,lon=lon_deg

    outline.coord     = 'C'
    outline.ra        = region_ra
    outline.dec       = region_dec
    outline.linestyle = -1
    outline.psym      = 0
    outline.symsize   = 1

    return,outline

END
    
    
