PRO antisunpos, jd, ra, dec, RADIAN = radian, _extra=extra

  ;AUTHOR: S. Leach
  ;PURPOSE: Get anti-sun direction, based on astrolib sunpos.pro

  if(keyword_set(radian)) then begin
      factor = !dtor
  endif else begin
      factor = 1.
  endelse


  sunpos, jd, ra, dec, RADIAN = radian, _extra=extra

  dec = -dec
  ra = modpos(ra + 180.*factor, wrap= 360.*factor)



end
