function sign, x
; Return the sign of a number (+1 or -1), +1 if 0.


  if n_elements(x) eq 1 then begin
      if x eq 0 then return, 1
      return, x/abs(x)
  endif

  where0 = where(x eq 0) ;,complement=wherenot0) for < IDL 5.4
  wherenot0 = where(x ne 0)

  outsign = x*0

  if where0(0) ne -1 then outsign(where0) = 1
  if wherenot0(0) ne -1 then $
    outsign(wherenot0) = x(wherenot0)/abs(x(wherenot0))

  return, outsign

end
