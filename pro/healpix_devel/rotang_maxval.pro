FUNCTION rotang_maxval,hmap,ipix=ipix,maxval=maxval


  ;AUTHOR: S. Leach
  ;PURPOSE: Returns the rotation angle (eg for use with mollview or gnomview)
  ;         corresponding to pixel with the maximum value in a healpix
  ;         map.


  nside        = npix2nside(n_elements(hmap))
  
  maxval       = max(hmap)
  ipix         = where(hmap eq maxval)
  pix2ang_ring,nside,ipix,theta,phi
  RA           = phi[0]*180./!pi
  Dec          = 90.-theta[0]*180./!pi
  rot_ang      = [ra,dec]

  return,rot_ang

end
