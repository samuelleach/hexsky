function outline_circle, ra,dec,diameter_deg,galactic=galactic

  ;AUTHOR: S. Leach
  ;Bases on circoplot.pro by J. Weiland.
  ;PURPOSE: Creates an outline struct (circle) for use with
  ;         the Healpix plotting command outline_coord2uv

  outline = {outline}
  nvert   = n_elements(outline.ra)

  lt0 = dec*!DTOR
  ln0 = ra*!DTOR
  
  xi  = 360.*findgen(nvert)/float(nvert-1) * !DTOR
  
  rad2 = (diameter_deg/2.)*!DTOR
  lat2 = asin((cos(xi)*sin(rad2) +   $
	       cos(rad2)*tan(lt0))/(cos(lt0)+ tan(lt0)*sin(lt0)))
  lon2 = ln0 + atan ((sin(xi)*sin(rad2)*cos(lt0)),   $
		     (cos(rad2) - sin(lt0)*sin(lat2)))
  dec_out = lat2 *!RADEG
  ra_out  = lon2 *!RADEG
  
  if(keyword_set(galactic)) then begin
     outline.coord     = 'G'
  endif else begin
     outline.coord     = 'C'
  endelse
  outline.ra        = ra_out
  outline.dec       = dec_out
  outline.linestyle = -1
  outline.psym      = 0
  outline.symsize   = 1

  return, outline
  
END
