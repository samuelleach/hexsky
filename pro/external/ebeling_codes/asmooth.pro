PRO	GET_KERNEL,GAUSSIAN,SCALE,ASM_KERNEL,ASM_KRNSIZ,ASM_K_MAX,$
                                   LBG_KERNEL,LBG_KRNSIZ,LBG_K_MAX

	lbg_min_scale = 1/sqrt(2)  ;annulus for local backgrd must never
		                   ;include any part of central pixel
        case gaussian of
        1   : begin
              asm_kernel = mk_kernel(scale) 
              lbg_scale = (3*scale)>lbg_min_scale
              end
        else: begin
              asm_kernel = mk_kernel(scale,/tophat) 
              lbg_scale = scale>lbg_min_scale
              end
        endcase
        lbg_kernel = mk_kernel(lbg_scale,annulus=4./3*lbg_scale)

;       find central kernel value:

        asm_krnsiz = size(asm_kernel)
        lbg_krnsiz = size(lbg_kernel)
        asm_k_max = asm_kernel(floor(asm_krnsiz(1)/2),floor(asm_krnsiz(1)/2)) 
        lbg_k_max = max(lbg_kernel)

; without pixelation this would be k_max = 1./(2*!pi*scale^2)     for Gaussian
;                              and k_max = 1./(!pi*scale^2)       for top-hat 
;                              and k_max = 1./(!pi*(r2^2-r1^2))   for annulus


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
     1: sig = (cts-bkg)/sqrt((ctserr^2+bkgerr^2)>1) 
endcase

return,sig

END

FUNCTION ASMOOTH,IMG,PAR,SIGMAX,TOPHAT=TOPHAT,LOG=LOG,SILENT=SILENT,$
         PLOT=PLOT,SCLMIN=SCLMIN,SCLMAX=SCLMAX,BACKGRD=BACK,BACKERR=BACKERR,$
         SIGTYPE=SIGTYPE
