pro condition_number

Healpix_undef = -1.6375e30 
nside=1024L
npix=nside*nside*12

print,'Reading maps'
read_fits_map,'aTa11_channel_1.fits',ata11
read_fits_map,'aTa12_channel_1.fits',ata12
read_fits_map,'aTa13_channel_1.fits',ata13
read_fits_map,'aTa22_channel_1.fits',ata22
read_fits_map,'aTa23_channel_1.fits',ata23
read_fits_map,'aTa33_channel_1.fits',ata33

print,'Building map matrices'
w = where( ata11 ne 0, nw)
map_ata = fltarr( nw, 3, 3)
for i=0L, nw-1 do begin
    ipix = w[i]
    map_ata[i, 0,0] = ata11[ipix]
    map_ata[i, 1,0] = ata12[ipix]
    map_ata[i, 2,0] = ata13[ipix]
    map_ata[i, 0,1] = map_ata[i, 1,0]
    map_ata[i, 1,1] = ata22[ipix]
    map_ata[i, 2,1] = ata23[ipix]
    map_ata[i, 0,2] = map_ata[i, 2,0]
    map_ata[i, 1,2] = map_ata[i, 2,1]
    map_ata[i, 2,2] = ata33[ipix]
endfor

print,'Evaluating condition number'
map_cond = fltarr( npix)
for i=0L, nw-1 do begin
    ipix = w[i]
    ata = reform( map_ata[i,*,*], 3, 3)
    map_cond[ipix] = cond( ata, /double, lnorm=2)
    
endfor
mollview, reform( map_cond[*]), /on, min=2, max=3

print,'Cholesky decomposition'
map_chold_ata=fltarr( nw, 3, 3)
for i=0L, nw-1 do begin
    ipix = w[i]
    ata = reform( map_ata[i,*,*], 3, 3)   
    
    if ata[0] gt 2 then begin ;choldc seems crashes for low hit count regions
        choldc,ata,diag
        map_chold_ata[i,*,*]=ata 
        map_chold_ata[i,1,0]=0. 
        map_chold_ata[i,2,0]=0. 
        map_chold_ata[i,2,1]=0.
        map_chold_ata[i,0,0]=diag[0]
        map_chold_ata[i,1,1]=diag[1]
        map_chold_ata[i,2,2]=diag[2]
    endif
endfor


print,'Making weight realisations'
seed=1L
iqu_weight = fltarr(npix,3)+healpix_undef

for i=0L, nw-1 do begin
    ipix = w[i]
    gauss=randomn(seed,3)
    iqu_weight(ipix,*) = map_chold_ata(i,*,*) # gauss

    seed = seed+1
endfor
;mollview,iqu_weight[*,0],/online
;mollview,iqu_weight[*,1],/online
;mollview,iqu_weight[*,2],/online

print,map_chold_ata(0,*,*)
print,' '
print,map_chold_ata(1,*,*)

;histogauss,map_chold_ata(*,0,0),a
;window,1
;histogauss,map_chold_ata(*,1,1),a
;window,2
;histogauss,map_chold_ata(*,2,2),a
;window,3
window,4
plot,map_chold_ata(*,1,1),map_chold_ata(*,1,2),xtitle='Q weight',ytitle='QU weight',psym=3
;histogauss,map_chold_ata(*,1,2),a

write_tqu,'weight.fits',iqu_weight,ordering='ring',coordsys='C'






end
