function outline_cross, ra,dec

  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct (cross) for use with
  ;         the Healpix plotting command outline_coord2uv

  outline = create_struct('coord','C', 'ra', ra,'dec', dec,$
			 'linestyle',-1,'psym',1,'symsize',2)
  return, outline
  
END
