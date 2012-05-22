 function outline_moonpos,jd,diameter=diameter

  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct (circle) with
  ;         RA and Dec given by the moon's position,
  ;         and diameter 0.5 deg.
  
   if n_elements(diameter) eq 0 then diameter = 0.5
   
   moonpos, jd, ra, dec, dis, geolong, geolat
  
   outline           = outline_circle(ra[0],dec[0],diameter)
   outline.linestyle = -3

  return, outline
  
END
