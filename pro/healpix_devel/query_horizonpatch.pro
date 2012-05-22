pro query_horizonpatch,nside,minel,maxel,minaz,maxaz,listpix,npix



  query_strip,nside,!pi/2.-maxel*!dtor,!pi/2.-minel*!dtor,listpix,nlist

  pix2ang_ring,nside,listpix,theta,phi
  
  my_minaz = minaz
  my_maxaz = maxaz


  if minaz lt 0. then begin
     my_minaz = minaz+360.
  endif
  if maxaz lt 0. then begin
     my_maxaz = maxaz+360.
  endif

  if minaz gt 360. then begin
     my_minaz = minaz-360.
  endif
  if maxaz gt 360. then begin
     my_maxaz = maxaz-360.
  endif


  index1 = where(phi*!radeg gt my_minaz)
  index2 = where(phi*!radeg lt my_maxaz)

  ;Deal with wrapping [0,360]
  if my_minaz lt my_maxaz then begin
    index  = SetIntersection(index1,index2)
  endif  else begin
    index  = SetUnion(index1,index2)
  endelse

  if (index[0] ne -1) then begin
    listpix = listpix[index]
  endif else begin
    listpix = 0
  endelse
  npix    = n_elements(listpix)

end


