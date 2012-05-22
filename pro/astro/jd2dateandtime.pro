FUNCTION jd2dateandtime,jd

  ;AUTHOR: S. Leach
  ;PURPOSE: Converts JD to a UTC date and time string

  daycnv,jd,year,month,day,hour

  string = strtrim(day,2)+' '+themonths(month,/abbrev)+$
	  ' '+strtrim(year,2)+' '+decimalhour2clocktime(hour)+' UTC'

  return,string

  

end
