pro radeclst2azel,ra_deg,dec_deg,lst_hr,lat_deg,az_deg,el_deg


  ;AUTHOR: S. Leach
  ;PURPOSE: Conver Ra, Dec and LST to az and el horizon coords.

;  lat_rad = lat_deg*!dtor
;  ra_rad  = ra_deg*!dtor
;  dec_rad = dec_deg*!dtor
;  ha_rad  = lst_hr*15.*!dtor - ra_rad 

;  altaz,ha_rad,lat_rad,dec_rad,alt_rad,az_rad
;  az_deg = az_rad*!radeg
;  el_deg = alt_rad*!radeg


  ha_deg  = lst_hr*15. - ra_deg 
  hadec2altaz,ha_deg,dec_deg,lat_deg,el_deg,az_deg
  



end
