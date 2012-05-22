pro detector__define

  ;AUTHOR: S. Leach
  ;PURPOSE: This is where the detector struct information gets defined.

  data = { DETECTOR, $
           index   : 0S,$
           wafer   : 0S,$
           row     : 0S,$
           col     : 0S,$
           az      : 0d0,$
           el      : 0d0,$
           channel : 0S,$
           power   : 0S,$
	   integration_time: 0d0$
  }  

end
