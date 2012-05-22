FUNCTION get_bolo_pixel,timestream, scope, scan, n_pix, spt=spt, pointing = pointing


n = n_elements(timestream.polarisation[0,*])
;n = n_elements(timestream.delta[0,*])
n_bolo = timestream.n_bolo


if keyword_set(spt) eq 0 then begin
print, 'Beginning simulation for EBEX'
res = timestream.reso_arcmin
nx = n_pix
ny = n_pix
;factor = 60./timestream.reso_arcmin

ra0 = mean(scan.ra[*])
dec0= mean(scan.dec[*])

;sx = (scan.ra[*]-ra0 )*cos(scan.dec[*]*!dtor)
;sy =  scan.dec[*]-dec0

;x_boresight = floor(sx*60./res + nx/2.)
;y_boresight = floor(sy*60./res + ny/2.)
x_bolo = fltarr(n_bolo, n)
y_bolo = fltarr(n_bolo, n)

for i=0, n_bolo-1 do begin

ra_cent = (pointing.ra[i,*]- ra0)*cos(pointing.dec[i,*]*!DTOR)
dec_cent= (pointing.dec[i,*] - dec0)

x_bolo[i,*] = floor(ra_cent*60./res + nx/2.)
y_bolo[i,*] = floor(dec_cent*60./res + ny/2.)

if i mod 50 eq 0 then print, 'Finished', i, ' bolos'

endfor

pixel = {x:x_bolo, y:y_bolo}


;pixel = {x:x_boresight, y:y_boresight,$
;             xoff:(scope.ra*cos(scope.dec*!DTOR))*factor,$
;                                       yoff:scope.dec*factor}
endif else begin
print, 'Beginning simulation for SPT'
;PIXEL_X/Y_BOLO will  be arrays of the given pixels of each bolometer
;at every moment in the timestream.
pixel_x_bolo= fltarr(n_bolo, n)
pixel_y_bolo= fltarr(n_bolo, n)

;MEAN_PIX is a correction to place the center RA/DEC at the middle
;pixel of the map.
mean_pix = n_pix/2.

;NEW_RADEC centers the ra and dec then takes into account the
;correction for the declination
new_radec = fltarr(2,n_elements(scan.ra_dec[0,*]))
new_radec[0,*] =$
     (scan.ra_dec[0,*]-median(scan.ra_dec[0,*]))*cos(scan.ra_dec[1,*]*!DTOR)
new_radec[1,*] = scan.ra_dec[1,*]-median(scan.ra_dec[1,*])


;FACTOR converts from # of degrees into # of pixels
factor = 60./timestream.reso_arcmin

;XOFF and YOFF turn the offsets (given in arcminutes) into pixels offsets.
xoff = fltarr(n_bolo)
yoff = fltarr(n_bolo)
xoff = scope.bolo_array[0,*]*factor/60.
yoff = scope.bolo_array[1,*]*factor/60.

;XCENTRE and YCENTRE bring the centre RA and DEC pointing into X and Y
;coordinates (pixels). 
;xcentre = new_radec[0,*]*factor

;ycentre = new_radec[1,*]*factor
;
;for i=0, n_bolo-1 do begin
;
;pixel_x_bolo[i,*]=round(xcentre+xoff[i]+mean_pix)
;pixel_y_bolo[i,*]=round(ycentre+yoff[i]+mean_pix)
;
;if i mod 25  eq 0 then  print, i

;endfor
;pixel = {pixel_x:pixel_x_bolo, pixel_y:pixel_y_bolo}

xcentre = new_radec[0,*]*factor+mean_pix
ycentre = new_radec[1,*]*factor +mean_pix

pixel = {x:reform(xcentre), y:reform(ycentre),$ 
                         xoff:reform(xoff), yoff:reform(yoff)}

endelse

return, pixel

END
