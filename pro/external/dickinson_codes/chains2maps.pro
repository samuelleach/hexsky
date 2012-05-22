PRO chains2maps,commander_parfile,num_burnin=num_burnin,makefiles=makefiles

; procedure to take Commander chain files and produce
; useful sky maps 
; also template, chisq and cls/sigma files
; Uses HKE's comm_process_resfiles routine
;
; Run in the chains directory
;
;
; 10-Sep-2008  C. Dickinson   1st go
; 11-Aug-2010  S. Leach       Modify to scrape parameters from the
;                             Commander parameter file.
;-----------------------------------------------------

if n_elements(num_burnin) eq 0 then num_burnin = 10 ; number of burn-in samples
if n_elements(makefiles) eq 0  then makefiles  = 1  ; Run the fortran codes

param = read_parameterfile(commander_parfile)

; Input parameters
num_iter   = 184 ; param.num_gibbs_iter      ;1000L    ; Total number of Gibbs samples per chain
num_chains = param.num_groups                ;1      ; number of chains
nside      = param.nside                     ;128    ; Nside
lmax       = param.lmax                      ;1      ; Max multipole for CMB map
fwhm       = param.fwhm_lowres               ;60.    ; Beam FWHM for CMB map (arcmin)
namp       = param.num_fg_signal_components  ;3      ; Number of amplitude components
nind       = param.num_fg_signal_components-1;3      ; Number of index components
pol        = param.polarization              ;1      ; number of polarizations (1 for I, 3 for I,Q,U)
if(pol eq '.true.') then begin
    npol = 3 
endif else begin
    npol = 1
endelse
nspec         = 0                                    ; number of power spectra
nchan         = param.numband                ;16     ; number of channels
nfreetemplate = param.num_free_fg_temp       ;0      ; number of free foreground templates (not including mono/dipoles)
nindtemplate  = param.num_ind_fg_temp        ;0      ; number of index foreground templates

; give path to correct binary executable
binexecutable = '~/bin/comm_process_resfiles'

IF (makefiles EQ 1) THEN BEGIN
; get pix_amp_fg array
str = binexecutable + ' 3 ../pix_amp_fg.fits 1 1 1 ' + string(nside,format='(i5)') +  strcompress(string(npol*namp,format='(i3)')) + string(num_iter,format='(i8)')  + string(num_burnin,format='(i8)') + ' 1 ' + string(num_chains,format='(i8)')
str = strcompress(str)
print, 'MAKING PIX_AMP_FG ARRAY'
spawn, str

; get pix_ind_fg array
str = binexecutable +' 3 ../pix_ind_fg.fits 2 1 1 ' + string(nside,format='(i5)') + strcompress(string(npol*nind,format='(i3)')) + string(num_iter,format='(i8)')  + string(num_burnin,format='(i8)') + ' 1 ' + string(num_chains,format='(i8)')
str = strcompress(str)
print, 'MAKING PIX_IN_FG ARRAY'
spawn, str

; get cmb array
str = binexecutable + ' 4 ../cmb.fits ' + string(lmax,format='(i5)') + string(nside,format='(i5)') +  ' ' + string(npol,format='(i3)') + string(fwhm,format='(i6)') + string(num_iter,format='(i8)') + string(num_chains,format='(i8)')
str = strcompress(str)
spawn, str

; make total chisq file
str = binexecutable + ' 5 ../chisq.fits ' + string(num_iter,format='(i8)') + string(num_chains,format='(i8)')
str = strcompress(str)
print, 'MAKING CHISQ ARRAY'
spawn, str


; free_fg file
str = binexecutable + ' 2 ../free_fg.fits ' + '1 ' + string(nfreetemplate+4,format='(i3)') + string(nchan,format='(i3)') + string(num_iter,format='(i8)') + string(num_chains,format='(i8)')
str = strcompress(str)
print, 'MAKING FREE_FG ARRAY'
spawn, str


; ind_fg file
str = binexecutable +' 2 ../ind_fg.fits ' + '2 ' + string(nindtemplate,format='(i3)') + ' 1 ' + string(num_iter,format='(i8)') + string(num_chains,format='(i8)')
str = strcompress(str)
print, 'MAKING IND_FG ARRAY'
spawn, str


; make cls and sigma files
str = binexecutable + ' 1 ../cls.fits' + ' 1 ' + string(num_iter,format='(i8)') + string(num_chains,format='(i8)') + string(lmax,format='(i5)') + string(nspec,format='(i3)')
str = strcompress(str)
print, 'MAKING CLS ARRAY'
spawn, str



str = binexecutable + ' 1 ../sigma.fits' + ' 2 ' + string(num_iter,format='(i8)') + string(num_chains,format='(i8)') + string(lmax,format='(i5)') + string(nspec,format='(i3)')
str = strcompress(str)
print, 'MAKING SIGMA ARRAY'
spawn, str



ENDIF



