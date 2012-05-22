PRO healp_coord,nside,lon,lat,ordering=ordering

Npix=12.*(1.*nside)^2
ipix=lindgen(Npix)
pix2ang, nside,ipix, theta, phi,ordering=ordering
lat=(!pi/2.-theta)*!radeg
lon=phi*!radeg

END