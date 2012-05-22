FUNCTION get_fsky,map,missval=missval,threshold=threshold

   ;AUTHOR: S. Leach
   ;PURPOSE: Returns the fraction of the map that is
   ;         not equal to missval and (optionally) greater
   ;         than threshold.


   if (n_elements(missval) eq 0 ) then missval = !healpix.bad_value
   if (n_elements(threshold) eq 0 ) then begin
       dothreshold = 0
   endif else begin
       dothreshold = 1
   endelse


   npixtot  = n_elements(map)
   nside    = npix2nside(npixtot)

   index    = where(map ne missval)

   if(dothreshold) then begin
       index2   = where(map gt threshold)
       index    = setintersection(index,index2)
   endif

   get_fsky = double(n_elements(index))/double(npixtot)

   return, get_fsky

end