;+
; NAME:
;       ASMOOTH
;
; PURPOSE: Return an adaptively smoothed version of IMAGE; smoothing is by
;       convolution with a circular Gaussian or top-hat kernel. Each pixel in
;       IMAGE is smoothed on its `natural' scale, in the sense that the total
;       number of counts under the kernel (and above the background) is required
;       to exceed a value that is determined by a preset significance. Thus,
;       significant structure is retained at all scales while noise is heavily
;       smoothed. Pixels containing too few counts to meet the signal-to-noise
;       criterion will be smoothed at the largest possible scale.
;
; CALLING SEQUENCE: RESULT = ASMOOTH(IMAGE,PAR[,SIGMAX,/BACKGRD,/BACKERR,
;                            /TOPHAT,/LOG,/SILENT,/PLOT,/SCLMIN,/SCLMAX,/SIGTYPE])
;
; INPUT:
;       IMAGE - image to be smoothed
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
;                   the maximal signal-to-noise ratio of the (background corrected)
;                   signal under the kernel
;
; OPTIONAL KEYWORD INPUT:
;
;       TOPHAT  - if present and non-zero, a circular top-hat kernel is used
;                 in the convolution; default is a Gaussian kernel
;       BACKGRD - array of the same size as IMAGE giving the expected
;                 background counts per pixel; per default ASMOOTH computes
;                 a local background from the image on the scale of the kernel
;                 UNTESTED - USE AT YOUR OWN RISK
;       BACKERR - array of the same size as IMAGE giving the error of the 
;                 expected background counts per pixel. If BACKERR is not
;                 supplied, the error of the background estimate is assumed
;                 to be negligible. Ignored if BACKGRD='local'.
;                 UNTESTED - USE AT YOUR OWN RISK
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
;       PLOT    - if zero, ASMOOTH will not display the raw and smoothed
;                 images
;       SCLMIN  - minimum value (pixels) of the smoothing scale used
;                 by ASMOOTH
;       SCLMAX  - maximum value (pixels) at which the smoothing scales used
;                 by ASMOOTH are truncated
;
; OUTPUT:
;
;       RESULT - IDL structure containing three arrays of the same dimensions 
;                as IMAGE:
;                RESULT.ASM_IM is the adaptively smoothed image
;                RESULT.SIGMAP is a map of the significance of the signal in
;                              each pixel of ASM_IM
;                RESULT.SCLMAP is a map of the smoothing scales (kernel sizes)
;                              used for each pixel. This array can be used as
;                              input (PAR) to, for instance, asmooth different
;                              images on exactly the same scales. 
;
;
; PROCEDURES CALLED:
;       MK_KERNEL, NUM2SIG
;
; METHOD:
;       ASMOOTH goes through the image in an iteration loop, smoothing at
;       ever increasing scales. As soon as the significance of the counts
;       within the smoothing aperture meets the preset conditions, the
;       smoothed values for all affected pixels are copied to the RESULTing
;       adaptively smoothed image. 
;
;       See Ebeling, White, and Rangarajan (MNRAS, 2006) for details of the procedure.
;
; NOTES:
;       The functional form of the kernel used for smoothing is either a
;       Gaussian (default) or a circular top-hat.
;       Convolving the image with the kernel matrix becomes quite time-consuming
;       at large scales: hit `q' at any time to abort ASMOOTH or set SMAX.
;       Uses FFTs to convolve --> VERY slow if image dimensions are not integer powers of 2!
;       Supply EXTERNAL BACKGROUND and associated errors at your own risk - this
;       mode has NOT BEEN WELL TESTED and results may be "unexpected" and/or misleading. 
;
; REFERENCES:
;       If you find this software useful for your work please include a reference to
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
;       Aug 1999:  fixed a bug that caused ASMOOTH to crash with a memory
;                  allocation error (occurred only for large images when
;                  a Gaussian kernel was used)
;	           HE.
;       <Jan 2006: multiple undocumented changes. Identical to most recent 
;                  version of asmooth_fft as used in Ebeling et al (2006)
;-
if n_params() lt 2 then begin
   print,''
   print,'  usage:         RESULT = ASMOOTH(IMAGE,PAR[,SIGMAX,/BACKGRD,'+$
                           '/BACKERR,/TOPHAT,'
   print,'                                  /LOG,/PLOT,/SCLMIN,/SCLMAX,'+$
                           '/SIGTYPE])'
   print,''
   print,'  input:         IMAGE: 2-dimensional array'
   print,'                 PAR  : minimal significance of signal under the'+$
                           ' kernel (scalar)'
   print,'                        or map of smoothing scales to be used (array)'
   print,''
   print,'  opt. keywords: SIGMAX : maximal significance'
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
   print,'                 SCLMIN : minimal scale (pixels) at which ASMOOTH begins'
   print,'                          smoothing'
   print,'                 SCLMAX : maximal scale (pixels) at which ASMOOTH stops'
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
   print,'                         RESULT.SIGMAP is a map of the '+$
                                   'significance of the'
   print,'                                signal in each pixel of ASM_IM'
   print,'                         RESULT.SCLMAP is a map of the smoothing '+$
                                   'scales (kernel'
   print,'                                sizes) used for each pixel. This '+$
                                   'array can be '
   print,'                                used as input (PAR) to, for '+$
                                   'instance, asmooth'
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
psize = size(par)
bsize = size(back)
besize = size(backerr)

if psize(0) gt 0 then par = reform(float(par)) else sigmin = float(par)

if isize(0) ne 2 then begin
   print,''
   print,'   ASMOOTH: IMAGE has to be a two-dimensional array'
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
     total(isize(0:2) eq psize(0:2)) eq 3: sclmap = par                 ;use only if you know what you're doing...
     else                                : begin
                                           print,'  if not scalar, '+$
                                                 'PAR has to have the same '+$
                                                  'dimensions as IMAGE'
                                           return,-1
                                           end
endcase

nx = isize(1)
ny = isize(2)

; BACKGROUND INFO:

; background supplied on input (UNTESTED, USE AT YOUR OWN PERIL)? If not, use local mode (default):

