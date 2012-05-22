function outline_ecliptic,dummy=dummy

  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct (ecliptic in RA/Dec) for use with
  ;         the Healpix plotting command outline_coord2uv

  outline = {outline}
  nn      = n_elements(outline.ra)
  theta   = 0.*findgen(nn)
;  phi     = findgen(nn)*540./float(nn)
  phi     = -180. + findgen(nn)*540./float(nn)

  ang2vec,theta,phi,vector,/astro
  coortrans,vector,coord_out,'e2c'
  vec2ang,coord_out,dec,ra,/astro
  
  outline.coord='C'
  outline.ra=ra
  outline.dec=dec
  outline.linestyle=-1
  outline.psym=0
  outline.symsize=1

  return, outline
  

  
END
