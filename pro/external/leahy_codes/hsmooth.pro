PRO GET_WIN, GAUSSIAN, SCALE, lmax, ASM_win, ASM_KRNSIZ, var_win, $
    LBG_win, LBG_KRNSIZ, lbg_vwin
;
; calculate beam window function.
; scale is 1-sigma beamwidth in arcmin
;
    am2r = !pi / (180.0*60.0)
    rscale = scale * am2r  ; in radians
        case gaussian of
        1   : begin
              fwhm = SQRT(8.*alog(2.0))*scale
              area = 2.*!pi * rscale^2 ; beam area in sr
              asm_win = gaussbeam(fwhm, lmax)
              var_win = gaussbeam(fwhm/sqrt(2.0), lmax) / (2.*area)
              lbg_scale = 3.*scale
              end
        else: begin
              area = 2*!pi * float(1d0 - cos(rscale)) ; make sure we don't lose precision
              asm_win = ann_window(scale, lmax, /tophat)
              var_win = asm_win / area
              lbg_scale = scale
              end
        endcase
        outer = 4./3.*lbg_scale
        area = 2*!pi * float(cos(lbg_scale*am2r) - cos(outer*am2r))
        lbg_win = ann_window(lbg_scale, lmax, outer=outer)
        lbg_vwin = lbg_win / area

        asm_krnsiz = lbg_scale/60.0  ; convert to degrees
        lbg_krnsiz = outer/60.0


END

FUNCTION NUM2SIG,CTS,CTSERR,BKG,BKGERR,SIGTYPE=TYPE

