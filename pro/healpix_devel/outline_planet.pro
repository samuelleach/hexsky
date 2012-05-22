function outline_planet, planet,jd,diameter=diameter

  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct (circle) for use with
  ;         the Healpix plotting command outline_coord2uv.

  if n_elements(diameter) eq 0 then diameter=0.6

  planet_coords, jd, ra, dec, planet=planet, /jd, /jpl

  outline           = outline_circle(ra[0],dec[0],diameter)
  outline.linestyle = -2

  return, outline
  
END
