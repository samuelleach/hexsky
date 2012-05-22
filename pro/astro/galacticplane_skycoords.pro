FUNCTION galacticplane_skycoords,RA_deg,Dec_deg,RA_guess=RA_guess,DEC_guess=DEC_guess

  ;AUTHOR: S.Leach and C.Bao
  ;PURPOSE: Returns the RA/DEC coords of the galactic plane in degrees
  ;         at a given RA_deg (Dec_deg) given a guess in Dec_deg (RA_deg).
  
  guess_accuracy = 10. ; deg
;  outline = outline_galacticplane(dummy) ; Contains RA and DEC of GP.

  galacticplane_coords,ra_gal,dec_gal,nn=2000
  
  if(keyword_set(RA_guess)) then begin
     DEC_GP_deg = DEC_deg

;     index = where(abs(dec_gal-dec_gp_deg) lt 1.)

     
     
  ;get part of the galactic plane with close RA
     guess_indices = where(abs(RA_gal-RA_guess) lt guess_accuracy)
     RA_range      = RA_gal[guess_indices]
     DEC_range     = DEC_gal[guess_indices]

  ;find closest DEC and RA
     final_index = where(abs(DEC_range-DEC_GP_deg) eq min(abs(DEC_range-DEC_GP_deg)))
     DEC_GP_deg  = DEC_range[final_index]
     RA_GP_deg   = RA_range[final_index]

  endif else if(keyword_set(DEC_guess)) then begin

     RA_GP_deg  = RA_deg

  ;get part of the galactic plane with close DEC
     guess_indices = where(abs(DEC_gal-DEC_guess) lt guess_accuracy)
     RA_range      = RA_gal[guess_indices]
     DEC_range     = DEC_gal[guess_indices]

  ;find closest DEC and RA
     final_index = where(abs(RA_range-RA_GP_deg) eq min(abs(RA_range-RA_GP_deg)))
;     print,final_index
     DEC_GP_deg = DEC_range[final_index]
     RA_GP_deg = RA_range[final_index]

 endif else $
     message,'Must set keyword RA_guess or DEC_guess and provide a corresponding guess.'  

  return, [RA_GP_deg,DEC_GP_deg]

end