; sigtype denotes the statistics used to compute the significance:
; if set to 1 (default) both background and source counts will be
;                       considered,
; if set to 0           only background counts enter (this is the
;                       traditional "significance of detection above the
;                       background")

if n_elements(type) eq 0 then type = 1
if type ne 0 then type = 1

;  ctserr may well be sqrt(par) in this case but then again it may not -->
;         don't assume what might be wrong:

case type of
     0: sig = (cts-bkg)/sqrt(bkg)
     1: begin
        err = sqrt(ctserr^2+bkgerr^2)
        zeros = where(err eq 0, nz)
        if nz gt 0 then err[zeros] = 1
        sig = (cts-bkg)/err
     end
endcase

return,sig

END

FUNCTION HSMOOTH,IMG, IMVAR, PAR, SIGMAX, NEST=NEST, TOPHAT=TOPHAT, LOG=LOG, $
                 SILENT=SILENT, PLOT=PLOT,SCLMIN=SCLMIN, SCLMAX=SCLMAX,$
                 BACKGRD=BACK, BACKERR=BACKERR, SIGTYPE=SIGTYPE, NLMAX=NLMAX,$
                 NOKEYBOARD=NOKEYBOARD,OUTPUT_ITER=OUTPUT_ITER
;+
; NAME:
;       HSMOOTH
;
; PURPOSE:
;       Return an adaptively smoothed version of HEALPix map IMAGE;
;       smoothing is by convolution with a circular Gaussian or
;       top-hat kernel. Each pixel in IMAGE is smoothed on its
;       `natural' scale, in the sense that the total number of counts
;       under the kernel (and above the background) is required to
;       exceed a value that is determined by a preset
;       significance. Thus, significant structure is retained at all
;       scales while noise is heavily smoothed. Pixels containing too
;       few counts to meet the signal-to-noise criterion will be
;       smoothed at the largest possible scale.
;
; CALLING SEQUENCE:
;
;       RESULT = HSMOOTH(IMAGE, IMVAR, PAR[, SIGMAX, /NEST, /BACKGRD,/BACKERR,
;                       /TOPHAT,/LOG,/SILENT,/PLOT,/SCLMIN,/SCLMAX,/SIGTYPE,
;                       /NLMAX])
;
; INPUT:
;       IMAGE - image to be smoothed
;       IMVAR - array of the same size as IMAGE giving the variance of the
;               image value.
;       PAR   - if scalar, PAR is taken to be the minimal signal-to-noise ratio
;                  of the (background corrected) signal under the kernel
;               if PAR has the same dimensions as IMAGE, it is interpreted
;                  as a map of smoothing scales for each pixel (see optional
;                  keyword output SCLMAP) - USE THIS OPTION AT YOUR OWN RISK,
;                  STATISTICAL INTERPRETATION OF RESULTS IS NOT OBVIOUS
;
; OPTIONAL INPUT PARAMETERS:
;
;       SIGMAX - if supplied as a third argument, SIGMAX is taken to be
;                   the maximal signal-to-noise ratio of the
;                   (background corrected) signal under the kernel
;
; OPTIONAL KEYWORD INPUT:
;       NEST    - Maps are in nested format, otherwise ring is assumed
;       TOPHAT  - if present and non-zero, a circular top-hat kernel is used
;                 in the convolution; default is a Gaussian kernel
;       BACKGRD - array of the same size as IMAGE giving the expected
;                 background counts per pixel; per default hsmooth computes
;                 a local background from the image on the scale of the kernel
;                 UNTESTED - USE AT YOUR OWN RISK
;       BACKERR - array of the same size as IMAGE giving the error of the
;                 expected background counts per pixel. If BACKERR is not
;                 supplied, the error of the background estimate is assumed
;                 to be negligible. Ignored if BACKGRD='local'.
;                 UNTESTED - USE AT YOUR OWN RISK
;       NLMAX   - maximum multipole for analysis
;       SIGTYPE - if set to 1 (default) the significance of any features
;                 will be computed according to
;
;                 sig = (n_tot-n_bkg)/sqrt(n_tot+err_bkg^2)
;
;                 if set to 0, the significance will be computed as
;
;                 sig = (n_tot-n_bkg)/sqrt(n_bkg)
;
;                 ("significance of detection above the background")
;
;       LOG     - if non-zero, images will be displayed on a logarithmic
;                 scale
;       SILENT  - if set, no output will be printed to the screen
;       PLOT    - if zero, hsmooth will not display the raw and smoothed
;                 images
;       SCLMIN  - minimum value (arcmin) of the smoothing scale used
;                 by hsmooth
;       SCLMAX  - maximum value (arcmin) at which the smoothing scales used
;                 by hsmooth are truncated
;
; OUTPUT:
;
;       RESULT - IDL structure containing three arrays of the same dimensions
;                as IMAGE:
;                RESULT.ASM_IM is the adaptively smoothed image
;                RESULT.ERRMAP is a map of the error in each pixel of ASM_IM
;                RESULT.SCLMAP is a map of the smoothing scales (kernel sizes)
;                              used for each pixel. This array can be used as
;                              input (PAR) to, for instance, hsmooth different
;                              images on exactly the same scales.
;
;
; PROCEDURES CALLED:
;       ANN_WINDOW, NUM2SIG
;
; METHOD:
;       hsmooth goes through the image in an iteration loop, smoothing at
;       ever increasing scales. As soon as the significance of the counts
;       within the smoothing aperture meets the preset conditions, the
;       smoothed values for all affected pixels are copied to the RESULTing
;       adaptively smoothed image.
;
;       See Ebeling, White, and Rangarajan (MNRAS, 2006) for details
;       of the procedure.
;       Adapted for HEALPix and non-poisson data by J. P, Leahy 2008
;
; NOTES:
;       The functional form of the kernel used for smoothing is either a
;       Gaussian (default) or a circular top-hat.
;       Convolving the image with the kernel matrix becomes quite
;       time-consuming at large scales: hit `q' at any time to abort
;       hsmooth or set SMAX.
;       Uses ANAFAST/SYNFAST to convolve.
;       Supply EXTERNAL BACKGROUND and associated errors at your own
;       risk - this mode has NOT BEEN WELL TESTED and results may be
;              "unexpected" and/or misleading.
;
; REFERENCES:
;       If you find this software useful for your work please include
;       a reference to
;
;       Ebeling H., D.A. White, F.V.N. Rangarajan, 2006, MNRAS, 368, 65
;
;       in any resulting publications.
;
; REVISION HISTORY:
;       Written by H. Ebeling, D.A. White and V.J. Rangarajan
;                              Nov 1994, Inst. of Astronomy, Cambridge, UK
;       Feb 1998:  major revision. The input parameter (which used to be the
;                  number of events under the kernel) is now the desired
;                  significance of any signal above the background and under
;                  the kernel; the background is estimated from the image or
;                  can be user-supplied. Added SIGMAP, SCLMAP to output
;                  HE, DAW.
;       Aug 1999:  fixed a bug that caused hsmooth to crash with a memory
;                  allocation error (occurred only for large images when
;                  a Gaussian kernel was used)
;              HE.
;       <Jan 2006: multiple undocumented changes. Identical to most recent
;                  version of hsmooth_fft as used in Ebeling et al (2006)
;       July 2008: Added ability to deal with image variance image, hence no
;                  longer assumes poisson errors. J. P. Leahy (Jodrell Bank)
;                  Cloned version for all-sky (HEALPix) analysis
;-
if n_params() lt 3 then begin
   print,''
   print,'  usage:         RESULT = hsmooth(IMAGE, IMVAR, PAR[,SIGMAX,'+$
                           '/NEST, /BACKGRD,/BACKERR,/TOPHAT,'
   print,'                                  /LOG,/PLOT,/SCLMIN,/SCLMAX,'+$
                           '/SIGTYPE])'
   print,''
   print,'  input:         IMAGE: 2-dimensional array'
   PRINT,'                 IMVAR: 2-d array of variances'
   print,'                 PAR  : minimal significance of signal under the'+$
     ' kernel (scalar)'
   print,'                        or map of smoothing scales to be used (array)'
   print,' optional:       SIGMAX : maximal significance'
   print,''
   print,' opt. keywords:  NEST:    Maps are NESTED order', + $
     ' (otherwise RING is assumed)'
   print,'                 BACKGRD: expected background (per pixel), scalar or'
   print,'                          array of same dimensions as IMAGE'
   print,'                          UNTESTED - USE AT YOUR OWN RISK'
   print,'                 BACKERR: error of expected background (per pixel);'
   print,'                          input is ignored if BACKGRD is not provided'
   print,'                          UNTESTED - USE AT YOUR OWN RISK'
   print,'                 TOPHAT : if set, a circular top hat is used as the kernel;'
   print,'                          the default is a 2d Gaussian'
   print,'                 SILENT : if set, no output will be printed to the screen'
   print,'                 LOG    : if set, image is displayed on log scale'
   print,'                 PLOT   : if set to zero, raw and smoothed images are'
   print,'                          not displayed'
   print,'                 SCLMIN : minimal scale (arcmin) at which hsmooth begins'
   print,'                          smoothing'
   print,'                 SCLMAX : maximal scale (arcmin) at which hsmooth stops'
   print,'                          smoothing'
   print,'                 SIGTYPE: if set to 1 (def) the '+$
                                    'significance of any features'
   print,'                          will be computed according to'
   print,'                             sig = (n_tot-n_bkg)/sqrt(n_tot+'+$
                                    'err_bkg^2)'
   print,'                          if set to 0, the significance will'+$
                                    ' be computed as'
   print,'                             sig = (n_tot-n_bkg)/sqrt(n_bkg)'
   print,'                          ("significance of detection above the'+$
                                    ' background")'
   print,''
   print,' output:         RESULT: IDL structure containing three arrays.'
   print,'                         RESULT.ASM_IM is the adaptively smoothed'+$
                                   ' image'
   print,'                         RESULT.ERRMAP is a map of the '+$
                                   'error in the'
   print,'                                signal in each pixel of ASM_IM'
   print,'                         RESULT.SCLMAP is a map of the smoothing '+$
                                   'scales (kernel'
   print,'                                sizes) used for each pixel. This '+$
                                   'array can be '
   print,'                                used as input (PAR) to, for '+$
                                   'instance, hsmooth'
   print,'                                different images on exactly the '+$
                                   'same scales. '
   return,-1
endif

; VARIOUS BITS CONCERNING SET UP AND CONSISTENCY CHECKS:

; control sequence to suppress carriage return in screen output:

nocr = string("15b)

; make image floating point and remove unused dimensions:

im = reform(float(img))

; check input dimensions for consistency:

isize = size(im)
vsize = size(imvar)
psize = size(par)
bsize = size(back)
besize = size(backerr)

if psize(0) gt 0 then par = reform(float(par)) else sigmin = float(par)

if isize(0) ne 1 then begin
   print,''
   print,'   hsmooth: IMAGE has to be a 1-D HEALPix array'
   print,''
   return,-1
endif

; par must be a scalar or of the same dimensions as img:

flag = -1           ;flags sigmin/sigmax or sclmap mode

case 1 of
     psize(0) eq 0                       : begin
                                           flag = 1
                                           if n_elements(sigmax) eq 0 then $
                                              sigmax = sigmin + 1 $
                                           else sigmax = float(sigmax)
                                           end
                                ; use only if you know what you're doing...
     total(isize[0:1] eq psize[0:1]) eq 3: sclmap = par
     else                                : begin
                                           print,'  if not scalar, '+$
                                                 'PAR has to have the same '+$
                                                  'dimensions as IMAGE'
                                           return,-1
                                           end
endcase

npix = isize[1]
nside = npix2nside(npix)
apix = 4.*!pi / npix
IF nside EQ -1 then begin
    print, 'Input array has wrong number of elements for HEALPix'
    return = -1
endif
lmax = 3L*nside - 1L
if N_Elements(nlmax) ne 0 then lmax = nlmax

; Variance info:

if N_Elements(imvar) eq 0 then begin
    print, 'Variance image must be specified'
    return, -1
endif

if min(imvar) lt 0 then begin
    print, 'Variance image should be >= 0 everywhere'
    return, -1
endif
if vsize[0] NE 1 then begin
    PRINT, 'Variance should be 1-D HEALPix'
    return, -1
endif
if ~ARRAY_EQUAL(isize[0:1],vsize[0:1]) then begin
    PRINT, 'Variance map must be same size as image'
    return, -1
endif

; BACKGROUND INFO:

; background supplied on input (UNTESTED, USE AT YOUR OWN PERIL)?
; If not, use local mode (default):

if n_elements(back) gt 0 then begin
   if n_elements(back) gt 1 then begin
      if bsize(0) ne 1 or bsize(1) ne npix then begin
         print,'  if not scalar, BACKGRD has to have the same dimensions as'+$
               ' IMAGE'
         return,-1
      endif
   endif
   bgrdcode = 2             ; most general case: bkgd can be *anything*...
   if  min(back) eq max(back) then begin
      back = back[0]        ; make scalar
      bgrdcode = 1          ; bkgd is a scalar constant
      if min(back) eq 0 then bgrdcode = 0 ; bkgd is zero
   endif
   back = float(back)
endif else begin
   bgrdcode = -1
endelse

; overview of background code values:
;
; bgrdcode = -1    no background supplied - local mode (default) is used
; bgrdcode = 0     background is supplied and explicitly set to zero   UNTESTED, USE AT YOUR OWN PERIL!
; bgrdcode = 1     background is supplied and is a scalar              UNTESTED, USE AT YOUR OWN PERIL!
; bgrdcode = 2     background is supplied as an image                  UNTESTED, USE AT YOUR OWN PERIL!

case bgrdcode of
    -1 : backtext = 'average of image in annulus around current kernel'
     0 : backtext = '0.'
     1 : backtext = 'const. = '+string(back,form='(e8.2)')  ;scalar
     2 : backtext = 'user-supplied map'         ;array  (bkg map supplied)
endcase

; background error supplied on input (UNTESTED, USE AT YOUR OWN PERIL)? if yes,
; check whether error is sqrt(background) to save one convolution, i.e., CPU
; time

if n_elements(backerr) gt 0 then begin
   if min(backerr) lt 0 then begin
      print,' background error has to be >= 0'
      return, -1
   endif
   if n_elements(backerr) gt 1 then begin
      if besize(0) ne 1 or besize(1) ne npix then begin
         print,'  if not scalar, BACKERR has to have the same dimensions as'+$
               ' IMAGE'
         return,-1
      endif
   endif
   berrcode = 3             ; most general case: backerr can be *anything*...
   if bgrdcode eq -1 then begin
      print,' hsmooth warning: no external BACKGRD supplied --->'+$
            ' keyword input BACKERR will be ignored'
      berrcode = -1
   endif else begin
      if max(backerr) eq 0 then begin
         backerr = 0           ; make scalar
         berrcode = 0          ; bkgd error explicitly set to zero
      endif else if min(backerr) eq max(backerr) then begin
         backerr = backerr[0]  ; make scalar
         berrcode = 1          ; bkgd error is a scalar constant
      endif
   endelse
endif else begin
   if bgrdcode ge 0 then begin
      backerr = back - back ; set to zero
      berrcode = 0
   endif else begin
      berrcode = -2
   endelse
endelse
if berrcode ge 0 then backerr = float(backerr)

; overview of background error code values:
;
; berrcode = -2    local mode (default): error determined from bkg annulus
; berrcode = 0     background error is zero (bkg may or may not be supplied)   UNTESTED, USE AT YOUR OWN PERIL
; berrcode = 1     background error is supplied and is constant                UNTESTED, USE AT YOUR OWN PERIL
; berrcode = 3     background error is supplied as an image                    UNTESTED, USE AT YOUR OWN PERIL

case berrcode of
    -2 : backerrtext = 'Random error of flux in background annulus'
    -1 : backerrtext = 'Poisson error of counts in background annulus'
     0 : backerrtext = '0.'
     1 : backerrtext = 'const. = '+string(min(backerr),form='(e8.2)')
     2 : backerrtext = 'square root of background'
     3 : backerrtext = 'user-supplied map'
endcase

;
; Put maps in RING order as expected by transform programs
;
if KEYWORD_SET(nest) then begin
    print, 'Reordering all input maps from nest to ring...'
    im    = Reorder(im, /N2R)
    imvar = Reorder(imvar, /N2R)
    if bgrdcode eq 2  then back    = Reorder(back, /N2R)
    if berrcode eq 3 then backerr = Reorder(backerr, /N2R)
    if flag eq 0     then sclmap  = Reorder(sclmap, /N2R)
endif

; SET ALL KINDS OF DEFAULTS:

; defaults are: Gaussian kernel, linear intensity scaling, initial
;               stepsize 0.01, plot raw and hsmoothed images,
;               unlimited smoothing scale, sigtype=1, minimal scale
;               set according to kernel type, maximal scale ~ 180 deg
;               background kernel, not silent

if not keyword_set(silent) then silent = 0

; definition of significance ("detection" vs "flux measurement"):

if n_elements(sigtype) eq 0 then sigtype = 1
if sigtype ne 0 then sigtype = 1

; initial stepsize, kernel type, display scaling, plot on/off, min/max. scale:

step0 = 0.01
; Default FWHM(min) = 1 degree = 60 arcmin
if n_elements(tophat) gt 0 then gaussian = tophat eq 0    else gaussian = 1
if n_elements(log)    gt 0 then log = log ne 0            else log = 0
if n_elements(plot)   gt 0 then plot = plot ne 0          else plot = 1
if n_elements(sclmax) gt 0 then sclmax = float(sclmax>0.) $
                           else sclmax = 180.*60.0
if n_elements(sclmin) eq 0 then begin
; ln2 = (FWHM/2)^2/2sigma^2
; sigma^2 = FWHM^2/(8ln2)
   if gaussian then sclmin = 60./Sqrt(8.0*Alog(2.0)) else sclmin = 60.
endif

; ECHO INPUT PARAMETERS AND (DEFAULT) SETTINGS:

if not silent then begin
   if flag eq 1 then begin
      print,sigmin,sigmax,form='(/,'' min, max significance       : '''+$
                               ',f5.2,'', '',f5.2)'
   endif else begin
      print,''
      print,' min, max significance       : undefined; user supplied scale map'
   endelse
   print,' background       (per pixel): '+backtext
   print,' background error (per pixel): '+backerrtext
   print,form='('' range of pixel values (n)   : '',f10.1,'', '',f10.1)',$
         min(im),max(im)
   if flag eq 1 then print, step0, $
     form = '('' initial stepsize            : '',f6.3)'
   print,''
   if gaussian then print,' adaptive kernel is Gaussian' $
               else print,' adaptive kernel is circular top-hat'
   print,''
   print,'                        TYPE "Q" TO EXIT GRACEFULLY...'
   print,''

   print,form='(20x,''smoothing    out/in    pixels    counts     '+$
                    'significance'')'
   print,' n_max   n_krnl_min  radius   diffl cumul  done (%)  done (%)'+$
         '       range    '
   print,form='(63x,''min   med    max'')'
   print,'-----------------------------------------------------------------'+$
         '---------------'
   print,''
endif

if plot then mollview, /ONLINE, im, log=log, title = 'Input image'

; define output arrays: asm_im, sigmap, and sclmap are the
; arrays that, once filled, will be returned at the end:

asm_im = fltarr(npix)   ; will hold adaptively smoothed image
sigmap = asm_im         ; will hold map of variance actually attained per pixel

; if map of smoothing scales is supplied, find unique values and
; overwrite sclmap:

if flag lt 0 then begin
   sclmap = sclmap < sclmax
   sval = unique(sclmap, /sort)
   nsval = n_elements(sval)
   isval = 0
   totcts = 0    ;irrelevant parameter if sclmap is supplied; set to 0
endif else sclmap = asm_im   ; will hold map of smoothing scales

; define a few more variables and parameters:

mask = asm_im   ; flags pixels smoothed so far

terminate = 0
done      = 0               ; number of pixels smoothed so far
step      = step0           ; set step size to initial value
scale     = sclmin/(1 + step)   ; needed because scale is increased by step
                            ; *before* convolution is performed
n_zero    = 0               ; number of subsequent scales for which no
                            ; pixels met the significance criterion
n_over    = 0               ; flag indicating that the range of significances
                            ; in the last step exceeded sigmax (oversmoothing)

; Temporary work files

cl_out = 'cl_out.fits'
map_lm = 'tmp_alm.fits'
msk_lm = 'msk_alm.fits'
var_lm = 'var_lm.fits'

; MAIN LOOP (keeps going until all pixels have been dealt with or run
;            is aborted):

starttime = systime(/julian) ; SL

niter = 0
while total(mask) lt npix do begin
    niter += 1
;     abort? (check keyboard input for "q")

      if (not keyword_set(nokeyboard)) then begin
      key = get_kbrd(0)                     ; read keyboard input (nowait)
      if strupcase(key) eq 'Q' then begin
         print,form='(//," Do you really want to stop smoothing? ",$)'
         reply = get_kbrd(1)
         if strmid(strupcase(reply),0,1) eq 'Y' then begin
            print,form='(/," Enter 1 to smooth remaining pixels with'+$
                        ' largest possible kernel,",/,"       2 to smooth'+$
                        ' remaining pixels with current kernel: ",$)'
            reply = get_kbrd(1)
            print,''
            if reply eq '2' then terminate = -1 else terminate = 1
            goto,terminate
         endif
      endif   ; smooth remainder at max scale, exit hsmooth
      endif

      if flag eq 1 then begin

;     PAR was scalar, i.e. sigma_min is supplied rather than a map of scales

;        save old values of scale and stepsize, then increase smoothing scale:

        old_scale = scale
        old_step  = step
        scale = sclmin > (scale*(1.+step)) < sclmax

repeat_step:
        if not silent then $
            print,scale,nocr, format = $
                "($,' current smoothing radius: ',f10.5,' arcmin',a)"

        get_win, gaussian, scale, lmax, asm_win,asm_krnsiz, var_win, $
                                        lbg_win,lbg_krnsiz, lbg_vwin

;        kernel radius cannot be larger than 180 deg

        krnsiz = asm_krnsiz
        if bgrdcode lt 0 then krnsiz = asm_krnsiz > lbg_krnsiz
        if krnsiz ge 180.0 then begin
            if not silent then $
                print,'     hsmooth: kernel cannot be larger than 180 deg'
            terminate = 1
        endif

terminate:

        if terminate then begin
            if terminate gt 0 then begin
                if not silent then $
                    print,'              setting kernel size to 180 degrees'
                scale = gaussian ? 180d0/4d0 : 3d0*180d0/4d0
                scale *= 60.0
                get_win, gaussian, scale, lmax, asm_win,asm_krnsiz, var_win, $
                                                lbg_win,lbg_krnsiz, lbg_vwin
                krnsiz = asm_krnsiz
                if bgrdcode lt 0 then krnsiz = asm_krnsiz > lbg_krnsiz
                if krnsiz ge 180.0 then begin
                    PRINT, 'Got max scale size wrong:', krnsiz
                    scale = scale*(krnsiz-2)/krnsiz
                    get_win,gaussian,scale, lmax, asm_win,asm_krnsiz, var_win, $
                                             lbg_win,lbg_krnsiz, lbg_vwin
                endif
            endif
            if scale lt old_scale then begin
               scale = old_scale
               get_win, gaussian, scale, lmax, asm_win,asm_krnsiz, var_win, $
                                         lbg_win,lbg_krnsiz, lbg_vwin
            endif
            sclmax = scale
        endif

        if scale eq sclmax then begin
            ind = where(mask eq 0, px)
            if not silent then $
               print,'     hsmooth: remainder will be smoothed on a scale of'+$
               ' SCLMAX = ',sclmax,' pixels',form='(a,f8.2,a)' ; SL
;               ' SCLMAX = ',sclmax,' pixels',form='(a,f6.2,a)'
        endif

;        convolve image and kernel(s) unless this has been done before for
;        the present kernel size (happens only for last smoothing scale
;        if at all):

        if scale ne old_scale then begin

            mtmp = (1.-mask)
            itmp = im*mtmp
            if bgrdcode ge 0 then begin
               btmp  = back   *mtmp
               betmp = backerr*mtmp
            endif
            vtmp = imvar*mtmp

            ianafast, itmp, '!'+cl_out, alm1_out=map_lm, /ring, nlmax=lmax, /cxx, /double ; SL
            ianafast, mtmp, '!'+cl_out, alm1_out=msk_lm, /ring, nlmax=lmax, /cxx, /double ; SL
            ianafast, vtmp, '!'+cl_out, alm1_out=var_lm, /ring, nlmax=lmax, /cxx, /double ; SL
            isynfast, 0, norm_cts,   alm_in=map_lm, beam=asm_win, nside=nside, $
                /apply_windows, nlmax=lmax, simul_type=1, /double ; SL
            isynfast, 0, asm_weight, alm_in=msk_lm, beam=asm_win, nside=nside, $
                /apply_windows, nlmax=lmax, simul_type=1, /double ; SL
            isynfast, 0, norm_var,   alm_in=var_lm, beam=var_win, nside=nside, $
                /apply_windows, nlmax=lmax, simul_type=1, /double ; SL

;       back_cts/back_err are the (expected) background and background
;           error (average!) under the kernel - unless bgrdcode is -1 in
;           which case back_cts/back_err are the background and background
;           error in the background annulus surrounding the kernel:

            case bgrdcode of
                -1: begin
                    isynfast, 0, back_cts,   alm_in=map_lm, beam=lbg_win, $
                         nside=nside, /apply_windows, nlmax=lmax, simul_type=1, /double ; SL
                    back_cts >= 0.0
                    isynfast, 0, lbg_weight, alm_in=msk_lm, beam=lbg_win, $
                         nside=nside, /apply_windows, nlmax=lmax, simul_type=1, /double ; SL
                end
                0: back_cts = btmp-btmp
                1: back_cts = asm_weight*min(back)
                2: begin
                    ismoothing, btmp, back_cts, beam=asm_win, /ring, nlmax=lmax, simul_type=1, /double ; SL;, /silent
                    btmp = 0. ; SL
                end
            endcase
            case berrcode of
                -2: begin
                    isynfast, 0, back_err, alm_in=var_lm, beam=lbg_vwin, $
                       nside=nside, /apply_windows, nlmax=lmax, simul_type=1, /double ; SL
                    back_err = sqrt(apix*back_err)
                end
                -1: back_err = sqrt(back_cts)
                0: back_err = betmp-betmp
                1: back_err = asm_weight*min(backerr)
                2: back_err = sqrt(back_cts)
                3: begin
                    ismoothing, betmp, back_err, beam=var_win, /ring, nlmax=lmax, simul_type=1, /double ; SL;, /silent
                    back_err = sqrt(apix*back_err)
                    betmp = 0. ; SL
                end
            endcase

;       norm_cts and back_cts are averages within the respective kernel;
;       divide by kernel peak value to obtain total counts;
;           then divide by appropriate weight to remove mask effects:
;           (this division also takes care of all edge effects!)

            izero = where(asm_weight eq 0,ct)
            if ct gt 0 then asm_weight(izero) = 1. ;avoid divides by zero...

            ctserr = sqrt(apix*norm_var) / asm_weight
            norm_var = 0. ; SL
            totcts = norm_cts / asm_weight
            norm_cts = 0. ; SL

;       bckcts gives the total background counts under the hsmooth
;       kernel; if bgrdcode is -1 this predicted background needs to
;           be derived from the observed total background counts in the
;           background annulus:

            if bgrdcode eq -1 then begin
                                ;avoid divides by zero...
                izero = where(lbg_weight eq 0,ct)
                if ct gt 0 then lbg_weight(izero) = 1.

                bckcts = back_cts/lbg_weight
                bckerr = back_err/lbg_weight
            endif else begin
                bckcts /= asm_weight
                bckerr /= asm_weight
            endelse
            back_cts   = 0. ; SL
            back_err   = 0. ; SL
            lbg_weight = 0. ; SL
            asm_weight = 0. ; SL
        endif

        if scale ne sclmax then begin

;           find pixels where significance of total counts under the
;           kernel exceed sigmin and guess next scale:

            sig = num2sig(totcts,ctserr,bckcts,bckerr,sigtype=sigtype)
            ctserr = 0. ; SL
            bckerr = 0. ; SL
            ind = where(sig ge sigmin and mask eq 0,px)

            if px gt 0 then begin

;              a non-zero number of pixels are found to have sufficiently
;              signal under the associated kernel, these will be smoothed
;              at the present scale.

               n_zero = 0  ; reset counter

               if scale eq sclmin then begin
                  step = step0
               endif else begin
                  sigind = sig[ind] ; why not?

;                  sigind = num2sig(totcts(ind),ctserr(ind),bckcts(ind),$
;                                   bckerr(ind),sigtype=sigtype)

;                 guess the next scale based on distribution of S/N values
;                 for the pixels just identified as meeting the snr criterion.
;                 if median of snr values is smaller than the average of
;                 sigmin and sigmax, then increase scale; otherwise
;                 decrease it:

                  newscale = ((sigmax+sigmin)/median(sigind)/2*scale)

;                 for less than 5 values the median is ill defined;
;                 keep current stepsize:

                  if px lt 5 then newscale = scale*(1.+step)
                  step = (newscale/scale)-1.0

               endelse

            endif else begin

               n_zero = n_zero + 1
               if n_zero ge 3 then begin

;                 if no pixels met the criterion three times in a row,
;                 double step size to save time:

                  step = 2*step

               endif

            endelse

;           if the median of the S/N values for this scale is larger
;           than the average of sigmin and sigmax, oversmoothing is
;           significant --> step size is negative

            if step lt 0 then begin

                if n_over ge 0 then begin

;                 decrease scale and do again:

;                 stepsize was too big; set scale to midpoint between previous
;                 and current scale (unless stepsize is already ridiculously
;                 small):

                    n_over = 1

                    step = ((scale/old_scale) - 1.0)/2

                    if step lt step0 then begin
                        if not silent then begin
                            print,'hsmooth: stepsize anomaly (warning)         '
                            print,'         significances for next step may '+$
                                  'significantly exceed SIGMAX'
                        endif
                        step = step0
                        n_over = -1
                    endif

                    scale = sclmin>(old_scale*(1+step))<sclmax
                    goto,repeat_step

                endif else begin

                    n_over = 0
                    step = step0

                endelse

            endif

;           reset n_over if previous iteration reset step to step0:

            if n_over lt 0 then n_over = 0

        endif

      endif else begin

;     PAR was array, i.e. map of scales is supplied rather than sigmin:

;        step through vector of unique smoothing scale values:

        scale = sval(isval)<sclmax
        isval = isval + 1
        GET_WIN, GAUSSIAN, SCALE, lmax, ASM_win, ASM_KRNSIZ, var_win, $
            LBG_win, LBG_KRNSIZ, lbg_vwin
;        find pixels where sclmap equals current scale:

         ind = where(sclmap eq scale,px)

      endelse

;     if any pixels meet the significance criterion for the present scale
;     (does not apply if map of smoothing scales is supplied), perform
;     convolution just for these pixels and add to hsmoothed output
;     image. Also, update mask, scale map and significance maps:

      if px gt 0 then begin

;        create temporary mask and select only those pixels identified by
;        the pointer ind; rest of image is set to zero, Re-using old arrays
;        to save space.

         mtmp = fltarr(npix)
         mtmp[ind] = 1.
         vtmp = mtmp*im
;         im_tmp_tot = total(vtmp)
         im_tmp_tot = total(vtmp,/double) ; SL

;        perform convolution for image and mask; edge_truncate actually
;        amounts to zero padding. division of results eliminates all
;        edge effects:

         ismoothing, vtmp, itmp, beam=asm_win, /ring, simul_type=1, /double ; SL;, /silent

;        add convolution result to hsmoothed output image
         asm_im += itmp   ;adaptive smoothing
;
;        ditto for variance
;
         vtmp = mtmp * imvar
         mtmp = 0. ;SL
         ismoothing, vtmp, itmp, beam=var_win, /ring, simul_type=1, /double ; SL;, /silent
         sigmap += itmp
         itmp = 0. ;SL
         vtmp = 0. ;SL

;        update mask (keeps track of "done" pixels), map of smoothing
;        scales and map of significances:

         mask[ind] = 1
         sclmap[ind] = scale

;        write screen log; ratio_1 is the ratio of counts in the pixels
;        from the current hsmooth step to those in the same pixels of
;        the unsmoothed image; ratio_2 is the same ratio but for all
;        pixels smoothed so far:

         zmax = max(im[ind])
         ind_done = where(mask eq 1, done)
;         ratio_1 = im_tmp_tot/(total(im[ind])>0.0001)
;         ratio_2 = total(asm_im)/total(im[ind_done])
         ratio_1 = im_tmp_tot/(total(im[ind],/double)>0.0001) ; SL
         ratio_2 = total(asm_im,/double)/total(im[ind_done],/double) ; SL
         if not silent then $
            print,form='(f6.2,f11.2,f10.3,2x,2f6.3,f8.2,f10.2,2x,3f6.2)',zmax,$
               min(totcts[ind]),scale,ratio_1,ratio_2,100*float(done)/npix,$
               100*total(asm_im,/double)/total(im,/double),min(sigmap[ind]),$ ; SL
               median(sigmap[ind]),max(sigmap[ind])
         totcts = 0. ; SL
         
;        update display:

         if plot then begin
            if niter GT 1 then wdelete
            mollview, asm_im, LOG=log, title = 'HSMOOTH image so far, at iteration '+strtrim(niter,2)
         endif

         if(keyword_set(output_iter)) then begin
            write_fits_map,'hsmooth_iter'+strtrim(niter,2)+'.fits',asm_im,order='RING'
         endif

      endif

endwhile

endtime = systime(/julian) ; SL

message,'Total time for Hsmooth [min] = '+strtrim((endtime-starttime)*24.*60,2),/cont ; SL

; finished! update display one last time:

if plot then begin
    wdelete
    mollview, asm_im, LOG=log, title = 'Final HSMOOTH image'
endif
; print overall count ratio to allow count conservation to be checked:

if not silent then begin
   print,''
   print,form='('' (total counts in smoothed image)/(total counts in '','$
         +'''original image) = '',f6.4)',total(asm_im,/double)/total(im,/double) ; SL
   print,''
endif

; return results as an IDL structure:
;
; asm_im   = adaptively smoothed image
; sigmap   = map of pixel errors
; sclmap   = map of smoothing scales used by hsmooth

return, {ASM_IM: asm_im,SIGMAP: sqrt(sigmap*apix), SCLMAP: sclmap}

end
