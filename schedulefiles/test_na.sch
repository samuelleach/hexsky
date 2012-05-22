#NEED TO UPDATE FOR NEW SYNTAX
2009-05-15 06:00:00  #UTC for Ft Sumner local time midnight

#test na schedule file
#May-15-2009, Ft Sumner, consider daylight saving time
#Launch_pad     1 6.0000 #before launch,6am local time
#Ascend         1 7.5000 #Launch at 7:30am local time,2.5 hrs duration
#Antisun        1 10.000 #float at 10am local time,then go antisun
#ra_dec_goto    18.6157 38.7844 #Vega(el just above 20) to check pointing
#ra_dec_goto    20.6905 45.2803 #Deneb if Vega is not good enough
#tuning electronics (the step that could take from 30mins to several hrs?)

#after this line we can start observing? possible interesting target needed

#CMB            1 10.500 22.6365 33.6469 #Davies field no.5,avail ~1.5hr
CMB            1 10.500 23. 60.0000 12.0000 0.70000 9 6. 34 
#Above is a high dust region along the galactic plane,avail~2hrs

CMB            1 12.000 8.47853 86.5591 15.0000 0.70000 9 6. 37 #Davies field 6,avail ~2 hrs

CMB            1 14.000 10.0000 50.0000 11.0000 0.70000 9 6. 47 #low dust region
#suggestions on possible targets? RA~9hr,DEC~50


calibrator      1 16.000 11.1219 8.00178 5.0 1.0 3 1.3 250 #Saturn Scan
calibrator      1 17.112 11.1219 8.00178 5.0 1.0 3 1.3 250 #Saturn Scan
calibrator      1 18.224 11.1219 8.00178 5.0 1.0 3 1.3 250 #Saturn Scan

#saturn is available for 3.5hrs till 7:30pm local time


#CMB             1 19.5000 12.6971 -1.44944 18.0000 0.7000 9 6. 47 #Gamma Virgo
CMB             1 19.3356 12.6971 -1.44944 15.0000 0.7000 9 6. 40 #Gamma Virgo
#depend on whether we want to maximumly use saturn above could go 2hrs or longer


calibrator      1 21.500 14.8453 8.00142 5.0 1.0 3 1.3 250 #Saturn Scan
calibrator      1 22.612 14.8453 8.00142 5.0 1.0 3 1.3 250 #Saturn Scan
calibrator      1 23.724 14.8453 8.00142 5.0 1.0 3 1.3 250 #Saturn Scan

#saturn for another 3.5hrs

CMB             2 0.836 18.3333  74.1617  18.0000 0.7000 9 1.0 47 #MAXIPOL-n
CMB             2 3.780 18.3333  74.1617  18.0000 0.7000 9 1.0 30 #MAXIPOL-n
#this could last for 4.75hrs

CMB             2 5.660 275.0000  15.0000  18.0000 0.7000 9 1.0 40 #high dust
#target in that region, but this patch will be available for ~2hrs
#termination    2 7.5000

