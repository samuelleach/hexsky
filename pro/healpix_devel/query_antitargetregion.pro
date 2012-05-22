pro query_antitargetregion, jd, lon, lat, target, tolerance, minel,maxel,targetsetel, nside, listpix

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns the list of pixels in an annulus that
  ;         defines the anti-sun or moon region.

  constraint = 180.-tolerance

  case(strlowcase(target)) of
     'sun': begin
        sunpos,jd,target_ra,target_dec
     end
     'moon': begin
        moonpos,jd,target_ra,target_dec
     end
  endcase

  ;Get horizon coords of target
  eq2hor,target_ra,target_dec,jd,target_alt,target_az,lat=lat,lon=lon,$
         PRECESS_= 0, NUTATE_= 0, REFRACT_= 0,ABERRATION_= 0

  ;Get anti-target azimuth
  antitarget_az = (target_az + 180.) mod 360.
  
  
  if target_alt gt targetsetel then begin
     query_horizonpatch,nside,minel,maxel,antitarget_az-constraint,antitarget_az+constraint,listpix,npix
  endif else begin
     ; Target has set below targetsetel. Get '360 degree panorama'
     query_strip,nside,!pi/2.-maxel*!dtor,!pi/2.-minel*!dtor,listpix,nlist
  endelse
     
  ; Get horizon coordinates of pixels
  pix2ang_ring,  nside, listpix,regionel,regionaz

  ;Rotate pixels to equatorial
  regionaz = regionaz         * !radeg
  regionel = (!pi/2.-regionel)* !radeg
  hor2eq,regionel,regionaz,jd,ra,dec,lat=lat,lon=lon,$
         PRECESS_= 0, NUTATE_= 0, REFRACT_= 0,ABERRATION_= 0
  ;Get new pixel numbers
  ang2pix_ring,nside,(!pi/2.-dec*!dtor),ra*!dtor,listpix


end
