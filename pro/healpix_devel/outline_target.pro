function outline_target, target,diameter_deg,galactic=galactic

  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct (circle) for use with
  ;         the Healpix plotting command outline_coord2uv

  
  target_coords,ra,dec,target
  outline = outline_circle(ra,dec,diameter_deg)

  if( keyword_set(galactic) ) then begin
     ra  = outline.ra
     dec = outline.dec
     euler,ra,dec,lon,lat,1 ; Convert RA/Dec to Galactic Lon/Lat
     outline.ra  = lon
     outline.dec = lat 
  endif


  return, outline
  
END
