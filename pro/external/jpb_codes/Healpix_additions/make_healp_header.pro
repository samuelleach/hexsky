FUNCTION make_healp_header,nside,coordsys=coordsys,ordering=ordering, $
                           main_header=main_header,data_sample=data_sample

; Returns extension header for a healpix float vector

order='RING'  ;default value
csys='E'      ;default value
d_sample=0.   ;default data type

IF keyword_set(coordsys) THEN BEGIN
  csys=coordsys
ENDIF

IF keyword_set(ordering) THEN BEGIN
  order=ordering
ENDIF

IF keyword_set(data_sample) THEN BEGIN
  d_sample=data_sample
ENDIF

Npix=12L*(1.*nside)^2
healp_vec=replicate(d_sample,Npix)

filename='/tmp/toto.fits'
WRITE_FITS_MAP, filename, healp_vec,Ordering=order

READ_FITS_MAP, filename, T_sky , hdr, exthdr

sxaddpar,exthdr,'NSIDE',nside
sxaddpar,exthdr,'COORDSYS',csys

main_header=hdr

RETURN,exthdr

END