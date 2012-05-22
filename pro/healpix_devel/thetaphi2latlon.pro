pro thetaphi2latlon,theta,phi,lat,lon

  ;AUTHOR: S. Leach
  ;PURPOSE: Convert between healpix theta,phi (in radians) convention to
  ;         astronomical lat, lon (in degrees)

  
  lon = phi/!dtor
  lat = (!pi/2.-theta)/!dtor
  

end