if n_elements(back) gt 0 then begin
   if min(back) lt 0 then begin
      print,' background level has to be >= 0'
      return,-1
   endif
   if n_elements(back) gt 1 then begin
      if bsize(0) ne 2 or bsize(1) ne nx or bsize(2) ne ny then begin
         print,'  if not scalar, BACKGRD has to have the same dimensions as'+$
               ' IMAGE'
         return,-1
      endif
   endif
   bgrdcode = 2             ; most general case: bkgd can be *anything*...
   if max(back) eq 0 then begin
      bgrdcode = 0          ; bkgd explicitly set to zero
   endif else if min(back) eq max(back) then begin
      bgrdcode = 1          ; bkgd is a scalar constant
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
      return,-1
   endif
   if n_elements(backerr) gt 1 then begin
      if besize(0) ne 2 or besize(1) ne nx or besize(2) ne ny then begin
         print,'  if not scalar, BACKERR has to have the same dimensions as'+$
               ' IMAGE'
         return,-1
      endif
   endif
   berrcode = 3             ; most general case: backerr can be *anything*...
   if bgrdcode eq -1 then begin
      print,' ASMOOTH warning: no external BACKGRD supplied --->'+$
            ' keyword input BACKERR will be ignored'
      berrcode = -1
   endif else begin
      if max(backerr) eq 0 then begin
         berrcode = 0          ; bkgd error explicitly set to zero
      endif else if min(backerr) eq max(backerr) then begin
         berrcode = 1          ; bkgd error is a scalar constant
      endif else begin
         tmp = minmax((sqrt(back)-backerr)/ $
         (backerr>min(backerr(where(backerr gt 0)))))
         if tmp(1)-tmp(0) lt 1d-6 then begin
            berrcode = 2      ; bkgd error is sqrt(bkgd)
         endif
      endelse
   endelse
endif else begin
   if bgrdcode ge 0 then begin
      backerr = back-back
      berrcode = 0
   endif else begin
      berrcode = -1
   endelse
endelse
if berrcode ge 0 then backerr = float(backerr)

; overview of background error code values:
;
; berrcode = -1    local mode (default): error is determined from bkg annulus
; berrcode = 0     background error is zero (bkg may or may not be supplied)   UNTESTED, USE AT YOUR OWN PERIL
; berrcode = 1     background error is supplied and is constant                UNTESTED, USE AT YOUR OWN PERIL
; berrcode = 2     background error is supplied and is sqrt(bkg)               UNTESTED, USE AT YOUR OWN PERIL
; berrcode = 3     background error is supplied as an image                    UNTESTED, USE AT YOUR OWN PERIL

case berrcode of
    -1 : backerrtext = 'Poisson error of counts in background annulus'
     0 : backerrtext = '0.'      
     1 : backerrtext = 'const. = '+string(min(backerr),form='(e8.2)') 
     2 : backerrtext = 'square root of background' 
     3 : backerrtext = 'user-supplied map' 
endcase

; SET ALL KINDS OF DEFAULTS:

; defaults are: Gaussian kernel, linear intensity scaling, initial
;               stepsize 0.01, plot raw and asmoothed images, 
;               unlimited smoothing scale, sigtype=1, minimal scale
;               set according to kernel type, maximal scale ~ image size,
;               not silent

if not keyword_set(silent) then silent = 0

; definition of significance ("detection" vs "flux measurement"):

if n_elements(sigtype) eq 0 then sigtype = 1
if sigtype ne 0 then sigtype = 1

; initial stepsize, kernel type, display scaling, plot on/off, min/max. scale:

step0 = 0.01
if n_elements(tophat) gt 0 then gaussian = tophat eq 0   else gaussian = 1
if n_elements(log)    gt 0 then log = log ne 0           else log = 0
if n_elements(plot)   gt 0 then plot = plot ne 0         else plot = 1
if n_elements(sclmax) gt 0 then sclmax = float(sclmax>0) else sclmax = 1.d10
if n_elements(sclmin) eq 0 then begin
   if gaussian then sclmin = 1/sqrt(9*!pi) else sclmin = 1/sqrt(!pi)
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
   if flag eq 1 then print,form='('' initial stepsize            : '',f6.3)',step0
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

; DISPLAY SETTINGS:

if plot then begin
   device,get_screen_size=screen_size
   o_win = !d.window+1
   xs = fix(screen_size(0)/2.5)
   ys = xs*ny/nx
   xp = screen_size(0)/2-xs-10
   yp = screen_size(1)/2-ys/2
   window,o_win,xs=xs,ys=ys,xpos=1280/2-517,ypos=yp,title='original image'
   if log then pzran = minmax(im(where(im gt 0))) else pzran = minmax(im)
   if log then tv,congrid(bytscl(alog10(im>pzran(0)),min=alog10(pzran(0)),$
                  max=alog10(pzran(1))),xs,ys) else $
                tv,congrid(bytscl(im,min=pzran(0),max=pzran(1)),xs,ys)
   s_win = !d.window+1
   xp = screen_size(0)/2+10
   window,s_win,xs=xs,ys=ys,xpos=xp,ypos=yp,title='adaptively smoothed image'
   wset,s_win
endif

; define output arrays: asm_im, sigmap, and sclmap are the
; arrays that, once filled, will be returned at the end:

