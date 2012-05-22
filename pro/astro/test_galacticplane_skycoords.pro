pro test_galacticplane_skycoords

  ra_deg  = 18.85*15.
  Dec_deg = 0.98

  print,RA_deg,Dec_deg
  
  coords = galacticplane_skycoords(RA_deg + 10.,Dec_deg,/dec_guess)

  print,coords

  
end

