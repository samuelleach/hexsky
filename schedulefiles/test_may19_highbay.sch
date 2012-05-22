2009-05-01 06:00:00

# Test scanning on Tue May 19th from inside the highbay.

# Carte du jour


calibrator_scan      19 22.03  17.33  24.86 1.0 6.0 6.0 12 11   # 0.32 hr scan with 11 starcam photos
calibrator_scan      19 22.35  17.33  24.86 1.0 6.0 6.0 12 11   # Can comment out to test repeat scanning

cmb_scan             19 22.68  17.65  24.86 0.7 12.0 0.0 1 61   # 0.33 hr drift scan
cmb_scan             19 23.01  17.65  24.86 0.7 12.0 0.0 1 61   # Can comment out to test repeat scanning

cmb_scan             19 23.34  18.62  24.86 0.7 10.0 3.0 8  9   # 0.33 hr scan, asking for 3 degree dec range
cmb_scan             19 23.66  18.93  24.86 0.7 10.0 4.0 8  9   # 0.33 hr scan, asking for 4 degree dec range

cmb_scan             19 23.98  19.26  24.86 0.7 12.0 5.0 6 11   # 0.33 hr scan. Repeat CMB scanning 3 x twenty minutes
cmb_scan             20 00.31  19.26  24.86 0.7 12.0 5.0 6 11   # 0.33 hr scan
cmb_scan             20 00.64  19.26  24.86 0.7 12.0 5.0 6 11   # 0.33 hr scan (within a few degrees of the Galactic plane)

calibrator_scan      20 00.97  20.23  24.86 1.0 6.0 10.0 12 11  # 0.32 hr scan (within a few degrees of the Galactic plane)
calibrator_scan      20 01.29  20.23  24.86 1.0 6.0 10.0 12 11  # 0.32 hr scan

cmb_scan             20 01.61  20.88  24.86 0.7 12.0 6.0 6 11   # 0.33 hr scan , asking for 6 degree dec range

