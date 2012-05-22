function outline_polygon,ra,dec

  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct for use with
  ;         the Healpix plotting command outline_coord2uv.
  ;         ra and dec are a list of the polygon vertices.
  
  
  outline = {outline}
  nvert   = n_elements(ra)
  nout    = n_elements(outline.ra)

  outline.coord  = 'C'
  outline.ra     = ra
  outline.dec    = dec
  outline.ra(nvert:nout-1)  = ra(nvert-1)
  outline.dec(nvert:nout-1) = dec(nvert-1)

  outline.linestyle = -1
  outline.psym      = 0
  outline.symsize   = 1

  return, outline
  
END
