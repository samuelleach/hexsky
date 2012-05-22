FUNCTION make_fitsimage_header,cdelts=cdelts,naxiss=naxiss,crpixs=crpixs, $
                               lon_range=lon_range,lat_range=lat_range, $
                               ctypes=ctypes,crvals=crvals,equinox=equinox,epoch=epoch

d=fltarr(2,2)
mkhdr,h,d

IF NOT keyword_set(cdelts) THEN BEGIN
ENDIF ELSE BEGIN
  cdelt1=cdelts(0)
  cdelt2=cdelts(1)
ENDELSE
IF keyword_set(naxiss) THEN BEGIN
  naxis1=naxiss(0)
  naxis2=naxiss(1)
ENDIF ELSE BEGIN
  IF keyword_set(lon_range) AND keyword_set(lat_range) THEN BEGIN
    lon_min=lon_range(0) & lon_max=lon_range(1)
    lat_min=lat_range(0) & lat_max=lat_range(1)
    naxis1=long((lon_max-lon_min)/abs(cdelt1))
    naxis2=long((lat_max-lat_min)/abs(cdelt2))
    cdelt1=sign(cdelt1)*(lon_max-lon_min)/(1.*abs(naxis1))
    cdelt2=sign(cdelt2)*(lat_max-lat_min)/(1.*abs(naxis2))
  ENDIF ELSE BEGIN
    message,'lon_range and lat_range should be set when naxiss not present',/info
    goto,end_of_it
  ENDELSE
ENDELSE

IF keyword_set(crpixs) THEN BEGIN
  crpix1=crpixs(0)
  crpix2=crpixs(1)
ENDIF ELSE BEGIN
  crpix1=(1.*naxis1)/2.+0.5
  crpix2=(1.*naxis2)/2.+0.5
ENDELSE

IF keyword_set(crvals) THEN BEGIN
  crval1=crvals(0)
  crval2=crvals(1)
ENDIF ELSE BEGIN
  crval1=0.
  crval2=0.
ENDELSE

IF keyword_set(ctypes) THEN BEGIN
  ctype1=ctypes(0)
  ctype2=ctypes(1)
ENDIF ELSE BEGIN
  ctype1='RA---TAN'
  ctype2='DEC--TAN'
ENDELSE

IF not keyword_set(crota2) THEN BEGIN
  crota2=0.
ENDIF

sxaddpar,h,'CDELT1',cdelt1 & sxaddpar,h,'CDELT2',cdelt2
sxaddpar,h,'NAXIS1',naxis1 & sxaddpar,h,'NAXIS2',naxis2
sxaddpar,h,'CRPIX1',crpix1 & sxaddpar,h,'CRPIX2',crpix2
sxaddpar,h,'CRVAL1',crval1 & sxaddpar,h,'CRVAL2',crval2
sxaddpar,h,'CTYPE1',ctype1 & sxaddpar,h,'CTYPE2',ctype2

sxaddpar,h,'CROTA2',crota2

IF keyword_set(equinox) THEN BEGIN
  sxaddpar,h,'EQUINOX',equinox
ENDIF

IF keyword_set(epoch) THEN BEGIN
  sxaddpar,h,'EPOCH',epoch
ENDIF

IF keyword_set(crvals) THEN BEGIN
  sxaddpar,h,'CRVAL1',crvals(0) & sxaddpar,h,'CRVAL2',crvals(1)
ENDIF

end_of_it:

RETURN,h

END
