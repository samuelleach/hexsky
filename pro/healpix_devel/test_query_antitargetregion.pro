pro test_query_antitargetregion

;  jd0 = systime(/julian)

  year = 2009 & month = 6 & day = 15 & hr = 16.
  jdcnv,year,month,day,hr,jd0

  lon = -133.
  lat = 33.
  target = ['moon','sun']
  tolerance = [45.,135.]
  minel = 30.
  maxel = 60.
  targetsetel = -10.
  nside = 64


  map   = make_array(nside2npix(nside),value=0.)
  
  nstep = 400
  jd    = jd0 + findgen(nstep)/float(nstep-1) 

  
  ;Loop over time steps
  for hh = 0, n_elements(jd) -1 do begin
     ;Loop over targets
     for tt = 0,n_elements(target)-1 do begin
        query_antitargetregion, jd[hh], lon, lat, target[tt], tolerance[tt],$
                                minel,maxel,targetsetel, nside, temp_listpix
        if tt eq 0 then begin
           listpix = temp_listpix
        endif else begin
           listpix = SetUnion(listpix,temp_listpix)
        endelse           
     endfor

     for pp = 0L , n_elements(listpix)-1 do begin
        map[listpix[pp]] = map[listpix[pp]] + 1.
     endfor
  endfor


  map = map/n_elements(target)/nstep*24.
  mollview,map,/online,ps='test.ps',units='hours'
  write_fits_map,'visibility.fits',map,ordering='ring'


end
