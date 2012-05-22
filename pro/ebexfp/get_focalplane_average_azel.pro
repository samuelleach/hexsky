pro get_focalplane_average_azel,focalplane,average_az,average_el

  det_index             = where(focalplane[*].power eq 1)
  ndet                  = n_elements(det_index)
  average_el = total(focalplane[det_index].el,/double)/float(ndet)/!dtor
  average_az = total(focalplane[det_index].az,/double)/float(ndet)/!dtor
	  
end