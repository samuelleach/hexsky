FUNCTION pol_frac,hpx_map,sigma2Ip=sigma2Ip

  ;AUTHOR: S. Leach
  ;PURPOSE: Function to return the polarization fraction map of a healpix
  ;         IQU map.

  if (n_elements(sigma2Ip) eq 0) then sigma2Ip = 0. ; Bias correction
  
  case datatype(hpx_map) of
    'STR': begin
      read_tqu,hpx_map,map
    end
    else : map = hpx_map
  endcase
 
  npix             = n_elements(map[*,0])
  pol_frac         = make_array(npix,value=0.)
  index            = where(map[*,0] gt 0.)
  pol_frac[index]  = sqrt(map[index,1]^2 + map[index,2]^2 - sigma2ip)/map[index,0]
  
  return, pol_frac
end
