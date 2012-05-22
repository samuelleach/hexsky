2009-05-01 06:00:00
 
# May 29 Flight plan

# Second column gives start time in decimal hours FT Sumner local time.

# Moon goes below -10 degrees elevation at ~1.75 on the 30th

#
#Saturn:
#45 degree az separation
# S: 17.4500
# E: 18.5667

#30 degree az separation
# S: 0.00000
# E: 0.366667
# S: 16.7333
# E: 18.5667
# S: 20.8833
# E: 21.4500

#20 degree separation
# S: 0.00000
# E: 0.366667
# S: 16.0000
# E: 18.5667
# S: 20.8833
# E: 23.2333

#15 degree az separation
# S: 0.00000
# E: 0.366667
# S: 15.3333
# E: 18.5667
# S: 20.8833

# Jupiter
# S: 2.78333
# E: 4.88333
# S: 8.58333
# E: 9.93333



cmb_scan         29 10.000  22.34   28.70  0.700   5.00   0.000  1 151  # Clean scan, anti-sun 
cmb_scan         29 10.500  22.34   28.70  0.700   5.00   0.000  1 151 

cmb_scan         29 11.000  22.300   60.00  0.700  5.00   0.000  1 455 # Archeops polarized cloud region near Cas A.

cmb_scan         29 12.500  8.000   77.20  0.700   5.00   0.000  1 151 
cmb_scan         29 13.000  8.000   77.20  0.700   5.00   0.000  1 151
cmb_scan         29 13.500  8.000   77.20  0.700   5.00   0.000  1 151

cmb_scan         29 14.000  10.75   59.00   0.700   5.00   0.000  1 151 # CMB region 1 : 1.5 hours
cmb_scan         29 14.500  10.75   59.00   0.700   5.00   0.000  1 151
cmb_scan         29 15.000  10.75   59.00   0.700   5.00   0.000  1 151

calibrator_scan  29 15.5  11.063   8.860   1.000   7.000   6.000  30  9 #Saturn # start a bit later because of moon
calibrator_scan  29 16.5  11.068   8.930   1.000   7.000   4.000  30  9   
calibrator_scan  29 17.5  11.070   8.984   1.000   7.000   2.000  30  9 #** Saturn # end a bit earlier because of sun

cmb_scan         29 18.500  13.55   8.600   0.700   5.00   0.000  1 151 # CMB Scan area 2: 1.5 hours
cmb_scan         29 19.000  13.55   8.600   0.700   5.00   0.000  1 151
cmb_scan         29 19.500  13.55   8.600   0.700   5.00   0.000  1 151

cmb_scan         29 20.000  14.94   8.600   0.700   5.00   0.000  1 151 # CMB Scan area 3: 2.0 hours
cmb_scan         29 20.500  14.94   8.600   0.700   5.00   0.000  1 151
cmb_scan         29 21.000  14.94   8.600   0.700   5.00   0.000  1 151 
cmb_scan         29 21.500  14.94   8.600   0.700   5.00   0.000  1 151 

cmb_scan         29 22.000  10.75   59.00   0.700   5.00   0.000  1 151 # CMB region 1 : 1.5 hours
cmb_scan         29 22.500  10.75   59.00   0.700   5.00   0.000  1 151
cmb_scan         29 23.000  10.75   59.00   0.700   5.00   0.000  1 151
cmb_scan         29 23.500  10.75   59.00   0.700   5.00   0.000  1 151 # Getting closer to moon.

cmb_scan         30 0.000   13.55   8.600   0.700   5.00   0.000  1 151 #CMB Scan area 2: 1.5 hours
cmb_scan         30 0.500   13.55   8.600   0.700   5.00   0.000  1 151
cmb_scan         30 1.000   13.55   8.600   0.700   5.00   0.000  1 151

cmb_dipole       30 1.500   10.000  36.000  900    0.000   36.000       # Dipole scan
cmb_dipole       30 1.750  -10.000  36.000  900    0.000   36.000       # Dipole scan


cmb_scan         30 2.000   14.94   8.600   0.700   5.00   0.000  1 151 # CMB Scan area 3: 1.5 hours
cmb_scan         30 2.500   14.94   8.600   0.700   5.00   0.000  1 151 
cmb_scan         30 3.000   14.94   8.600   0.700   5.00   0.000  1 151 

cmb_scan         30 3.500   18.85  0.98    0.700   10.00   3.000  22  7 # Galactic plane scanning ~ perpendicular (or could go for clean patch and pick up galaxy after dawn)
cmb_scan         30 4.250   18.85  0.98    0.700   10.00   3.000  22  7 
cmb_scan         30 5.000   18.85  0.98    0.700   10.00   3.000  22  7 
cmb_scan         30 5.750   18.85  0.98    0.700   10.00   3.000  22  7 


