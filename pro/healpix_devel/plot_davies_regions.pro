pro plot_davies_regions

  ;AUTHOR: S. Leach
  ;PURPOSE: Make various plots of the 'Davies regions' from
  ;         Davies (2006) MNRAS, 37, 1125-1139
  
;-definition of the Davies regions--------------------------------
; From Table 2 of Davies et al 2006
long_min=[245,140,200,250, 90,118,300,227,145,300,33,270,-10,70, 76]
long_max=[260,155,230,260, 97,135,315,237,165,320,45,310,  5,90, 84]
lat_min =[21, 15, -41,-25,-13, 20, 35, 12,-30,-30,50, 55,-35,20,-30]
lat_max =[31, 20, -48,-35,-30, 37, 45, 18,-38,-40,70, 70,-50,30,-50]
;-----------------------------------------------------------------

fields=make_array(n_elements(long_min),value={outline})

long= make_array(5,value=0.)
lat = make_array(5,value=0.)

window,0
first=0

;Convert Davies regions coordinates to RA/DEC and plot
for ii=first,n_elements(long_min)-1 do begin
    long[0]= long_min[ii]  & lat[0]=lat_min[ii]
    long[1]= long_min[ii]  & lat[1]=lat_max[ii]
    long[2]= long_max[ii]  & lat[2]=lat_max[ii]
    long[3]= long_max[ii]  & lat[3]=lat_min[ii]
    long[4]= long_min[ii]  & lat[4]=lat_min[ii]
    euler,long,lat,ra,dec,2
    
    if ii eq first then $
      plot,ra,dec,xrange=[0,360],yrange=[-90,90],xstyle=1,$
      xtitle='RA [deg]',ytitle='Dec [deg]'
    oplot,ra,dec
    xyouts,total(minmax(ra))/2,total(minmax(dec))/2,strtrim(ii+1,2),$
      alignment=0.5

    ;Convert coordinates into an outline struct.
    fields[ii]=outline_polygon(ra,dec)
endfor


window,1
;Plot Davies regions in Galactic Lon/Lat coordinates
for ii=first,n_elements(long_min)-1 do begin
    long[0]= long_min[ii]  & lat[0]=lat_min[ii]
    long[1]= long_min[ii]  & lat[1]=lat_max[ii]
    long[2]= long_max[ii]  & lat[2]=lat_max[ii]
    long[3]= long_max[ii]  & lat[3]=lat_min[ii]
    long[4]= long_min[ii]  & lat[4]=lat_min[ii]
    euler,long,lat,ra,dec,2
    
    if ii eq first then $
      plot,long,lat,xrange=[-20,360],yrange=[-90,90],xstyle=1,$
      xtitle='l [deg]',ytitle='b [deg]'
    oplot,long,lat
    xyouts,total(minmax(long))/2,total(minmax(lat))/2,strtrim(ii+1,2),$
      alignment=0.5
endfor


;Plot fields
map=!HEXSKYROOT+'/data/cbdustmodel_150.000ghz.fits'
;map=make_array(nside2npix(512))
skyview,map,field=fields,projection='moll',rot_ang=[230,55.000,0.00000],max=200


end
