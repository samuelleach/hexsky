pro schedule__define

  ;AUTHOR: S. Leach
  ;PURPOSE: This is where the schedule struct information gets defined.

  schedule = { SCHEDULE,$
	      command : make_array(2028,value={command}),$
	      ncommands : 0S,$
	      ;Reference time for the schedule file
              year : 0S,$
	      month : 0S,$
	      day : 0S,$
	      hour_utc: 0E,$
	      ;Add geographical information ?
              filename:''$
	   }
  
end
