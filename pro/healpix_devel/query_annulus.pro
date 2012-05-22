pro query_annulus, nside, ra, dec, radius, listpix,$
		thickness=thickness

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns the list of pixels in an annulus of radius radius
  ;         around [ra,dec] of thickness thickness.
  ;         All angles in degrees.

  ;EXAMPLE:
  ;nside=512
  ;query_ring,nside,120.,-45.,45.,listpix  
  ;map = make_array(nside2npix(nside),value=1.)
  ;map(listpix)=0.
  ;mollview,map
	    
  if n_elements(thickness) eq 0 then thickness = 1.
  
  Ang2Vec, DEC, RA, vec_cen, /astro
  QUERY_DISC, nside, vec_cen, radius+thickness/2.,$
	      Listpix, npix, /deg, /inclusive
  QUERY_DISC, nside, vec_cen, radius-thickness/2.,$
	      Listpix2, npix, /deg, /inclusive
  listpix=SetDifference(listpix,listpix2)

end
