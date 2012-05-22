pro hii_region_read,ra,dec,S_jy,theta_arcmin
  
  ;AUTHOR: S. Leach
  ;PURPOSE: Demonstrator program for reading HII region catalogue.
  
  readcol,!HEXSKYROOT+'/data/synthcat.dat',$
	   region_number,gname_dummy,$
	   RAh,RAm,RAs,$
	   DEd,DEm,DEs,$
	   S_jy,dS_jy,theta_arcmin,dtheta_arcmin,/silent
  
  ;Convert to degrees
  radec2deg,ra,dec,RAh,RAm,RAs,DEd,DEm,DEs

;  histogauss,s_jy,bb

  
  ;RCW38  is 945 ; There is a compact source (947) with S=183 Jy right on top of RCW38
  ; IC1795 is 851
  region = 945
  index = where(region_number eq region)
  print,'RA, Dec [deg] = ',RA(index),dec(index)
  print,'Flux density [Jy] = ',s_jy(index)
  print,'Approximate size [arcmin] = ',theta_arcmin(index)
 
  nside = 1024
  map   = make_array(nside2npix(nside),value=!healpix.bad_value)


  for rr=0,n_elements(ra)-1 do begin
    Ang2Vec, DEC[rr], RA[rr], vec_cen, /astro
    QUERY_DISC, nside, vec_cen, theta_arcmin[rr]/60.,$
		Listpix, npix, /deg, /inclusive
    if s_jy[rr] gt 20. then  map(listpix)=s_jy[rr]
  endfor

;  gnomview,map,rot=[84,-4.7]
;;  gnomview,map,rot=[309.,41.]
;;  gnomview,map,rot=[93,19]
;;  gnomview,map,rot=[134.811,-46.7]

  region = 851
  index  = where(region_number eq region)
  ra0    = RA(index)
  dec0   = dec(index)
;  gnomview,map,rot=[ra0,dec0]

  
;  mollview,map,PXSIZE=1200

;  ximview,map
;  write_fits_map,'hii.fits',map,/ring
  
  index = where(s_jy gt 150.)

  ra    = ra[index]
  dec   = dec[index]
  s_jy  = s_jy[index]
  theta_arcmin = theta_arcmin[index]
  
  
end
