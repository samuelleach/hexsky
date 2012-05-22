function get_lstschedulefile_firstline,day,month,year, $
                                       hour_utc=hour_utc, $
                                       jd_ref=jd_ref

  ;AUTHOR:  S. Leach
  ;PURPOSE: Returns the 'first line' of an EBEX schedule file.
  ;         The first line is a date and time given in UTC such
  ;         that the Greenwich Sidereal Time = 0.

  lng  = 0.d0
  lst  = 0.d0
  tz   = 0    ; Timezone
  
  hour_utc = lst2ct(lst,lng,tz,day,month,year)
  jdcnv,year,month,day,hour_utc,jd_ref

  jd_ref = jd_ref[0]
  
  hr       = floor(hour_utc)
  mnt_dec  = (hour_utc-hr)*60d0
  mnt      = floor(mnt_dec)
  sec_dec  = (mnt_dec-mnt)*60d0
  sec      = round(sec_dec)

  string = strtrim(year)+'-'+$
	  int2filestring(month,2)+'-'+$
	  int2filestring(day,2)+' '+$
	  int2filestring(hr[0],2)+':'+$
	  int2filestring(mnt[0],2)+':'+$
	  int2filestring(sec[0],2)

  return,strtrim(string,2)
  
end
