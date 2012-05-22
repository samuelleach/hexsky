pro deg2dms,decdeg_in,decdeg,decmin,decsec

  ;AUTHOR: S. Leach
  ;PURPOSE: Convert an angle in degrees to degrees,minutes,seconds

  hemisphere   = sign(decdeg_in)
  absdecdeg_in = abs(decdeg_in)

  decdeg  = floor(absdecdeg_in)
  tmp     = (absdecdeg_in - double(decdeg))*60d0
  decmin  = floor(tmp)
  decsec  = (tmp - double(decmin))*60d0

  decdeg  = long(decdeg*hemisphere)
  
end
