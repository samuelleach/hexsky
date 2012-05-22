function stellarium_command,jd,lon_deg,lat_deg

  ;AUTHOR: S. Leach
  ;PURPOSE: Make a stellarium commmand line command given some inputs.

  njd     = n_elements(jd)

  command = make_array(njd,value='')

  
  for cc=0,njd-1 do begin
     daycnv,jd[cc],year,month,day,hour

     skydate_string   = strtrim(year,2)+strtrim(month,2)+strtrim(day,2)
     skytime_string   = decimalhour2clocktime(hour)

     deg2dms,lon_deg,londeg,lonmin,lonsec
     deg2dms,lat_deg,latdeg,latmin,latsec
     
     latsign_string='+' & if lat_deg lt 0. then latsign_string='' 
     lonsign_string='+' & if lon_deg lt 0. then lonsign_string='' 
     
     longitude_string = lonsign_string+strtrim(londeg,2)+'d'+strtrim(lonmin,2)+"\'"+number_formatter(lonsec,dec=2)+'\"'
     latitude_string  = latsign_string+strtrim(latdeg,2)+'d'+strtrim(latmin,2)+"\'"+number_formatter(latsec,dec=2)+'\"'
     
     command = 'stellarium --landscape ocean --longitude '+longitude_string+' --latitude '+latitude_string+$
               ' --sky-date '+skydate_string+' --sky-time '+skytime_string
     
  endfor

     return, command


end