asm_im = 1.*im-im   ; will hold adaptively smoothed image
sigmap = 1.*im-im   ; will hold map of significance actually attained per pixel

; if map of smoothing scales is supplied, find unique values and
; overwrite sclmap:

if flag lt 0 then begin
   sclmap = sclmap<sclmax
   sval = unique(sclmap,/sort)
   nsval = n_elements(sval) 
   isval = 0
   totcts = im-im    ;irrelevant parameter if sclmap is supplied; set to 0
endif else sclmap = 1.*im-im   ; will hold map of smoothing scales

; define a few more variables and parameters:

mask = replicate(0,nx,ny)   ; flags pixels smoothed so far

terminate = 0
done      = 0               ; number of pixels smoothed so far
step      = step0           ; set step size to initial value
scale     = sclmin - step   ; needed because scale is increased by step
                            ; *before* convolution is performed
n_zero    = 0               ; number of subsequent scales for which no
                            ; pixels met the significance criterion
n_over    = 0               ; flag indicating that the range of significances
                            ; in the last step exceeded sigmax (oversmoothing)

; MAIN LOOP (keeps going until all pixels have been dealt with or run
;            is aborted):

while total(mask) lt nx*ny do begin

;     abort? (check keyboard input for "q")

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
      endif   ; smooth remainder at max scale, exit asmooth

      if flag eq 1 then begin    

;     PAR was scalar, i.e. sigma_min is supplied rather than a map of scales

;        save old values of scale and stepsize, then increase smoothing scale:

         old_scale = scale
         old_step  = step
         scale = sclmin>(scale+step)<sclmax
repeat_step:
         if not silent then $
            print,scale,nocr,form='($,'' current smoothing radius: '',f10.5,a)'

	 get_kernel,gaussian,scale,asm_kernel,asm_krnsiz,asm_k_max,$
                                   lbg_kernel,lbg_krnsiz,lbg_k_max

;        kernel cannot be larger than image:

	 krnsiz = asm_krnsiz
	 if bgrdcode lt 0 then krnsiz = asm_krnsiz>lbg_krnsiz
         if krnsiz(1) gt nx or krnsiz(2) ge ny then begin
            if not silent then $
               print,'     ASMOOTH: kernel cannot be larger than image'
            terminate = 1
         endif

terminate:

         if terminate then begin
            if terminate gt 0 then begin
               if not silent then $
                  print,'              setting kernel size to ~size of image'
               scale = float(nx<ny)
               if gaussian then scale = scale/3
               get_kernel,gaussian,scale,asm_kernel,asm_krnsiz,asm_k_max,$
                                         lbg_kernel,lbg_krnsiz,lbg_k_max
  	       krnsiz = asm_krnsiz
	       if bgrdcode lt 0 then krnsiz = asm_krnsiz>lbg_krnsiz
               if nx ge ny then scale = scale*ny/krnsiz(2) $
                           else scale = scale*nx/krnsiz(1)
               get_kernel,gaussian,scale,asm_kernel,asm_krnsiz,asm_k_max,$
                                         lbg_kernel,lbg_krnsiz,lbg_k_max
  	       krnsiz = asm_krnsiz
	       if bgrdcode lt 0 then krnsiz = asm_krnsiz>lbg_krnsiz
               if krnsiz(1) ge nx or krnsiz(2) ge ny then begin
                  scale = scale*((krnsiz(1)>krnsiz(2))-2)/(krnsiz(1)>krnsiz(2))
                  get_kernel,gaussian,scale,asm_kernel,asm_krnsiz,asm_k_max,$
                                            lbg_kernel,lbg_krnsiz,lbg_k_max
               endif
            endif
            if scale lt old_scale then begin
               scale = old_scale
               get_kernel,gaussian,scale,asm_kernel,asm_krnsiz,asm_k_max,$
                                         lbg_kernel,lbg_krnsiz,lbg_k_max
            endif
            sclmax = scale
         endif

         if scale eq sclmax then begin
            ind = where(mask eq 0, px)
            if not silent then $
               print,'     ASMOOTH: remainder will be smoothed on a scale of'+$
               ' SCLMAX = ',sclmax,' pixels',form='(a,f6.2,a)'
         endif

;        convolve image and kernel(s) unless this has been done before for
;        the present kernel size (happens only for last smoothing scale
;        if at all):

         if scale ne old_scale then begin

