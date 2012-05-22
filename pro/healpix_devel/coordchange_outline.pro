function coordchange_outline,outline,euler_code

  ;AUTHOR: S. Leach
  ;PURPOSE: Perform a coordinate change of a Healpix outline using astrolib euler.pro

  ;      SELECT   From          To        |   SELECT      From            To
  ;       1     RA-Dec (2000)  Galactic   |     4       Ecliptic      RA-Dec
  ;       2     Galactic       RA-DEC     |     5       Ecliptic      Galactic
  ;       3     RA-Dec         Ecliptic   |     6       Galactic      Ecliptic  
  
  ra  = outline.ra
  dec = outline.dec

  euler,ra,dec,l,b,euler_code

  outline.ra  = l
  outline.dec = b


  return,outline


end
