2009-05-01 06:00:00
 
# Written on Fri May 15 17:20:13 2009 by acs-user@ebex-monitor.
 
# Schedule starts on 21 May 2009 21:30:36 UTC and ends on 22 May 2009 06:25:30 UTC
 

# Start obs at L+3 (10am)



cmb_scan         21 10.000  -3.000   55.00  0.700   10.00   0.000  1     107 # Gal plane drift scan 10-11.30 RA~-45 Dec~55
cmb_scan         21 10.500  -3.000   55.00  0.700   10.00   0.000  1     107 #Troublesome for fixupaz
cmb_scan         21 11.000  -3.000   55.00  0.700   10.00   0.000  1     107

cmb_scan         21 11.500   0.000   69.00  0.700   10.00   0.000  1     107 # Gal plane drift scan 11.30-13 RA ~ 0.65 Dec ~ 69
cmb_scan         21 12.000   0.000   69.00  0.700   10.00   0.000  1     107
cmb_scan         21 12.500   0.000   69.00  0.700   10.00   0.000  1     107

cmb_scan         21 13.000   10.44   66.5   0.700   10.00   0.000  1     107 # Gal plane drift scan 13-15 RA~156.6 Dec ~ 66.5
cmb_scan         21 13.500   10.44   66.5   0.700   10.00   0.000  1     107
cmb_scan         21 14.000   10.44   66.5   0.700   10.00   0.000  1     107
cmb_scan         21 14.500   10.44   66.5   0.700   10.00   0.000  1     107

cmb_scan         21 15.000   10.00   39.3   0.700   10.00   0.000  1     107 # Clean scan 15-15.30 RA~150 Dec~39.3 


calibrator_scan  21 15.510   11.063   8.894   1.000   7.000   5.000  39   9 #Saturn
calibrator_scan  21 16.510   11.065   8.923   1.000   7.000   4.000  39   9 #Saturn
calibrator_scan  21 17.510   11.070   8.997   1.000   7.000   3.000  39   9 #Saturn


cmb_scan         21 18.510   13.51   16.53   0.700   10.00   0.000  1     105 # Something between 18.510 to 21.425
cmb_scan         21 19.000   13.51   16.53   0.700   10.00   0.000  1     107
cmb_scan         21 19.500   13.51   16.53   0.700   10.00   0.000  1     107

cmb_scan         21 20.000   14.90   16.53   0.700   10.00   0.000  1     107 
cmb_scan         21 20.500   14.90   16.53   0.700   10.00   0.000  1     107
cmb_scan         21 21.000   14.90   16.53   0.700   10.00   0.000  1     91 # Night starting here


calibrator_scan  21 21.425   11.181   9.087   1.000   7.000  -3.000  39   9 #Saturn
calibrator_scan  21 22.425   11.199   8.829   1.000   7.000  -4.000  39   9 #Saturn
calibrator_scan  21 23.425   11.207   8.663   1.000   7.000  -5.000  39   9 #Saturn

cmb_scan         22 0.425   17.72   71.87   0.700   10.00   4.000  20     11 # CMB raster scan for three hours
cmb_scan         22 1.425   17.72   71.87   0.700   10.00   4.000  20     11 
cmb_scan         22 2.425   17.72   71.87   0.700   10.00   4.000  9      11 # Finish by 3am (moon constraint) #Troublesome for fixupaz_new


#cmb_scan         22 2.940   18.77  -2.86    0.700   12.00   5.000  23    11 # Galactic plane scanning ~ perpendicular (or could go for clean patch and pick up galaxy after dawn)