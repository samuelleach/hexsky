function create_header, naxis1, naxis2, $
                        ctype1=ctype1, ctype2=ctype2, $
                        crpix1=crpix1, crpix2=crpix2, $
                        crval1=crval1, crval2=crval2, $
                        cdelt1=cdelt1, cdelt2=cdelt2, $
                        crota1=crota1, crota2=crota2, $
                        equinox=equinox, epoch=epoch, $
                        bunit=bunit, waveleng=waveleng, $
                        lonpole=lonpole, telescop=telescop, $
                        instrume=instrume, origin=origin, $
                        comment=comment

if not keyword_set(naxis1) or not keyword_set(naxis2) then begin
    print, 'NAXIS1 and NAXIS2 must be provided'
    return, -1
endif


if n_elements(ctype2) then sxaddpar, header, 'CTYPE2', ctype2
if n_elements(crval1) then sxaddpar, header, 'CRVAL1', crval1
if n_elements(crval2) then sxaddpar, header, 'CRVAL2', crval2
if n_elements(crpix1) then sxaddpar, header, 'CRPIX1', crpix1
if n_elements(crpix2) then sxaddpar, header, 'CRPIX2', crpix2
if n_elements(cdelt1) then sxaddpar, header, 'CDELT1', cdelt1
if n_elements(cdelt2) then sxaddpar, header, 'CDELT2', cdelt2
if n_elements(crota1) then sxaddpar, header, 'CROTA1', crota1
if n_elements(crota2) then sxaddpar, header, 'CROTA2', crota2
if n_elements(equinox) then sxaddpar, header, 'EQUINOX', equinox
if n_elements(epoch) then sxaddpar, header, 'EPOCH', epoch
if n_elements(bunit) then sxaddpar, header, 'BUNIT', bunit
if n_elements(waveleng) then sxaddpar, header, 'WAVELENG', waveleng


mkhdr, header, 4, [fix(naxis1), fix(naxis2)]
if n_elements(ctype1) gt 0 then sxaddpar, header, 'CTYPE1', ctype1
if n_elements(ctype2) gt 0 then sxaddpar, header, 'CTYPE2', ctype2
if n_elements(crval1) gt 0 then sxaddpar, header, 'CRVAL1', crval1
if n_elements(crval2) gt 0 then sxaddpar, header, 'CRVAL2', crval2
if n_elements(crpix1) gt 0 then sxaddpar, header, 'CRPIX1', crpix1
if n_elements(crpix2) gt 0 then sxaddpar, header, 'CRPIX2', crpix2
if n_elements(cdelt1) gt 0 then sxaddpar, header, 'CDELT1', cdelt1
if n_elements(cdelt2) gt 0 then sxaddpar, header, 'CDELT2', cdelt2
if n_elements(crota1) gt 0 then sxaddpar, header, 'CROTA1', crota1
if n_elements(crota2) gt 0 then sxaddpar, header, 'CROTA2', crota2
if n_elements(equinox) gt 0 then sxaddpar, header, 'EQUINOX', equinox
if n_elements(epoch) gt 0 then sxaddpar, header, 'EPOCH', epoch
if n_elements(bunit) gt 0 then sxaddpar, header, 'BUNIT', bunit
if n_elements(waveleng) gt 0 then sxaddpar, header, 'WAVELENG', waveleng

return, header

end                        
