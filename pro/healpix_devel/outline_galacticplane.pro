function outline_galacticplane,dummy=dummy,b=b

  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct (contour parallel the Galactic plane at
  ;         galactic latitude b, in RA/Dec) for use with
  ;         the Healpix plotting command outline_coord2uv

  if n_elements(b) eq 0 then b = 0
  
  outline = {outline}
  nn      = n_elements(outline.ra)

  theta   = b + 0.*findgen(nn)
  phi     = findgen(nn)*360./float(nn-1)

  ang2vec,theta,phi,vector,/astro
  coortrans,vector,coord_out,'g2c'
  vec2ang,coord_out,dec,ra,/astro
  
  outline.coord     = 'C'
  outline.ra        = ra
  outline.dec       = dec
  outline.linestyle = -1
  outline.psym      = 0
  outline.symsize   = 1

  return, outline
  

  
END
