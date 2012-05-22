FUNCTION get_focalplane_orientation,ra,dec,jd,lon,lat,horizon_coords=horizon_coords

    ;AUTHOR: S. Leach
    ;PURPOSE: Returns the orientation of the focalplane
    ;         with respect to the local meridian.

    if keyword_set(horizon_coords) then begin
        ;Get celestial coords coordinates of target
        az_target  = ra
        el_target  = dec
        hor2eq, el_target,  az_target, jd, ra_target,  dec_target, lon=lon,lat=lat
    endif else begin
        ;Get horizon coordinates of target
        ra_target  = ra
        dec_target = dec
        eq2hor, ra_target,  dec_target,  jd, el_target,  az_target, lon=lon,lat=lat
    endelse

    
    ;Displace horizon elevation coordinates by 10 arcsec
    hor2eq, el_target+10./60./60., az_target,jd,$
      ra_target_displaced,dec_target_displaced,lon=lon,lat=lat
    

    beta = !PI - atan((ra_target_displaced  - RA_target )*!dtor*cos(dec_target*!dtor),$
                      (dec_target_displaced - dec_target)*!dtor)

    return,beta

end
