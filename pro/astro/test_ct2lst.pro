pro test_ct2lst

  day   = 15
  month = 5
  year  = 2009
  time  = 0
  
  lng=-104.-14./60.
  tz= -7.
  ct2lst,lst,lng,tz,time,day,month,year
  print,'time = ',time
  print,'lst = ',lst
  print,'est time = ',lst2ct(lst,lng,tz,day,month,year)


  
end
