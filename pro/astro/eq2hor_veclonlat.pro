pro eq2hor_veclonlat,ra,dec,jd,alt,az,lat=lat,lon=lon,_EXTRA=EXTRA

  ;AUTHOR: S. Leach
  ;PURPOSE: Provide a wrapper routine to astrolib eq2hor.pro
  ;         that allows for vectors in lon and lat, which is
  ;         not supported by eq2hor.pro

  nra  = n_elements(ra)
  nlon = n_elements(lon) 
  nlat = n_elements(lat)

  if(nlon ne nlat) then message,'Must have the same number of elements in lon as in lat'
  if(nlon ne nra)  then message,'Must have the same number of elements in lon as in ra'

  alt = make_array(nra,value=0d0)
  az  = make_array(nra,value=0d0)
  
  for aa=0L,nra-1L do begin
     eq2hor,ra[aa],dec[aa],jd[aa],alttemp,aztemp,lon=lon[aa],lat=lat[aa],_extra=extra
     alt[aa] = alttemp
     az[aa]  = aztemp
  endfor


end
