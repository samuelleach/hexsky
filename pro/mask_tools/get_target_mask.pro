function get_target_mask,mytarget,radius,nside,gal_coords=gal_coords

  ;AUTHOR:  S. Leach
  ;PURPOSE: Returns a healpix mask (nest ordering, nside) excluding
  ;         all pixels except those within a radius around a given target.

  ; eg.
  ; HIDL> gnomview,get_target_mask('crab',1.,512),/nest,rot=target('crab',/galactic)

   if(n_elements(gal_coords) eq 0) then begin
      coords = target(mytarget,/galactic)
   endif else begin
      coords = gal_coords
   endelse

    
   Ang2Vec, coords[1], coords[0], vec_cen, /astro
   QUERY_DISC, nside, vec_cen, radius,Listpix, npix, /deg, /inclusive

   mask          = make_array(nside2npix(nside),value=0.)
   mask[listpix] = 1.
   mask          = reorder(mask,/r2n)

   return, mask

end
