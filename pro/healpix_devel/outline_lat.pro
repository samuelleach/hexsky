FUNCTION OUTLINE_LAT,jd,el,lat,lon

   ;Author : C. Bao
   ;Purpose: Create a outline structure of constant
   ;         elevation line at certain time at specific location
   ;         for use with the Healpix plotting command
   ;         outline_coord2uv

  outline = {outline}
  nvert   = n_elements(outline.ra)

  region_az = findgen(nvert)*360/nvert

  region_el            = fltarr(nvert)
  region_el(0:nvert-1) = el+0.0

  hor2eq,region_el,region_az,jd,region_ra,region_dec,lat=lat,lon=lon

  outline.coord     = 'C'
  outline.ra        = region_ra
  outline.dec       = region_dec
  outline.linestyle = -1
  outline.psym      = 0
  outline.symsize   = 1

  return,outline

END  
