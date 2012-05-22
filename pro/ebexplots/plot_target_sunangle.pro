pro plot_target_sunangle,target_coords,jd0,djd,lon,lat,psfile=psfile,title=title,$
                        minel=minel,maxel=maxel

  ;AUTHOR: S. Leach
  ;PURPOSE: Plot the azimuth angle between a target and the sun for
  ;         various latitudes.

  
  if n_elements(psfile) eq 0 then psfile = 'target_sunangle.ps'
  if n_elements(title) eq 0 then title = ' '

  nlat   = n_elements(lat)
  nlon   = n_elements(lon)
  if n_elements(lon) eq 1 then lon = make_array(nlat,value=lon)

  npoint =  1025
  az     =  make_array(npoint,nlat,value=0.)
  el     =  make_array(npoint,nlat,value=0.)
  jd     =  jd0 + dindgen(npoint)/double(npoint -1)*djd
  ra     =  make_array(npoint,value = target_coords[0])
  dec    =  make_array(npoint,value = target_coords[1])
  sunaz  =  make_array(npoint,nlat,value = 0.)
  sunel  =  make_array(npoint,nlat,value = 0.)
  moonaz =  make_array(npoint,nlat,value = 0.)
  moonel =  make_array(npoint,nlat,value = 0.)
  
  rjd    = jd - !constant.rjd0


  for ll = 0,nlat-1L do begin
     eq2hor, ra, dec,  jd, el_tmp,  az_tmp, lon=lon[ll],lat=lat[ll],refract=0,alt=40000.
     az[*,ll] = az_tmp
     el[*,ll] = el_tmp

     sunpos, jd , sunra , sundec
     eq2hor, sunra, sundec,  jd, el_tmp,  az_tmp, lon=lon[ll],lat=lat[ll],refract=0,alt=40000.
     sunaz[*,ll] = az_tmp
     sunel[*,ll] = el_tmp

     moonpos, jd , moonra , moondec
     eq2hor, moonra, moondec,  jd, el_tmp,  az_tmp, lon=lon[ll],lat=lat[ll],refract=0,alt=40000.
     moonaz[*,ll] = az_tmp
     moonel[*,ll] = el_tmp
  endfor

  ps_start,file=psfile

  mycol = fsc_color(['red','blue','green','brown','pink','black'])

  title= 'Start: '+jd2dateandtime(jd[0])+', (RA, Dec) = ('+number_formatter(target_coords[0],dec=1)+$
         ', '+number_formatter(target_coords[1],dec=1)+')'

  ; Plot distance between target Az and Anti-Sun Az
  plot,rjd,modpos(az[*,0]-(sunaz[*,0]+180.),wrap=180.,/zero_cent),$
       ytitle='Target Az - (Sun Az + 180) [deg]',xtitle='RJD [day]',ystyle=1,xstyle=1,$
       title=title,/nodata,yrange=[-90,90]  
  for ll = 0,nlat - 1L do begin
     oplot,rjd,modpos(az[*,ll]-(sunaz[*,ll]+180.),wrap=180.,/zero_cent),color=mycol[ll],thick=4
  endfor
  al_legend,number_formatter(lat,dec=1),box=0,/bottom,/right,color=mycol[0:nlat-1],thick=4,line=6

  ; Plot distance between target Az and Anti-Moon Az
  plot,rjd,modpos(az[*,0]-(moonaz[*,0]+180.),wrap=180.,/zero_cent),$
       ytitle='Target Az - (Moon Az + 180) [deg]',xtitle='RJD [day]',ystyle=1,xstyle=1,$
       title=title,/nodata,yrange=[-180,180]  
  for ll = 0,nlat - 1L do begin
     plot_piecewise,rjd,modpos(az[*,ll]-(moonaz[*,ll]+180.),wrap=180.,/zero_cent),color=mycol[ll],thick=8,ytol=340
     angle = modpos(az[*,ll]-(moonaz[*,ll]+180.),wrap=180.,/zero_cent)
     index = where(moonel[*,ll] gt -5. and abs(angle) gt 135)
     if n_elements(index) gt 1 then begin
        oplot,rjd[index],modpos(az[index,ll]-(moonaz[index,ll]+180.),wrap=180.,/zero_cent),$
              color=fsc_color('black'),psym=3
     endif
  endfor
  al_legend,number_formatter(lat,dec=1),box=0,/bottom,/right,color=mycol[0:nlat-1],thick=4,line=6


  ; Plot Moon El
  plot,rjd,moonel[*,0],$
       ytitle='Moon El [deg]',xtitle='RJD [day]',ystyle=1,xstyle=1,$
       title=title,/nodata,yrange=[-45,45]  
  for ll = 0,nlat - 1L do begin
     oplot,rjd,moonel[*,ll],color=mycol[ll],thick=4
  endfor
  al_legend,number_formatter(lat,dec=1),box=0,/bottom,/right,color=mycol[0:nlat-1],thick=4,line=6


  ; Plot target El
  plot,rjd,el[*,0],$
       ytitle='Target El [deg]',xtitle='RJD [day]',ystyle=1,xstyle=1,$
       title=title,/nodata,yrange=[0,70]  
  for ll = 0,nlat - 1L do begin
     oplot,rjd,el[*,ll],color=mycol[ll],thick=4
  endfor
  al_legend,number_formatter(lat,dec=1),box=0,/bottom,/right,color=mycol[0:nlat-1],thick=4,line=6




  if n_elements(minel) gt 0 then oplot,jd,make_array(npoint,value=minel),thick = 4
  if n_elements(maxel) gt 0 then oplot,jd,make_array(npoint,value=maxel),thick = 4

  
  ps_end


end

pro test_plot_target_sunangle

;  targ                = 'RCW38'
;  targ                = 'carina_nebula'
  targ                = 'cena'

  jdcnv,2012,12,17,0,jd0
  djd  = 30

  latitude_deg        = -77.867
  longitude_start_deg = 166.967

;  latitude_deg        = latitude_deg + [-10.,-5,0.,5.,10.]
  latitude_deg        = latitude_deg + [-8,0.,8.]

  minel               = 30.
  maxel               = 60.

  plot_target_sunangle,target(targ),jd0,djd,longitude_start_deg,latitude_deg,$
    minel=minel,maxel=maxel,psfile=targ+'_sunangle.ps'
  plot_target_sunangle,target(targ),jd0,1,longitude_start_deg,latitude_deg,$
    minel=minel,maxel=maxel,psfile=targ+'_sunangle1.ps'
  plot_target_sunangle,target(targ),jd0,14,longitude_start_deg,latitude_deg,$
    minel=minel,maxel=maxel,psfile=targ+'_sunangle2.ps'



end
