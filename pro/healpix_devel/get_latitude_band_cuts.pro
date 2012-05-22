pro get_latitude_band_cuts,nside,lat_bandwidth_deg,indexcuts,latcuts_deg,nest=nest

  ;AUTHOR: S. Prunet IAP, developer S. Leach
  ;PURPOSE: Set up a set of Healpix map ring indices which
  ;         correspond to bands in latitude.
    
  npix = 12L*nside*nside

  print,'Setting up latitude band indices'
  ipix = lindgen(npix)
;  print,'Running pix2ang'
  if keyword_set(nest) then begin
      pix2ang_nest,nside,ipix,theta,phi
  endif else begin
      pix2ang_ring,nside,ipix,theta,phi
  endelse
;  print,'Finished pix2ang'
  theta  = theta*!radeg ; in degrees
  nbands = long(180./lat_bandwidth_deg)
  if (180. - nbands*lat_bandwidth_deg gt 0.0) then nbands = nbands + 1
  indexcuts = ptrarr(nbands,/allocate_heap)
  latcuts_deg   = fltarr(nbands)

  for ibands = 0,nbands-1 do begin
;     print,'Band ',ibands
     ou = where((theta ge ibands*lat_bandwidth_deg) $
                and (theta lt min([(ibands+1)*lat_bandwidth_deg,180.])))
     *indexcuts(ibands) = ou
     theta_bar           = total(theta[ou],/double)/float(n_elements(ou))
     latcuts_deg[ibands] = theta_bar-90  
  endfor
  theta = 0
  phi   = 0
  ipix  = 0
  print,'Done setting up latitude band indices'

end
