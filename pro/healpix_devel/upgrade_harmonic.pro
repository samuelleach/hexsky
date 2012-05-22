pro upgrade_harmonic,map_in,map_out,$
                     nside_out=nside_out,order_in=order_in,lmax=lmax,$
                     iter_order=iter_order


    ;AUTHOR: S. Leach
    ;PURPOSE: Perform an 'upgrade' of healpix map via resythesis of
    ;         the map a_lm at higher pixelization.


    npix     = n_elements(map_in)
    nside_in = npix2nside(npix)

    if not n_elements(nside_out) then nside_out = 2*nside_in
    if not n_elements(order_in)  then order_in  = 'ring'
    if not n_elements(lmax)      then lmax      = 3*nside_in-1
    if not n_elements(iter_order)then iter_order= 1


    mask  = make_array(npix,value=1)
    index = where(map_in eq 0.)
    
    ;Harmonic upgrade
    almfile = 'temp.alm.fits'
    ianafast,map_in,cl_out,alm1_out=almfile,nlmax=lmax,ordering=order_in,iter_order=iter_order,/double
    isynfast,0,map_out,alm_in=almfile, nside = nside_out,nlmax=lmax,/double
    spawn,'rm -rf '+almfile

    ;Set to zero pixels that were zero before
    if index[0] ne -1 then begin
       mask[index] = 0.
       ud_grade,mask,mask,order_in=order_in,nside_out=nside_out
       index = where(mask eq 0.)
       if index[0] ne -1 then map_out[index] = 0.
    endif

    if order_in eq 'NESTED' then begin
       map_out = reorder(map_out ,/r2n)
    endif


end
