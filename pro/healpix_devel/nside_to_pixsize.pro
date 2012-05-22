function nside_to_pixsize,nside

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns the size of a Healpix pixel given the nside parameter.

  pixsize=  sqrt(3./!pi)*3600./float(nside)
  
  
  return,pixsize
  
end


  
