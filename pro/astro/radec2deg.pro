pro radec2deg,ra,dec,rahr,ramin,rasec,decdeg,decmn,decsc

  ;AUTHOR: S. Leach
  ;PURPOSE: Convert Ra (hr, min, sec) and Dec (deg,mn,sc) to
  ;         RA and Dec (in degrees)

  RA = (rahr/24.+ ramin/24./60.+ rasec/24./60./60.)*360.
;  dec = decdeg + decmn/60. + decsc/3600.
  dec = (abs(decdeg) + decmn/60. + decsc/3600.)*sign(decdeg)
  
end
