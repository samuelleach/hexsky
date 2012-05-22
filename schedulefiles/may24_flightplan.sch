2009-05-01 06:00:00
 
# May 24 Flight plan

# Start obs at L+3 (10am)

cmb_scan         24 10.000  -3.000   55.00  0.700   10.00   0.000  1     107 # Gal plane drift scan 10-11.30 RA~-45 Dec~55
cmb_scan         24 10.500  -3.000   55.00  0.700   10.00   0.000  1     107 # Troublesome for fixupaz
cmb_scan         24 11.000  -3.000   55.00  0.700   10.00   0.000  1     107

cmb_scan         24 11.500   0.000   69.00  0.700   10.00   0.000  1     107 # Gal plane drift scan 11.30-13 RA ~ 0.65 Dec ~ 69
cmb_scan         24 12.000   0.000   69.00  0.700   10.00   0.000  1     107
cmb_scan         24 12.500   0.000   69.00  0.700   10.00   0.000  1     107

cmb_scan         24 13.000   10.44   66.5   0.700   10.00   0.000  1     107 # Gal plane drift scan 13-15 RA~156.6 Dec ~ 66.5
cmb_scan         24 13.500   10.44   66.5   0.700   10.00   0.000  1     107
cmb_scan         24 14.000   10.44   66.5   0.700   10.00   0.000  1     107
cmb_scan         24 14.500   10.44   66.5   0.700   10.00   0.000  1     107

cmb_scan         24 15.000   10.00   39.3   0.700   10.00   0.000  1     81 # Clean scan 15-15.30 RA~150 Dec~39.3 


calibrator_scan  24 15.377   11.063   8.893   1.000   7.000   5.000  39   9 #Saturn
calibrator_scan  24 16.377   11.065   8.917   1.000   7.000   4.000  39   9 #Saturn
calibrator_scan  24 17.377   11.070   8.984   1.000   7.000   3.000  39   9 #Saturn

cmb_scan         24 18.510   13.51   16.53   0.700   10.00   0.000  1     105 # CMB Scan area 1: 1.5 hours
cmb_scan         24 19.000   13.51   16.53   0.700   10.00   0.000  1     107
cmb_scan         24 19.500   13.51   16.53   0.700   10.00   0.000  1     107

cmb_scan         24 20.000   14.90   16.53   0.700   10.00   0.000  1     107 # CMB Scan area 2: 1.5 hours
cmb_scan         24 20.500   14.90   16.53   0.700   10.00   0.000  1     107
cmb_scan         24 21.000   14.90   16.53   0.700   10.00   0.000  1     107 

calibrator_scan  24 21.500   11.198   8.855   1.000   7.000  -4.000  39   9 #Saturn
calibrator_scan  24 22.500   11.206   8.678   1.000   7.000  -5.000  39   9 #Saturn

cmb_dipole       24 23.500   15.000  36.000  900    0.000   36.000          # Dipole scan
cmb_dipole       24 23.750   15.000  50.000  900    0.000   36.000          # Dipole scan

cmb_scan         25 0.425   13.51   16.53   0.700   10.00   0.000  1     107 # CMB Scan area 1: 2.0 hours
cmb_scan         25 0.925   13.51   16.53   0.700   10.00   0.000  1     107
cmb_scan         25 1.425   13.51   16.53   0.700   10.00   0.000  1     107
cmb_scan         25 1.925   13.51   16.53   0.700   10.00   0.000  1     107 

cmb_scan         25 2.425   14.90   16.53   0.700   10.00   0.000  1     107 # CMB Scan area 2: 1.5 hours
cmb_scan         25 2.925   14.90   16.53   0.700   10.00   0.000  1     107 
cmb_scan         25 3.425   14.90   16.53   0.700   10.00   0.000  1     107 


cmb_scan         25 4.000   18.85  0.98    0.700   20.00   4.000  14    7 # Galactic plane scanning ~ perpendicular (or could go for clean patch and pick up galaxy after dawn)
cmb_scan         25 4.750   18.85  0.98    0.700   20.00   4.000  14    7 
cmb_scan         25 5.500   18.85  0.98    0.700   20.00   4.000  14    7 
cmb_scan         25 6.250   18.85  0.98    0.700   20.00   4.000  20    5 


#cmb_scan         24 4.000   18.85  0.98    0.700   15.00   4.000  13    9 # Galactic plane scanning ~ perpendicular (or could go for clean patch and pick up galaxy after dawn)
#cmb_scan         24 4.750   18.85  0.98    0.700   15.00   4.000  13    9 
#cmb_scan         24 5.500   18.85  0.98    0.700   15.00   4.000  13    9 
#cmb_scan         24 6.250   18.85  0.98    0.700   15.00   4.000  13    9 

