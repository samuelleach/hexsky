pro apply_pixel_offset_scan, az_bs0, el_bs0, $
                         xoff0, yoff0, $
                         az_out, el_out
 ;; 
; APPLY_PIXEL_OFFSET_SINGLE
;   The purpose of this program is to apply the "pixel offsets" to the
;   boresight pointing.  The pixel offsets are the "on-sky" pointing
;   offsets of the various detectors relative to boresight.  They are
;   defined in the coordinate with boresight at (0,0) and two
;   perpindicular great circles emanating from this point.  This is
;   equivalent to the spherical coordinate system with boresight
;   rotated to (0,0).
;
; INPUTS
;   AZ_BS - the boresight azimuth.  Has dimension [nsamples].
;   EL_BS - the boresight elevation.  Has dimension [nsamples].
;   XOFF -  horizontal pixel offset
;   YOFF - vertical pixel offsets
;
; OUTPUTS
;   AZ_OUT - an array of azimuth positions.  Has
;            dimension [nsamples].
;   EL_OUT - an array of elevation positions.  Has
;            dimension [nsamples].
;
; KEYWORDS
; 
; CALLING SEQUENCE
; e.g., 
; IDL> apply_pixel_offset_single,
;      data.antenna0.track_actual[*,0], data.antenna0.track_actual[*,1],
;      xoff, yoff, az_out, el_out
;
; TO DO
;  
; Created 17 Apr, 2008, by RK.
; Mod: 14 May, 2008 by CR
;
;; 

; check the inputs
if n_elements(az_bs0) ne n_elements(el_bs0) then begin
    print,'There is a problem with the boresight position.'
    print,'Quitting!'
    return
endif

if n_elements(xoff0) ne n_elements(yoff0)  then begin
    print,'There is a problem with the pixel offsets.'
    print,'Quitting!'
    return
endif

nsamples = n_elements(az_bs0)
nbolos = n_elements(xoff0)

az_bs = (az_bs0*!dtor) # (fltarr(nbolos)+1.)
el_bs = (el_bs0*!dtor) # (fltarr(nbolos)+1.)
xoff = (fltarr(nsamples)+1.) # (xoff0*!dtor)
yoff = (fltarr(nsamples)+1.) # (yoff0*!dtor)

;stop
; first try the very direct approach, where you create [nsamples,
; nbolos] matrices for AZ_BS, EL_BS, XOFF, and YOFF.  Oh, but wait,
; this will require the same amount of memory as 4X the bolometer data
; (which itself is [nsamples, nbolos]).  

; So we don't want to do this and I think we must resort to a FOR loop
; over the bolometers.  However, we can do some precalculating:

;sin_az_bs = sin(az_bs)
;cos_az_bs = cos(az_bs*!dtor)
;tan_az_bs = sin_az_bs/cos_az_bs

;sin_el_bs = sin(el_bs*!dtor)
;cos_el_bs = cos(el_bs*!dtor)
;tan_el_bs = sin_el_bs/cos_el_bs

;sin_az_in = sin(xoff*!dtor)
;cos_az_in = cos(xoff*!dtor)
;tan_az_in = sin_az_in / cos_az_in

;sin_el_in = sin(yoff*!dtor)
;cos_el_in = cos(yoff*!dtor)
;tan_el_in = sin_el_in / cos_el_in

; create the output arrays
;az_out = fltarr(nsamples,nbolos)
;el_out = fltarr(nsamples,nbolos)

; loop over the bolometers
; These equations represent:
; 1) change offsets into cartesian coordinates
; 2) rotate by el around y axis, rotate by az about z axis
; 3) go back into az/el coordinates (from cartesians to polars)

el_out = (!pi/2 - acos( $
            sin(el_bs)*cos(yoff)*cos(xoff) $
            + cos(el_bs)*sin(yoff) $
                         ))

az_out = -atan( $
            ( $
            - sin(az_bs)*cos(el_bs)*cos(xoff) $
            - cos(az_bs)*sin(xoff) $
            + sin(az_bs)*sin(el_bs)*tan(yoff) $
            ) $
            / $
            ( $
            cos(az_bs)*cos(el_bs)*cos(xoff) $
            - sin(az_bs)*sin(xoff) $
            - cos(az_bs)*sin(el_bs)*tan(yoff) $
            ) $
                 )

;stop

mm = 15./18.*!pi
; ATAN only outputs from (-90, 90), so you need to account for that.
wh_problem = where(abs(az_bs-az_out) gt mm, nproblem)
if nproblem gt 0 then $
   az_out[wh_problem] = az_out[wh_problem] + !pi

; repeat this process, which takes of the case where AZ_BS is greater
; than 360.
wh_problem = where(abs(az_bs-az_out[*]) gt mm, nproblem)
if nproblem gt 0 then $
   az_out[wh_problem] = az_out[wh_problem] + !pi

az_out=az_out/!dtor
el_out=el_out/!dtor
end


