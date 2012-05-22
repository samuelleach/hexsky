function outline_contour, dec

  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct (declination contour) for use with
  ;         the Healpix plotting command outline_coord2uv
  
  outline={outline}
  nvert= n_elements(outline.ra)

  phi    = 90. - dec
  theta  = 2.1*!pi*findgen(nvert)/float(nvert-1)
  x      = phi*cos(theta)
  y      = phi*sin(theta)
  ra_out = 360.*atan(y,x)/(2*!pi)
  dec_out= 90.-sqrt(x^2+y^2)

  outline.coord='C'
  outline.ra=ra_out
  outline.dec=dec_out
  outline.linestyle=-1
  outline.psym=0
  outline.symsize=1

  return, outline
  
END
