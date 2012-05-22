FUNCTION healp_enlarge,nside,index,radius,ordering=ordering

;Enlarges an index by a certain distance in healpix.

Nindex=n_elements(index)

pix2ang, nside, index, theta, phi ,ordering=ordering
ctheta=cos(theta) & stheta=sin(theta)
cphi=cos(phi) & sphi=sin(phi)
theta=1 & phi=1

mask=intarr(nside2npix(nside))

FOR i=0L,Nindex-1 DO BEGIN
  vec0=[stheta(i)*cphi(i),stheta(i)*sphi(i),ctheta(i)]
  query_disc,nside,vec0,radius,listpix,Nlist,nested=nested,inclusive=inclusive,/deg
;  IF Nlist NE 0 THEN BEGIN
    mask(listpix)=1
;  ENDIF
ENDFOR

enlarged_index=where(mask EQ 1,count)

RETURN,enlarged_index

END
