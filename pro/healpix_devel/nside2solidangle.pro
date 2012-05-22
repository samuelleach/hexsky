function nside2solidangle,nside,sqdeg=sqdeg

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns solid angle of a Healpix pixel given the nside parameter.

  solidangle =  4.*!pi/(12.*double(nside)*double(nside))
   
  if(keyword_set(sqdeg)) then solidangle = solidangle/4./!pi*41252.9612

  return,solidangle
 
end


  
