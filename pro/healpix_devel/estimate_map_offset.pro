FUNCTION estimate_map_offset,map,oplot=oplot,$
                             trialoffset=trialoffset,factor=factor,$
                             order=order,$
                             target_meanval=target_meanval,$
                             lat_bandwidth=lat_bandwidth,$
                             indexcuts=indexcuts,latcuts_deg=latcuts_deg,$
                             cosecmaxval=cosecmaxval
                             

   ;AUTHOR: S. Leach
   ;PURPOSE: Estimate the Galactic offset in a map using the
   ;         cosec fit (plane-parallel slab model.)

   if(n_elements(factor) eq 0)        then factor      = 1.
   if(n_elements(trialoffset) eq 0)   then trialoffset = 0.
   if(n_elements(lat_bandwidth) eq 0) then lat_bandwidth = 10.
   if(n_elements(order) eq 0) then order = 'NESTED'

   index      = where(map ne !healpix.bad_value,np)
   map[index] = factor*map[index] + trialoffset
   nside      = npix2nside(n_elements(map))


   if n_elements(indexcuts) eq 0 then begin
       if order eq 'NESTED' then begin
           get_latitude_band_cuts,nside,lat_bandwidth,indexcuts,latcuts_deg,/nest
       endif else begin
           get_latitude_band_cuts,nside,lat_bandwidth,indexcuts,latcuts_deg
       endelse
   endif

   nband    = n_elements(latcuts_deg)
   profile  = fltarr(nband) 
   rms = fltarr(nband) 
   for pp = 0, nband-1 do begin
       pixlist     = setintersection(*indexcuts[pp],index)
       mymoment    = moment(map[pixlist],/double)
       profile[pp] = mymoment[0]
       rms[pp]     = sqrt(mymoment[1])
   endfor

   northindex = where(latcuts_deg gt 0.)
   southindex = where(latcuts_deg le 0.)

   coseclat_north = 1./sin(abs(latcuts_deg[northindex]*!DTOR))
   coseclat_south = 1./sin(abs(latcuts_deg[southindex]*!DTOR))
   profile_north  = profile[northindex]
   profile_south  = profile[southindex]
   rms_north      = rms[northindex]
   rms_south      = rms[southindex]

   if n_elements(cosecmaxval) eq 0 then cosecmaxval = max(coseclat_north)
   if (keyword_set(oplot)) then begin
       oplot,coseclat_north,profile_north
   endif else begin
       plot,coseclat_north,profile_north,chars=2,ytitle='Signal',xtitle=textoidl('Cosec(b)'),sym=1,$
         xrange = [0,cosecmaxval]
   endelse
   oploterr,coseclat_north,profile_north,rms_north
   oploterr,coseclat_south,profile_south,rms_south
    
   oplot,coseclat_south,profile_south,line=2,sym=1
   al_legend,box=0,['North','South'],line=[0,2],chars=2
   

   cosec_max = 1./sin(15.*!dtor)
   fitindex_north = where(coseclat_north lt cosec_max)
   fitindex_south = where(coseclat_south lt cosec_max)

   nfit_north = n_elements(fitindex_north)
   fitexy,coseclat_north[fitindex_north],profile_north[fitindex_north],a_north,b_north,$
     sigma_a_b_north,x_sig=0.01*make_array(nfit_north,value=1.),$
     y_sig=rms_north[fitindex_north]
   print,'North cs=0 intercept = ',a_north,' +/- ',sigma_a_b_north[0]
   print,'North slope          = ',b_north,' +/- ',sigma_a_b_north[1]


   nfit_south = n_elements(fitindex_south)
   fitexy,coseclat_south[fitindex_south],profile_south[fitindex_south],a_south,b_south,$
     sigma_a_b_south,$
     x_sig=0.01*make_array(nfit_south,value=1.),$
     y_sig=rms_south[fitindex_south]
   print,'South cs=0 intercept = ',a_south,' +/- ',sigma_a_b_south[0]
   print,'South slope          = ',b_south,' +/- ',sigma_a_b_south[1]


   mapaverage =  total(map[index],/double)/double(np)
   mapminmax  = minmax(map[index])
   print,'Map average value = ',mapaverage
   print,'Map minmax values = ',mapminmax

;   print,min(profile_north),min(profile_south)

;   offset =  (a_south*sigma_a_b_south[0]^(-2) + a_north*sigma_a_b_north[0]^(-2))/$
;     (sigma_a_b_south[0]^(-2) + sigma_a_b_north[0]^(-2)) -$
;     (b_south*sigma_a_b_south[1]^(-2) + b_north*sigma_a_b_north[1]^(-2))/$
;     (sigma_a_b_south[1]^(-2) + sigma_a_b_north[1]^(-2))

   offset =   (a_south*sigma_a_b_south[0]^(-2) + a_north*sigma_a_b_north[0]^(-2))/$
     (sigma_a_b_south[0]^(-2) + sigma_a_b_north[0]^(-2))
   
   print,'Recommended offset to add to map = ',-offset
   target_meanval = -offset + mapaverage
   print,'Recommended map average value    = ',target_meanval

   return,offset

end
