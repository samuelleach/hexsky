pro Radgen, outimg, radx, rady, xcen0, ycen0,  $
            imsize=imsize, bin=bin, $
            rmin=rmin, rmax=rmax, $
            ellratio=ellratio, ellpa=ellpa, $
            poly=poly, plot=plot, $
            silent=silent,linear=linear,center=center

;+
; PURPOSE:
; Program to generate a 2-d image given 1-d profile
; (radial or elliptical) with a specified center and radial extent.
;
; NOTES:
; The radial profile is interpolated in log space either by
;  (1) a 5th order polynomial function, or
;  (2) spline interpolation (default)
; Be sure to inspect to insure the fit is sensible (esp. at outer edges).
;
; If the psf is very strongly peaked, set bin > 1 to ensure 
; pixellation is not a problem
;
; To get the profile from the original image, one can use RADPLOTF
;
; INPUTS
;	radx	radial profile: radial distances (in units of pixels)
;	rady	radial profile: fluxes
;
; OPTIONAL INPUTS
;	x,y	center location 
;
; OUTPUTS
;	outimg	2-d image 
;
; KEYWORD INPUTS {defaults}
;       imsize  size of output image; may be a two element vector {64}
;       bin     binning factor for making the psf - should be odd {1}
;       rmin    min radius for image {0}
;       rmax    max radius for image {imsize}
;	ellratio  for elliptical phot, ratio of major to minor axes 
;	ellpa	for elliptical phot, position angle CCW from up
;	        (with elliptical phot, all the radii become
;		the semi major axis)
;       /poly use poly interpolation for the radial profile
;	/plot	plot the interpolated fit to the radial profile
;	/silent	
;	center=		alternate way of setting xcen and ycen
;
; NOTES
; - This program developed by modifying RADSUB.PRO:
;   changed profile interpolation options and removed
;   sky subtraction option.
; - 1st half of code is nearly identical to RADPLOTF
;
; HISTORY: Written by M. Liu (UCB) 06/19/96
; 08/11/98 (MCL): fixed bug with using 'bin' - put obj in wrong place
; 08/18/00 (MCL): 'imsize' can now be a 2-element vector
; 2003-11-28 MDP: Fixed apparent bug with "bin" where xsize,ysize where
; 	multiplied by bin twice.
;
;-

; set defaults & useful constants
if not(keyword_set(imsize)) then begin
    imsize = 64 & xsize = 64 & ysize = 64
endif else begin
    if n_elements(imsize) eq 1 then begin
        xsize = imsize & ysize = imsize 
    endif else begin
        xsize = imsize(0) & ysize = imsize(1)
    endelse
endelse
if not(keyword_set(bin)) then bin = 1
if not(keyword_set(rmin)) then rmin =  0
if not(keyword_set(rmax)) then rmax = max(imsize)

if keyword_set(center) and ~(keyword_set(xcen0)) then xcen0=center[0]
if keyword_set(center) and ~(keyword_set(ycen0)) then ycen0=center[1]
	
if n_elements(xcen0) eq 0 then xcen0 = xsize*1.0/2
if n_elements(ycen0) eq 0 then ycen0 = ysize*1.0/2 

; user guide
if n_params() lt 3 then begin
    print, 'pro Radgen, outimg, radx, rady, (xcen), (ycen),'
    print, '            [imsize=', strc(imsize), '], [bin=', $
      strc(bin), '], [rmin=', $ 
      strc(rmin), '],[rmax=', strc(rmax), '],'
    print, '            [ellratio=], [ellpa=]' 
    print, '            [poly],[plot], [silent]'
    return
endif


; check the radial profile
if n_elements(radx) eq 0 then begin
    message, 'radial profile is undefined!', /info
    stop
endif else begin
    nrad = n_elements(radx)
    if (rmax gt max(radx)) then rmax =  max(radx)
    drad = radx(2) - radx(1)
