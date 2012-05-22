pro galacticplane_coords,ra,dec,nn=nn

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns RA and Dec (deg) of the galactic plane.

  if n_elements(nn) eq 0 then nn = 360L

  theta    = 0.*findgen(nn)
  phi      =    findgen(nn)*360/float(nn-1)

  ang2vec,theta,phi,vector,/astro
  coortrans,vector,coord_out,'g2c'
  vec2ang,coord_out,dec,ra,/astro


end
