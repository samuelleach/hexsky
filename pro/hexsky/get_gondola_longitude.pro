function get_gondola_longitude,longitude_start_deg,jd_start,jd_end,orbitspeed

  ;AUTHOR: S. Leach
  
  ; Function to perform a simple iso-latitude gondola orbit.
  ;
  ; N.B. This is the same model as coded in the hexsky C code, $  
  ; in src/ebex_gondola.c, longitude_circumpolar().
  ; 
  ; orbitspeed = 0.1 => 360 degrees of longitude in 10 days.
  ;
  ;  currentlong_deg = start_longitude_deg + 360. * orbitspeed * elapseddays;
  ;  while (currentlong_deg > 180.) currentlong_deg -= 360.;
  ;  while (currentlong_deg < -180.) currentlong_deg += 360.;
        
  longitude_end_deg = longitude_start_deg + 360d0 * orbitspeed * ( jd_end - jd_start )
;  longitude_end_deg = modpos(longitude_end_deg, wrap = 360d0)
  return, longitude_end_deg

end