endelse
; MDP 2006-08-02 why should we care if any of it is <0?
; Answer: Because it breaks the fitting of the polynomial model
;  which takes place in log space.
if min(rady) le 0.0 then begin
	message,'radial profile is not always >= zero!',/info
	stop
endif


; set binning to an odd value so we can put the
; max pixel in the center when rebinning at the end
if not(odd(bin)) then bin =  bin+1


; initialize
nx = xsize*bin
ny = ysize*bin
outimg = fltarr(nx, ny) 
if (bin gt 1) then message, 'subpixel binning = '+strc(bin), /info
xcen = xcen0*bin
ycen = ycen0*bin

; makes an array of (distance)^2 from center of aperture
;   where distance is the radial or the semi-major axis distance.
;   based on DIST_CIRCLE and DIST_ELLIPSE in Goddard IDL package
;   but now can deal with rectangular image sections
distsq = fltarr(nx,ny,/nozero)
if keyword_set(ellratio) or keyword_set(ellpa) then begin

	if not(keyword_set(ellratio)) then ellratio=1.0
	if not(keyword_set(ellpa)) then ellpa = 0.0
	if not(keyword_set(silent)) then $
	  message,'elliptical phot, ratio='+strc(ellratio)+$
		', pa='+strc(ellpa),/info

	ang = ellpa /!RADEG                      
	cosang = cos(ang)
	sinang = sin(ang)
	xx = findgen(nx) - xcen
	yy = findgen(ny) - ycen

;	rotate pixels to match ellipse orientation
	xcosang = xx*cosang
	xsinang = xx*sinang

	for i = 0L,ny-1 do begin
	  xtemp =  xcosang + yy(i)*sinang
	  ytemp = -xsinang + yy(i)*cosang
	  distsq(0,i) = (xtemp*ellratio)^2 + ytemp^2 
	endfor

; do it simpler if just have a circular profile
endif else begin

	xx = findgen(nx)
	yy = findgen(ny)
	x2 = (xx - xcen)^(2.0)
	y2 = (yy - ycen)^(2.0)
	for i = 0L,(ny-1) do $			; row loop
		distsq(*,i) = x2 + y2(i)
endelse

; now account for subpixellation
distsq =  distsq / bin^2.

;----------------------------------------
; interpolate profile and make the image;
;----------------------------------------
w = where(distsq le rmax^2 and distsq ge rmin^2,complement=wbad,goodct, ncomp=badct)
if badct gt 0 then outimg[wbad] = !values.f_nan
dd = sqrt(distsq)

; (1) using 5th-order polynomial in log space,
;     i.e., DN(r) = 10.^(a0 + a1*r + a2*r^2 + a3*r^3 + ...)
if keyword_set(poly) then begin

    DEG = 5
    cc = poly_fit(radx, alog10(rady), DEG, ff)

    if keyword_set(plot) then begin
        plot, ps = 5, radx, alog10(rady), xstyle = 0
        oplot, radx, ff
    endif

    outimg[w] =  1.0
    for i = 0, DEG do $
      outimg[w] = outimg[w] * 10.^(cc(i) * (dd[w])^(float(i)))
    
; (2) using spline interpolation in log space
endif else begin

    rr =  dd[w]
    ss =  sort(rr)
    ff =  10.^spline(radx, alog10(rady), rr(ss))

    if keyword_set(plot) then begin
        nx =  n_elements(radx)
        np =  40
        plot_io, ps = 5, radx(indgen(np)*nx/np), rady(indgen(np)*nx/np), $
          xstyle = 0 
        oplot, rr(ss), ff
    endif

    outimg(w(ss)) =  transpose(ff)   ; dont ask me why - it just works

endelse
if keyword_set(linear) then begin

    rr =  dd[w]
    ss =  sort(rr)
    ff =  10.^spline(radx, alog10(rady), rr(ss))
	outimg = reform( interpol(rady,radx,rr), xsize, ysize)
	
endif


if (bin gt 1) then $
    outimg = rebin(shift(outimg, bin/2, bin/2), xsize, ysize)

end
