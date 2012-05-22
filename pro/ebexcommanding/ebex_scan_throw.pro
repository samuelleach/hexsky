function ebex_scan_throw,period_sec,azspeed_deg,azaccel_deg,starcamstop_sec

  ;AUTHOR: S. Leach
  ;PURPOSE: Return the scan throw given some parameters.
  ;         period_sec is the scan period in seconds.
  ;         azspeed_deg is the scan speed in degrees per second.
  ;         azaccel_deg is the acceleration at turnaround in
  ;                     degrees per second squared.
  ;         starcamstop_sec is the stop time at turnaround in seconds.

  ;         Math based on the same scan and stop pattern as in ebex_scan_period.pro

  throw_deg =   (period_sec/2. - starcamstop_sec - 2.*azspeed_deg/azaccel_deg) * azspeed_deg

  return, throw_deg


end
