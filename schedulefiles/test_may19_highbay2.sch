2009-05-01 06:00:00
 
# Written on Tue May 19 23:20:14 2009 by acs-user@ebex-monitor.
 
# This schedule file is schedulefiles/test_may19_highbay.sch with start time and RA shifted by 2.00 hrs.
 
 
calibrator_scan 20  0.030   19.330  24.860   1.000   6.000   6.000  12  11 # 0.32 hr scan with 11 starcam photos
calibrator_scan 20  0.350   19.330  24.860   1.000   6.000   6.000  12  11 # Can comment out to test repeat scanning
cmb_scan        20  0.680   19.650  24.860   0.700  12.000   0.000   1  61 # 0.33 hr drift scan
cmb_scan        20  1.010   19.650  24.860   0.700  12.000   0.000   1  61 # Can comment out to test repeat scanning
cmb_scan        20  1.340   20.620  24.860   0.700  10.000   3.000   8   9 # 0.33 hr scan, asking for 3 degree dec range
cmb_scan        20  1.660   20.930  24.860   0.700  10.000   4.000   8   9 # 0.33 hr scan, asking for 4 degree dec range
cmb_scan        20  1.980   21.260  24.860   0.700  12.000   5.000   6  11 # 0.33 hr scan. Repeat CMB scanning 3 x twenty minutes
cmb_scan        20  2.310   21.260  24.860   0.700  12.000   5.000   6  11 # 0.33 hr scan
cmb_scan        20  2.640   21.260  24.860   0.700  12.000   5.000   6  11 # 0.33 hr scan (within a few degrees of the Galactic plane)
calibrator_scan 20  2.970   22.230  24.860   1.000   6.000  10.000  12  11 # 0.32 hr scan (within a few degrees of the Galactic plane)
calibrator_scan 20  3.290   22.230  24.860   1.000   6.000  10.000  12  11 # 0.32 hr scan
cmb_scan        20  3.610   22.880  24.860   0.700  12.000   6.000   6  11 # 0.33 hr scan , asking for 6 degree dec range
