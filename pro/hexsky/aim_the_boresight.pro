pro aim_the_boresight,ra_target,dec_target,jd,lon,lat,xoff,yoff,ra_bs,dec_bs

  ;AUTHOR:  S. Leach
  ;PURPOSE: Aims the boresight at a direction slightly offset (xoff,yoff)
  ;         from a desired target at ra_target and dec_target.


  beta         = get_focalplane_orientation(ra_target,dec_target,jd,lon,lat)
  theta_target = !pi + beta

  cosra_target    = cos(ra_target*!dtor)
  sinra_target    = sin(ra_target*!dtor)

  cosdec_target   = cos(dec_target*!dtor)
  sindec_target   = sin(dec_target*!dtor)

  costheta_target = cos(theta_target)
  sintheta_target = sin(theta_target)

  rotboresight3,cosra_target,cosdec_target, sinra_target,sindec_target,$
    costheta_target,sintheta_target,-xoff*!dtor,-yoff*!dtor,$
    ra_bs,dec_bs,sindec_rad

  ra_bs  = ra_bs/!dtor
  dec_bs = dec_bs/!dtor    

end
