2009-05-01 06:00:00

# Test scanning on Tue May 20th from inside the highbay.


calibrator_scan      20 21.00  15.9  23.9 1.0 7.0 6.0 9 9    # scan with 9 starcam photos
calibrator_scan      20 21.25  15.9  23.9 1.0 7.0 6.0 9 9    # Can comment out to test repeat scanning

cmb_scan             20 21.50  16.4  23.9 0.7 10.0 2.0 6 9   # asking for 2 degree dec range
cmb_scan             20 21.75  16.4  23.9 0.7 10.0 3.0 6 9   # asking for 3 degree dec range

cmb_scan             20 22.00  16.9  23.9 0.7 12.0 0.0 1 45  # 0.25 hr drift scan
cmb_scan             20 22.25  16.9  23.9 0.7 12.0 0.0 1 45  # Can comment out to test repeat scanning

calibrator_scan      20 22.50  17.4  23.9 1.0 7.0 -6.0 9 9   # Negative elevation step
calibrator_scan      20 22.75  17.4  23.9 1.0 7.0 -6.0 9 9   # 

cmb_scan             20 23.00  17.9 23.9 0.7 12.0 5.0 5 9    # Repeat CMB scanning 3 x 15 minutes
cmb_scan             20 23.25  17.9 23.9 0.7 12.0 5.0 5 9    # 
cmb_scan             20 23.50  17.9 23.9 0.7 12.0 5.0 5 9    # 


cmb_scan             20 23.75  18.65  23.9 0.7 12.0 6.0 6 9  # asking for 6 degree dec range

