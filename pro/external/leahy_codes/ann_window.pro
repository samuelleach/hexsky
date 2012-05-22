FUNCTION lambda, x
;
; Kernel for integrating spherical harmonic
;
COMMON LVAL, ll
RETURN,legendre(x, ll)
END

FUNCTION ann_window, scale, lmax, TOPHAT = tophat, outer = outer
;
; Returns C_l window function for an annulus or top-hat distribution
;
COMMON LVAL, ll

am2r = !dpi / (180d * 60d) ; arcmin to radians
nocr = string("15b)

if Keyword_set(tophat) then begin
    in = 0.0
    out = scale*am2r
endif else begin
    in = scale*am2r
    out = outer*am2r
endelse

window = fltarr(lmax+1)
c1 = cos(in)
c2 = cos(out)
test = fltarr(2)
wmax = c1 - c2
prev = wmax
for i=0,lmax do begin
    ll = i
;
;   Integrate legendre polynomial over annulus
;   should be possible to speed this up a lot by efficiently evaluating
;   polynomial at many x values at once.
;
    eps = ABS(wmax/prev)*1e-6
;    print,c2,c1,ll
;    window[i] = qromb('lambda', c2, c1, eps=eps)
;    window[i] = qromb('lambda', c2, c1, eps=eps,jmax=22) ; Default jmax is 20
;    window[i] = qromb('lambda', c2, c1, eps=eps,jmax=24) ; SL: jmax needs increasing for large sigmax ? 
;    print,window[i],c2,c1,eps,ll

;    print,c2,c1
    window[i] = qpint1d('lambda', c2, c1) ; SL trial ; Defaults to epsrel = 1e-6

;    print,window[i]
;    qsimp,'lambda', c2, c1, SS, eps=eps, max_iter=24 ; SL
;    window[i] = ss                                   ; SL
    
    prev = window[i]
;
;  Brute force evaluation.
;    for j = 0,1 do begin
;        nval = (j+1)*100
;        dx = (c1-c2)/nval
;        xa = c2 + dx*findgen(nval)
;        test[j] = TOTAL(legendre(xa,i))*dx
;    endfor
;    diff = test[0]-test[1]
;    if ABS(diff) gt eps THEN Print, 'ell=',i,' error =', diff
endfor

RETURN, window / window[0]
; * (2.0 * !pi)
; * sqrt(!pi*(2L*lindgen(lmax+1)+1L))

END
