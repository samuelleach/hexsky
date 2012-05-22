pro test_planet_coords

;Program illustrates how to find planet coordinates with IDL astrolib.


;planet='JUPITER' & utc= 10.5
planet='SATURN'   & utc= 22.
  
lat =  34.472
lon = -104.246
  
JDCNV, 2009, 5, 15, utc, jd1
planet_coords, jd1, ra1, dec1, planet=planet,/jd
eq2hor, ra1, dec1, jd1, el1, az1, LAT=lat , LON=lon 
print,planet+' RA and dec =', ra1,dec1
print,planet+' az and el = ',az1,el1


JDCNV, 2009, 5, 15, utc+1., jd2
planet_coords, jd2, ra2, dec2, planet=planet,/jd
eq2hor, ra2, dec2, jd2, el2, az2, LAT=lat , LON=lon 
print,planet+' RA and dec =', ra2,dec2
print,planet+' az and el = ',az2,el2


print,(ra1-ra2)*60.,(dec1-dec2)*60.



hor2eq,el1+4.,az1,jd1,ra_start,dec_start,LAT=lat , LON=lon 
print,ra_start,dec_start



end
