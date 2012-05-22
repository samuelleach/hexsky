function get_intersection_mask,map1,map2

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns a mask corresponding to the intesection of map1 and
  ;         map2 (excluding zeros and undefined pixels)

  index1 = where ((map1 ne 0.) and (map1 ne !healpix.bad_value))
  index2 = where ((map2 ne 0.) and (map2 ne !healpix.bad_value))
  
  index       = setintersection(index1,index2)
  mask        = make_array(n_elements(map1),value=0)
  mask[index] = 1

  return,mask

end
