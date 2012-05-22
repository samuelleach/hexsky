pro test_rotboresight3

  focalplane = get_na_wafer(150)

  det_index = where(focalplane.power eq 1)
  ndet      = n_elements(det_index)

;  ra0   = 0.
  ra0   = !pi
  dec0  = 0.
  theta0 = 0.

  cosra_bs    = cos(ra0)
  cosdec_bs   = cos(dec0)
  costheta_bs = cos(theta0)
  sinra_bs    = sin(ra0)
  sindec_bs   = sin(dec0)
  sintheta_bs = sin(theta0)

  nside_hitmap = 1024
  hitmap = make_array( nside2npix( nside_hitmap),value=0D)

  for idet = 0, ndet-1 do begin

    index    = det_index(idet)
    
    xoff     = focalplane[index].az
    yoff     = focalplane[index].el

    rotboresight3,cosra_bs,cosdec_bs, sinra_bs,sindec_bs,$
		  costheta_bs,sintheta_bs,xoff,yoff,$
		  ra_rad,dec_rad,sindec_rad
    

    ang2pix_ring2, nside_hitmap, sindec_rad, ra_rad, ipring,/costheta
    for pp = 0L , n_elements(ipring)-1L do begin
        hitmap[ipring[pp]] = hitmap[ipring[pp]] + 1d0
    endfor
    
    
  endfor
  
  hitmap(where(hitmap eq 0.)) = !healpix.bad_value
  gnomview, hitmap, grat=2,gl=1.5,units='hits',$
            rot=[ra0/!dtor,dec0/!dtor],/online,ps='gnom.ps'


end
