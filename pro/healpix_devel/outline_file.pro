function outline_file,file

  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct for use with
  ;         the Healpix plotting command outline_coord2uv.
  ;         The struct contains the coordinates found in
  ;         a two column ascii file with RA and Dec (deg).
  
  readcol,file,ra,dec,/silent
  nvert   = n_elements(ra)
  
  outline = {outline}
  nout    = n_elements(outline.ra)

  outline.ra  = make_array(nvert,value=0.)
  outline.dec = make_array(nvert,value=0.)

  
  outline.coord             = 'C'
  outline.ra                = ra
  outline.dec               = dec
  outline.ra(nvert:nout-1)  = ra(nvert-1)
  outline.dec(nvert:nout-1) = dec(nvert-1)

  outline.linestyle = -1
  outline.psym      = 0
  outline.symsize   = 1

  return, outline
  
END
