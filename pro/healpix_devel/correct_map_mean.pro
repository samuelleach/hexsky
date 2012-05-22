pro correct_map_mean,map,target_meanval

  ;AUTHOR: S. Leach
  ;PURPOSE: Add an offset to a map in order to acheive a desired map
  ;         mean value.

   index      = where(map ne !healpix.bad_value,np)
   meanval    = total(map[index],/double)/double(np)
   map[index] = map[index] + target_meanval - meanval
 
end
