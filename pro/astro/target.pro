FUNCTION target,target,galactic=galactic,ra_hr=ra_hr

  ;AUTHOR:  S. Leach
  ;PURPOSE: Provide functional wrapper to target_coords.pro

  target_coords,ra,dec,target


  if(keyword_set(galactic)) then begin
      euler,ra,dec,l,b,1        ; Rotate from RA/DEC to Galactic l/b
      ra  = l
      dec = b
  endif
 
  if(keyword_set(ra_hr)) then begin
      ra = ra/15d0
  endif            

 return,[ra,dec]

end