; FFT version:
            itmp = im*(1.-mask)
            mtmp =    (1.-mask)
	    if bgrdcode ge 0 then begin
               btmp  = back   *(1.-mask)
               betmp = backerr*(1.-mask)
	    endif

; FFT version: no zero padding, FFT convolution:
            norm_cts = convolve(itmp,asm_kernel) 
            asm_weight = convolve(mtmp,asm_kernel)

;	    back_cts/back_err are the (expected) background and background
;           error (average!) under the kernel - unless bgrdcode is -1 in
;           which case back_cts/back_err are the background and background 
;           error in the background annulus surrounding the kernel:

            case bgrdcode of
	        -1: begin
                    back_cts = convolve(itmp,lbg_kernel)>0
                    lbg_weight = convolve(mtmp,lbg_kernel)
		    end
                 0: back_cts = btmp-btmp
                 1: back_cts = asm_weight*min(back)
                 2: back_cts = convolve(btmp,asm_kernel)
            endcase
            case berrcode of
	        -1: back_err = sqrt(back_cts)
                 0: back_err = betmp-betmp
                 1: back_err = asm_weight*min(backerr)
                 2: back_err = sqrt(back_cts)
                 3: back_err = sqrt(convolve(betmp^2,asm_kernel))
            endcase

;	    norm_cts and back_cts are averages within the respective kernel;
;	    divide by kernel peak value to obtain total counts;
;           then divide by appropriate weight to remove mask effects:
;           (this division also takes care of all edge effects!)

            izero = where(asm_weight eq 0,ct)
            if ct gt 0 then asm_weight(izero) = 1. ;avoid divides by zero...

            totcts = norm_cts/asm_k_max  ;total counts under kernel

;           error must only take into account real events, i.e. totcts
;           before correction for masked pixels occurs:

            ctserr_rel = 1/sqrt(totcts>1)  ;fractional error of totcts

;           now apply mask correction to total counts under kernel:

            totcts = totcts/asm_weight   ;correction for masked pixels

;           use fractional background error computed earlier to get 
;           correct absolute error of expected counts under the kernel:

	       ctserr = totcts*ctserr_rel

;	    bckcts gives the total background counts under the asmooth
;	    kernel; if bgrdcode is -1 this predicted background needs to
;           be derived from the observed total background counts in the 
;           background annulus:

            if bgrdcode eq -1 then begin
               izero = where(lbg_weight eq 0,ct)
               if ct gt 0 then lbg_weight(izero) = 1. ;avoid divides by zero...

;              total counts in background annulus:

               bckcts = back_cts/lbg_k_max ;counts under lbg_kernel
               
;	       error must only take into account real events, i.e. bckcts
;              before correction for masked pixels and before scaling to
;              smoothing kernel size occurs:

	       bckerr_rel = 1/sqrt(bckcts>1)  ;fractional error of bckcts

;	       now apply mask correction to background counts:

               bckcts = bckcts/lbg_weight     ;correction for masked pixels

;              and scale to asmooth kernel:

               bckcts = bckcts*(lbg_k_max/asm_k_max)

;              use fractional background error computed earlier to get 
;              correct absolute error of expected background under the
;              kernel:

	       bckerr = bckcts*bckerr_rel

            endif else begin
               bckcts = back_cts/asm_weight/asm_k_max
               bckerr = back_err/asm_weight/asm_k_max
            endelse

         endif

         if scale ne sclmax then begin

;           find pixels where significance of total counts under the
;           kernel exceed sigmin and guess next scale: 

            sig = num2sig(totcts,ctserr,bckcts,bckerr,sigtype=sigtype)
            ind = where(sig ge sigmin and mask eq 0,px)

            if px gt 0 then begin

;              a non-zero number of pixels are found to have sufficiently
;              signal under the associated kernel, these will be smoothed
;              at the present scale.
 
               n_zero = 0  ; reset counter

               if scale eq sclmin then begin
                  step = step0
               endif else begin
                  sigind = num2sig(totcts(ind),ctserr(ind),bckcts(ind),$
                                   bckerr(ind),sigtype=sigtype)

;                 guess the next scale based on distribution of S/N values
;                 for the pixels just identified as meeting the snr criterion.
;                 if median of snr values is smaller than the average of
;                 sigmin and sigmax, then increase scale; otherwise
;                 decrease it:

                  newscale = ((sigmax+sigmin)/median(sigind)/2*scale) 

