function get_cosmooninc_map,jd,lon,lat,nside=nside,moontolerance_deg=moontolerance_deg

  ;AUTHOR:  S. Leach
  ;PURPOSE: Return a map in celestial coordinates of the
  ;         cosIncidenceAngleof the moon incident a telescope
  ;         pointing towards those sky coordiates.

  if n_elements(nside) eq 0 then nside = 64

  dummy = 0.
  map   = get_cossuninc_map(nside,jd,lon,lat,dummy,dummy,/scope,/moon)

  if n_elements(moontolerance_deg) gt 0  then begin
     map[where(map le cos(moontolerance_deg*!dtor))] = !healpix.bad_value
  endif

  return,map
end
