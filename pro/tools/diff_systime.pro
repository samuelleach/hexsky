function diff_systime,lastsystime

  ;AUTHOR: S.Leach
  ;PURPOSE: Use for timing tests.

  ;EXAMPLE:

  ;IDL> a = diff_systime(0.)
  ;IDL> a = diff_systime(a)

  nextsystime      = systime(/seconds)
  if lastsystime ne 0. then  print,'dT [sec] = ',nextsystime-lastsystime

  return, nextsystime

end
