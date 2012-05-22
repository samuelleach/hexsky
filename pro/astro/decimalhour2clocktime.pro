FUNCTION decimalhour2clocktime,decimal_hour

  ;AUTHOR: S. Leach
  ;PURPOSE: Takes a decimal hour and formats it into a
  ;         clock time string.

  hr       = floor(decimal_hour)
  mnt_dec  = (decimal_hour-hr)*60.
  mnt      = floor(mnt_dec)
  sec_dec  = (mnt_dec-mnt)*60
  sec      = round(sec_dec)
  
  string = int2filestring(hr[0],2)+':'+$
	  int2filestring(mnt[0],2)+':'+$
	  int2filestring(sec[0],2)

  return,string

  
end