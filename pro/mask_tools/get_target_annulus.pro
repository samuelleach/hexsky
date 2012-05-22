function get_target_annulus,mytarget,innerradius,outerradius,nside,gal_coords=gal_coords

  ;AUTHOR:  S. Leach
  ;PURPOSE: Returns a healpix mask (nest ordering, nside) with an
  ;         annulus that exlcudes pixels around a target

  ; eg.
  ; HIDL> gnomview,get_target_annulus('perseus',1.5.,3.,128),/nest,rot=target('perseus',/galactic)

   if(n_elements(gal_coords) eq 0) then begin
      coords = target(mytarget,/galactic)
   endif else begin
      coords = gal_coords
   endelse

   
   radius    = (outerradius + innerradius)/2.
   thickness = (outerradius - innerradius)
 
   query_annulus,nside,coords[0],coords[1],radius,listpix,thickness=thickness
  
   mask          = make_array(nside2npix(nside),value=0.)
   mask[listpix] = 1.
   mask          = reorder(mask,/r2n)

   return, mask

end
