FUNCTION healp_drizzle,nside,fits_header

h=fits_header
Nx=sxpar(h,'NAXIS1')
Ny=sxpar(h,'NAXIS2')
cdelt1=sxpar(h,'CDELT1')
cdelt2=sxpar(h,'CDELT2')
create_coo2,h,c1,c2,/silent

;make healpix vector
ordering='RING'
Npix=nside2npix(nside)
ipix=lindgen(Npix)

;compute pixel center coordinates
pix2ang,nside,ipix,theta_ce,phi_ce,ordering=ordering

;compute healpix corners coordinates
pix2corners,nside,ipix,theta_co,phi_co,ordering=ordering

;compute index of corners in FITS image
h2pix,h,ipix,jpix,/silent
ijpix=lonarr(Nx*Ny,2)
ijpix(*,0)=ipix
ijpix(*,1)=jpix
all_pix_nums=reform(ij2index(ijpix,[Nx,Ny]),Nx,Ny)

th_co=1 & ph_co=1
coo2pix2,phi_co*!radeg,90.-theta_co*!radeg,i_co,j_co,ph_co,th_co
ph_ce=1 & th_ce=1
coo2pix2,phi_ce*!radeg,90.-theta_ce*!radeg,i_ce,j_ce,ph_ce,th_ce

surf_pix_healp=40000./Npix
surf_pix_fits=abs(Nx*cdelt1*Ny*cdelt2)

;find pixels which intersect Fits image (one corner into the fits image)
index=where((i_co(*,0) GE 0 AND i_co(*,0) LE Nx-1 AND j_co(*,0) GE 0 AND j_co(*,0) LE Ny-1) OR $
          (i_co(*,1) GE 0 AND i_co(*,1) LE Nx-1 AND j_co(*,1) GE 0 AND j_co(*,1) LE Ny-1) OR $
          (i_co(*,2) GE 0 AND i_co(*,2) LE Nx-1 AND j_co(*,2) GE 0 AND j_co(*,2) LE Ny-1) OR $
          (i_co(*,3) GE 0 AND i_co(*,3) LE Nx-1 AND j_co(*,3) GE 0 AND j_co(*,3) LE Ny-1) AND $
          th_co GE 0,count)
;stop
radius=sqrt(surf_pix_healp)
index=healp_enlarge(nside,index,radius,ordering=ordering)
count=n_elements(index)

;vec=fltarr(Npix)
;vec(ind)=th(index)
;vec(ind)=d(round(i_ce(index)),round(j_ce(index)))
;mollview,vec,/on

Nmaxpix=round(2*surf_pix_fits/surf_pix_healp)
pixnums=lonarr(Nmaxpix)
corner_inside=lonarr(Nmaxpix,4)
surf=fltarr(Nmaxpix)
one_pix={pix_num:ptr_new(),corner_is_inside:ptr_new(),surface_inside:ptr_new()}
inside_out=replicate(one_pix,Npix)
i_offset=[-0.5,+0.5,+0.5,-0.5]
j_offset=[-0.5,-0.5,+0.5,+0.5]

;count=100L ;for tests

FOR i=0L,count-1 DO BEGIN
  ii=index(i)
  ;define region of FITS image containing the healpix pixel
  imin=fix(min(i_co(ii,*)))>0 & jmin=fix(min(j_co(ii,*)))>0
  imax=ceil(max(i_co(ii,*)))<(Nx-1) & jmax=ceil(max(j_co(ii,*)))<(Ny-1)
;Find out if the corners of the fits pixels are inside the healpix pixel
  i_polygon=reform(i_co(ii,*)) & j_polygon=reform(j_co(ii,*))
  iv=0L
;  plot,i_polygon,j_polygon,psym=-3,/xsty,/ysty
  FOR ip=imin,imax DO BEGIN
    FOR jp=jmin,jmax DO BEGIN
      i_fits_corners=ip+i_offset
      j_fits_corners=jp+j_offset
;      oplot,i_fits_corners,j_fits_corners,psym=-3,color=100
      is_inside=inside(i_fits_corners, j_fits_corners, i_polygon, j_polygon)
      ind2=where(is_inside EQ 1,c2)
      IF c2 NE 0 THEN BEGIN
;        oplot,i_fits_corners(ind2),j_fits_corners(ind2),psym=4,color=150
        pixnums(iv)=all_pix_nums(ip,jp)
        corner_inside(iv,*)=is_inside
        surf(iv)=inter_poly_box(i_polygon,j_polygon,i_fits_corners,j_fits_corners,is_inside)
        iv=iv+1
      ENDIF      
    ENDFOR
  ENDFOR
  IF iv NE 0 THEN BEGIN
    inside_out(ii).pix_num=ptr_new(pixnums(0:iv-1))
    inside_out(ii).corner_is_inside=ptr_new(corner_inside(0:iv-1,*))
    inside_out(ii).surface_inside=ptr_new(surf(0:iv-1))
  ENDIF
  message,'Done healpix pixel:'+strtrim(i,2)+'/'+strtrim(count-1),/info
ENDFOR

;;==compute fraction of surface inside healpix pixel
;message,'Computing pixel fractions',/info
;ind2=where(ptr_valid(inside_out.pix_num),c2) 
;FOR i=0L,c2-1 DO BEGIN
;  ii=index(i)
;;Find out if the corners of the fits pixels are inside the healpix pixel
;  i_polygon=reform(i_co(ii,*)) & j_polygon=reform(j_co(ii,*))
;  Nfits_pix=n_elements(*(inside_out(ind2(i)).pix_num))
;  surf=fltarr(Nfits_pix)
;  ij=index2ij(*(inside_out(ind2(i)).pix_num),[Nx,Ny])
;  FOR j=0L,Nfits_pix-1 DO BEGIN
;    inside_vec=(*(inside_out(ind2(i)).corner_is_inside))(j,*) ;4 vector giving inside indication
;    i_box=i_offset+ij(j,0)
;    j_box=j_offset+ij(j,1)
;    surf(j)=inter_poly_box(i_polygon,j_polygon,i_box,j_box,inside_vec)
;  ENDFOR
;  inside_out(ind2(i)).surface_inside=ptr_new(surf)
;ENDFOR

RETURN,inside_out

END
