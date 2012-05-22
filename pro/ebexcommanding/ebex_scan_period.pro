function ebex_scan_period,azthrow_deg,azspeed_deg,azaccel_deg,starcamstop_sec

  ;AUTHOR: S. Leach
  ;PURPOSE: Return the scan period given some parameters
  ;         azthrow_deg is the throw in degrees.
  ;         azspeed_deg is the scan speed in degrees per second.
  ;         azaccel_deg is the acceleration at turnaround in
  ;                     degrees per second squared.
  ;         starcamstop_sec is the stop time at turnaround in seconds.

  period =  2.*(azthrow_deg/azspeed_deg + 2.*azspeed_deg/azaccel_deg + $
                starcamstop_sec)

;  print,2.*azthrow_deg/azspeed_deg, + 4.*azspeed_deg/azaccel_deg , 2*starcamstop_sec

  return,period


end