; now average the pix_amp_fg.fits
array   = readfits('../pix_amp_fg.fits')
npix    = 12L * long(nside)^2
pix_amp = fltarr(npix,2,npol*namp)
ngood   = num_iter-num_burnin
FOR j=0L, npol*namp-1 DO BEGIN
FOR i=0L, npix-1 DO BEGIN
pix_amp[i,0,j] = total(array[i,j,*,0:ngood-1]) / float(ngood*num_chains)
pix_amp[i,1,j] = stddev(array[i,j,*,0:ngood-1])
ENDFOR
outfile = '../pix_amp' + strcompress(string(j+1,format='(i1)'),/remove_all) + '_mean.fits'
write_fits_map, outfile, pix_amp[*,0,j], /ring
outfile = '../pix_amp' + strcompress(string(j+1,format='(i1)'),/remove_all) + '_rms.fits'
write_fits_map, outfile, pix_amp[*,1,j], /ring
ENDFOR
delvarx,array
delvarx,pix_amp


; now average the pix_ind_fg.fits
array   = readfits('../pix_ind_fg.fits')
pix_ind = fltarr(npix,2,npol*nind)
FOR j=0L, npol*nind-1 DO BEGIN
FOR i=0L, npix-1 DO BEGIN
pix_ind[i,0,j] = total(array[i,j,*,0:ngood-1]) / float(ngood*num_chains)
pix_ind[i,1,j] = stddev(array[i,j,*,0:ngood-1])
ENDFOR
outfile = '../pix_ind' + strcompress(string(j+1,format='(i1)'),/remove_all) + '_mean.fits'
write_fits_map, outfile, pix_ind[*,0,j], /ring
outfile = '../pix_ind' + strcompress(string(j+1,format='(i1)'),/remove_all) + '_rms.fits'
write_fits_map, outfile, pix_ind[*,1,j], /ring
ENDFOR
delvarx,array
delvarx,pix_ind


; now average the cmb.fits
array = readfits('../cmb.fits',1,hdr)
cmb   = fltarr(npix,2,npol)
FOR j=0L, npol-1 DO BEGIN
FOR i=0L, npix-1 DO BEGIN
cmb[i,0,j] = total(array[i,j,*,num_burnin:num_iter-1]) / float(ngood*num_chains)
cmb[i,1,j] = stddev(array[i,j,*,num_burnin:num_iter-1]) 
ENDFOR
ENDFOR
delvarx,array

IF (npol NE 3) THEN write_fits_map, '../cmb_mean.fits', cmb[*,0,0], /ring ELSE write_tqu, '../cmb_mean.fits', reform(cmb[*,0,*],npix,npol), /ring
IF (npol NE 3) THEN write_fits_map, '../cmb_rms.fits', cmb[*,1,0], /ring ELSE write_tqu, '../cmb_rms.fits', reform(cmb[*,1,*],npix,npol), /ring


; also make postscripts of each one
mollview, cmb[*,0,0], ps='../cmb_mean.ps', title='CMB amplitude mean'
mollview, cmb[*,1,0], ps='../cmb_rms.ps', title='CMB amplitude r.m.s.'
delvarx,cmb

; do for component number 1
mollview, '../pix_amp1_mean.fits', ps='../pix_amp1_mean.ps', title='Foreground amplitude no 1 mean'
mollview, '../pix_amp1_rms.fits', ps='../pix_amp1_rms.ps', title='Foreground amplitude no 1 r.m.s.'
mollview, '../pix_ind1_mean.fits', ps='../pix_ind1_mean.ps', title='Foreground index no 1 mean' 
mollview, '../pix_ind1_rms.fits', ps='../pix_ind1_rms.ps', title='Foreground index no 1 r.m.s.'

IF (namp GE 2) THEN BEGIN
mollview, '../pix_amp2_mean.fits', ps='../pix_amp2_mean.ps', title='Foreground amplitude no 2 mean'
mollview, '../pix_amp2_rms.fits', ps='../pix_amp2_rms.ps', title='Foreground amplitude no 2 r.m.s.'
ENDIF

IF (nind GE 2) THEN BEGIN
mollview, '../pix_ind2_mean.fits', ps='../pix_ind2_mean.ps', title='Foreground index no 2 mean' 
mollview, '../pix_ind2_rms.fits', ps='../pix_ind2_rms.ps', title='Foreground index no 2 r.m.s.'
ENDIF

IF (namp GE 3) THEN BEGIN
mollview, '../pix_amp3_mean.fits', ps='../pix_amp3_mean.ps', title='Foreground amplitude no 3 mean'
mollview, '../pix_amp3_rms.fits', ps='../pix_amp3_rms.ps', title='Foreground amplitude no 3 r.m.s.'
ENDIF

IF (nind GE 3) THEN BEGIN
mollview, '../pix_ind3_mean.fits', ps='../pix_ind3_mean.ps', title='Foreground index no 3 mean' 
mollview, '../pix_ind3_rms.fits', ps='../pix_ind3_rms.ps', title='Foreground index no 3 r.m.s.'
ENDIF

IF (namp GE 4) THEN BEGIN
mollview, '../pix_amp4_mean.fits', ps='../pix_amp4_mean.ps', title='Foreground amplitude no 4 mean'
mollview, '../pix_amp4_rms.fits', ps='../pix_amp4_rms.ps', title='Foreground amplitude no 4 r.m.s.'
ENDIF

IF (nind GE 4) THEN BEGIN
mollview, '../pix_ind4_mean.fits', ps='../pix_ind4_mean.ps', title='Foreground index no 4 mean' 
mollview, '../pix_ind4_rms.fits', ps='../pix_ind4_rms.ps', title='Foreground index no 4 r.m.s.'
ENDIF



STOP
END 
