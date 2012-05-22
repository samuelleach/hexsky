function hpixheader, nside, order=order

; return the header of a Healpix vector of given NSIDE and ORDERING

if not keyword_set(order) then order='RING'

npix = nside2npix(nside)
;mkhdr, header, fltarr(npix) ; SL commenting out for optimisation
sxaddpar, header, 'ORDERING', order
sxaddpar, header, 'PIXTYPE', 'HEALPIX'
sxaddpar, header, 'NSIDE', nside
sxaddpar, header, 'NPIX', npix
sxaddpar, header, 'FIRSTPIX', 0
sxaddpar, header, 'LASTPIX', npix-1
sxaddpar, header, 'EQUINOX', 'J2000' ;SL added for keeping hpix2map silent.

return, header

end
