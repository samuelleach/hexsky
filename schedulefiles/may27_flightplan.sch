2009-05-01 06:00:00
 
# May 27 Flight plan

# Second column gives start time in decimal hours FT Sumner local time.

# Fan region + Archeops clouds become available at ~10.75
#
#Saturn:
#
# S: 0.00000
# E: 0.500000
# S: 15.1667
# E: 18.7000
# S: 20.8500
# E: 22.9000

#Jupiter:
#
# S: 2.96667
# E: 4.90000
# S: 9.11667
# E: 10.1167


cmb_scan         27 10.000   21.73   24.86  0.700   5.00   0.000  1     263 # Clean scan, anti-sun 10-10.30am.

#gap here

cmb_scan         27 10.700  22.300   60.00  0.700   6.00   0.000  1     509 # Gal plane drift scan 10-11.30 RA~-45 Dec~55
#cmb_scan         27 11.000  23.660   59.00  0.700   5.00   0.000  1     189 
#cmb_scan         27 11.500  23.660   59.00  0.700   5.00   0.000  1     189

cmb_scan         27 12.250   0.000   69.00  0.700   5.00   0.000  1     189 # Gal plane drift scan 11.30-13 RA ~ 0.65 Dec ~ 69
cmb_scan         27 12.750   0.000   69.00  0.700   5.00   0.000  1     189
cmb_scan         27 13.250   0.000   69.00  0.700   5.00   0.000  1     189

cmb_scan         27 13.750   10.44   66.5   0.700   5.00   0.000  1     189 # Gal plane drift scan 13-15 RA~156.6 Dec ~ 66.5
cmb_scan         27 14.250   10.44   66.5   0.700   5.00   0.000  1     189
cmb_scan         27 14.750   10.44   66.5   0.700   5.00   0.000  1     189
cmb_scan         27 15.250   10.44   66.5   0.700   5.00   0.000  1     93

calibrator_scan  27 15.5   11.063   8.860   1.000   7.000   6.000  39   9   #Saturn # start a bit later because of moon
# calibrator_scan  27 16.5   11.068   8.930   1.000   7.000   4.000  39   9   #Saturn
# calibrator_scan  27 17.5   11.070   8.984   1.000   7.000   2.000  39   9   #Saturn # start a bit earlie because of sun

# # 0.2hr gap here

# cmb_scan         27 18.700   13.75   8.600   0.700   5.00   0.000  1    185 # CMB Scan area 1: 1.5 hours
# cmb_scan         27 19.200   13.75   8.600   0.700   5.00   0.000  1    185
# cmb_scan         27 19.700   13.75   8.600   0.700   5.00   0.000  1    185

# cmb_scan         27 20.200   15.14   8.600   0.700   5.00   0.000  1    185 # CMB Scan area 2: 1.5 hours
# cmb_scan         27 20.700   15.14   8.600   0.700   5.00   0.000  1    185
# cmb_scan         27 21.200   15.14   8.600   0.700   5.00   0.000  1    185 

# calibrator_scan  27 21.700   11.198   8.855   1.000   7.000  -4.000  39   9 #Saturn

# # 1.4hr gap here

# cmb_scan         28 0.000   13.75   8.600   0.700   5.00   0.000  1     185 #CMB Scan area 1: 1.5 hours
# cmb_scan         28 0.500   13.75   8.600   0.700   5.00   0.000  1     185
# cmb_scan         28 1.000   13.75   8.600   0.700   5.00   0.000  1     185

# cmb_dipole       28 1.500   8.000  36.000  900    0.000   36.000           # Dipole scan
# cmb_dipole       28 1.750  -8.000  36.000  900    0.000   36.000           # Dipole scan


# cmb_scan         28 2.000   15.14   8.600   0.700   5.00   0.000  1     185 # CMB Scan area 2: 1.5 hours
# cmb_scan         28 2.500   15.14   8.600   0.700   5.00   0.000  1     185 
# cmb_scan         28 3.000   15.14   8.600   0.700   5.00   0.000  1     185 

# cmb_scan         28 3.500   18.85  0.98    0.700   10.00   3.000  25    7   # Galactic plane scanning ~ perpendicular (or could go for clean patch and pick up galaxy after dawn)
# cmb_scan         28 4.250   18.85  0.98    0.700   10.00   3.000  25    7 
# cmb_scan         28 5.000   18.85  0.98    0.700   10.00   3.000  25    7 
# cmb_scan         28 5.750   18.85  0.98    0.700   10.00   3.000  25    7 


