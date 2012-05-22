2009-05-01 06:00:00
 
# May 22 Flight simulations - begins at 12.00 - scans for 4 hours
#
# CMB drift scan and repeat
#
# Calibrator scan up (artificial planet)
# Calibrator scan down (artificial planet)
#
# CMB raster scan and repeat
#
# Calibrator scan up (artificial planet)
# Calibrator scan down (artificial planet)
#
# Long CMB raster scan - check dec range (half an hour)
#
# Calibrator - Saturn


cmb_scan        22 12.00 0.400 72.22 0.700  5.00   0.000  1 123 # Drift scan with 0.7deg/s scanning.
cmb_scan        22 12.33 0.400 72.22 0.350  5.00   0.000  1 77  # Drift scan with 0.35deg/s scanning.

calibrator_scan 22 12.66 7.07 27.23  1.000  7.000  5.000  13 9  # Calibrator scan towards artificial planet
calibrator_scan 22 13.00 7.51 26.73  1.000  7.000  5.000  13 9

cmb_scan        22 13.33 5.68 71.82  0.700  5.00   4.000  14 9  # CMB scan with 4 degree target Dec range
cmb_scan        22 13.66 5.68 71.82  0.700  5.00   4.000  14 9

calibrator_scan 22 14.00 8.50 27.30 1.000  7.000   -5.000  13 9 # Calibrator scan towards artificial planet
calibrator_scan 22 14.33 8.73 28.56 1.000  7.000   -5.000  8  9

cmb_dipole      22 14.55    5. 36. 180. 0. 36.                  # Dipole scans
cmb_dipole      22 14.60   -8. 36. 180. 0. 36.


cmb_scan        22 14.66 7.19 -6.19  0.700  5.00   4.000  28  7 # CMB scans (half an hour)
cmb_scan        22 15.16 7.19 -6.19  0.700  5.00   3.000  28  7

calibrator_scan 22 15.66 11.14 7.99  1.000  7.000   3.000  19 9 # Calibrator scan
calibrator_scan 22 16.16 11.14 7.99  1.000  7.000   3.000  19 9

