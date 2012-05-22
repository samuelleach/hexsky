PRO pix2corners,nside,pixnum,theta_corners,phi_corners,ordering=ordering

npix=n_elements([pixnum])

IF not keyword_set(ordering) THEN BEGIN
  pix2vec_ring, nside, pixnum, vec, vertex   ;RING ordering assumed
ENDIF ELSE BEGIN
  IF ordering EQ 'NESTED' THEN BEGIN
    pix2vec_nest, nside, pixnum, vec, vertex
  ENDIF ELSE BEGIN
    pix2vec_ring, nside, pixnum, vec, vertex
  ENDELSE
ENDELSE

;print,vertex_ring
;print,vertex_nest

theta_corners=fltarr(npix,4)
phi_corners=fltarr(npix,4)

FOR i=0,3 DO  BEGIN
  vec2ang, vertex(*,*,i),theta,phi
  theta_corners(*,i)=theta & phi_corners(*,i)=phi
ENDFOR

END


