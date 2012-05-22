#NEED TO UPDATE FOR NEW SYNTAX
2009-05-15 06:00:00

# This is a test schedule file for May 15th.
#
# Notes:
#  Moon goes below -5 degrees elevation at 11.40am local time.
#
#  Polaris moves into anti-sun regions at midday and is
#  available until about 13.45 local tune.
#
#  Sun goes below -5 degrees elevation at 20.20 local time.
#
#  Moon rises again at 00.45am.
#
#  Galactic plane become available.. depending on the anti-moon constraint.

calibrator_scan      1  12.00 2.530 89.26 7.0 1.0 11 1.0 18     # Polaris scans.
calibrator_scan      1  12.50 2.530 89.26 7.0 1.0 11 1.0 18     
calibrator_scan      1  13.00 2.530 89.26 7.0 1.0 11 1.0 18     
cmb_scan             1 13.50 9.000 45.0 12.0000 0.7000 93 0.0 1 # Scanning a clean 
cmb_scan             1 14.00 9.000 45.0 12.0000 0.7000 93 0.0 1 # region until Saturn 
cmb_scan             1 14.50 9.000 45.0 12.0000 0.7000 93 0.0 1 # becomes available. 
cmb_scan             1 15.00 9.000 45.0 12.0000 0.7000 93 0.0 1
cmb_scan             1 15.50 9.000 45.0 12.0000 0.7000 93 0.0 1
calibrator_scan      1 16.000 11.039 8.44 7.0 1.0 5 5.0 100     # Saturn scans
calibrator_scan      1 17.112 11.041 8.50 7.0 1.0 5 4.0 100
calibrator_scan      1 18.224 11.046 8.65 7.0 1.0 5 3.0 100
cmb_scan             1 19.336 12.000 0.0 12.0000 0.700 93 0.0 1 # Scanning a clean 
cmb_scan             1 19.836 12.000 0.0 12.0000 0.700 93 0.0 1 # region until sun set. 
cmb_scan             1 20.336 12.000 0.0 12.0000 0.700 93 0.0 1
cmb_dipole           1 21.000 15.000 36.000 1800.00 0.000 30.00 # Half hour dipole scans.
cmb_dipole           1 21.500 15.000 50.000 1800.00 0.000 30.00  
calibrator_scan      1 22.000 11.135 9.29 7.0 1.0 5 -3.0 100    # Saturn scans.
calibrator_scan      1 23.112 11.162 9.15 7.0 1.0 5 -4.0 100     
calibrator_scan      2 00.224 11.174 9.04 7.0 1.0 5 -5.0 100     
cmb_scan             2 1.336 2.530 89.26 12.0000 0.700 5 4.0 46 # Polaris scans.
cmb_scan             2 2.336 2.530 89.26 12.0000 0.700 5 4.0 46 
cmb_scan             2 3.336 2.530 89.26 12.0000 0.700 5 4.0 46
cmb_scan             2 4.336 2.530 89.26 12.0000 0.700 5 4.0 46
cmb_scan             2 5.336 2.530 89.26 12.0000 0.700 5 4.0 46