;                 for less than 5 values the median is ill defined;
;                 keep current stepsize:

                  if px lt 5 then newscale = scale+step 
                  step = (newscale - scale)

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

                  step = (scale-old_scale)/2

	          if step lt step0 then begin
                     if not silent then begin
                        print,'ASMOOTH: stepsize anomaly (warning)         '
                        print,'         significances for next step may '+$
                              'significantly exceed SIGMAX'
                     endif
                     step = step0
                     n_over = -1
                  endif

                  scale = sclmin>(old_scale+step)<sclmax
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
         if gaussian then asm_kernel = mk_kernel(scale) else $
                          asm_kernel = mk_kernel(scale,/tophat) 

;        find pixels where sclmap equals current scale: 

         ind = where(sclmap eq scale,px)

      endelse

;     if any pixels meet the significance criterion for the present scale
;     (does not apply if map of smoothing scales is supplied), perform
;     convolution just for these pixels and add to asmoothed output
;     image. Also, update mask, scale map and significance maps:

      if px gt 0 then begin

;        create temporary mask and select only those pixels identified by
;        the pointer ind; rest of image is set to zero:

         tmp_mask = mask-mask  
         tmp_mask(ind) = 1.                     
         im_tmp = tmp_mask*im

; FFT version:
         itmp = im_tmp
         mtmp = itmp-itmp+1.

; scales supplied by user? smooth whole image:

         if flag lt 0 then itmp = 1.*im  
 
;        perform convolution for image and mask; edge_truncate actually
;        amounts to zero padding. division of results eliminates all
;        edge effects:

         im_tmp = convolve(itmp,asm_kernel)
         weight = convolve(mtmp,asm_kernel)
         izero = where(weight eq 0,ct)
         if ct gt 0 then weight(izero) = 1
         im_tmp = im_tmp/weight

;        add convolution result to asmoothed output image; also
;        update mask (keeps track of "done" pixels), map of smoothing
;        scales and map of significances:

         case flag of
              1: asm_im = asm_im + im_tmp   ;adaptive smoothing
             -1: asm_im[ind] = im_tmp[ind]  ;smoothing scales user supplied 
         end

         mask(ind) = 1
         sclmap(ind) = scale
         if flag eq 1 then begin
            sigmap(ind) = num2sig(totcts(ind),ctserr(ind),bckcts(ind),$
                                  bckerr(ind),sigtype=sigtype)
         endif else sigmap = im-im   ;irrelavant if sclmap is supplied!

;        write screen log; ratio_1 is the ratio of counts in the pixels
;        from the current asmooth step to those in the same pixels of
;        the unsmoothed image; ratio_2 is the same ratio but for all
;        pixels smoothed so far:

         zmax = max(im(ind))
         ind_done = where(mask eq 1,done)
         im_tmp_tot = total(im_tmp)
         ratio_1 = im_tmp_tot/(total(im(ind))>0.0001)
         ratio_2 = total(asm_im)/total(im(ind_done))
         if not silent then $
            print,form='(f6.2,f11.2,f10.3,2x,2f6.3,f8.2,f10.2,2x,3f6.2)',zmax,$
               min(totcts(ind)),scale,ratio_1,ratio_2,100*float(done)/(nx*ny),$
               100*total(asm_im)/total(im),min(sigmap(ind)),$
               median(sigmap(ind)),max(sigmap(ind))

;        update display:

         if plot then begin
            if log then tv,congrid(bytscl(alog10(asm_im>pzran(0)),$
                   min=alog10(pzran(0)),max=alog10(pzran(1))),xs,ys) else $
                   tv,congrid(bytscl(asm_im,min=pzran(0),max=pzran(1)),xs,ys)
         endif

      endif

endwhile

; finished! update display one last time:

if plot then if log then tv,bytscl(congrid(alog10(asm_im>pzran(0)),xs,ys),$
                         min=alog10(pzran(0)),max=alog10(pzran(1))) $
                    else tv,bytscl(congrid(asm_im,xs,ys),min=pzran(0),$
                         max=pzran(1)) 

; print overall count ratio to allow count conservation to be checked:

if not silent then begin
   print,''
   print,form='('' (total counts in smoothed image)/(total counts in '','$
         +'''original image) = '',f6.4)',total(asm_im)/total(im)
   print,''
endif

; return results as an IDL structure:
;
; asm_im   = adaptively smoothed image
; sigmap   = map of significances
; sclmap   = map of smoothing scales used by ASMOOTH

return,{ASM_IM: asm_im,SIGMAP: sigmap, SCLMAP: sclmap}

end                                                                       
