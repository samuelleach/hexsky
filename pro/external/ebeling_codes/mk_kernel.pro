function mk_kernel,scale,tophat=tophat,annulus=rout,box=box,invert=invert
;
; returns kernel for e.g. convolution;
;
;  default              --> Gaussian;         scale is the standard deviation
;  tophat=1             --> circular top-hat; scale is the radius of the circle
;  annulus=outer_radius --> annulus; scale is the inner radius of the annulus
;  box=1                --> square box; scale is the length of a side
;

if n_params() eq 0 then begin
   print,' '
   print,'  usage:   result = mk_kernel(scale[,/tophat,/annulus,/box,/invert])'
   print,'           default: Gaussian, scale = sigma'
   print,'           tophat : circular top-hat, scale = radius'
   print,'           annulus: annulus, scale = inner, outer radius'
   print,'           box: square box, scale = length of side'
   print,'           invert: if set, mk_kernel returns an inverted kernel'
   print,' '
   return,-1
endif

scale = scale + 0.d0                      ; make double precision

type = 0         ; Gaussian
if n_elements(tophat) ne 0 then if tophat then type = 1      ; circular tophat
if n_elements(rout) ne 0 then type = 2 else rout = scale + 1 ; annulus
if n_elements(box) ne 0 then if box then type = 3            ; square box

if scale ge rout then begin
   print,' MK_KERNEL: outer radius of annulus must be larger than inner radius'
   return,-1
endif   

case type of
0: begin
   odim = round(6*scale)>5                ; kernel goes out to 3*sigma (radius)
					  ; minimal size is 5 pixels
   if odim mod 2 eq 0 then odim = odim+1  ; make odim odd
   ndim = odim
   while ndim lt 100 do ndim = 3*ndim
   fac = ndim/odim
   x = lindgen(ndim^2.) mod ndim
   y = fix(lindgen(ndim^2.)/ndim)
   x0 = (ndim-1)/2.
   y0 = (ndim-1)/2.
   rdist = shift(dist(ndim),x0,x0)
   kernel = 1/(2*!pi*(fac*scale)^2)*exp(-(rdist^2)/(2*(fac*scale)^2))
   end       
1: begin
   odim = round(2*scale)>5                ; kernel size is 2*radius
					  ; minimal size is 5 pixels
   if odim mod 2 eq 0 then odim = odim+1  ; make odim odd
   ndim = odim
   while ndim lt 100 do ndim = 3*ndim
   fac = ndim/odim
   x = lindgen(ndim^2.) mod ndim
   y = fix(lindgen(ndim^2.)/ndim)
   x0 = (ndim-1)/2.
   y0 = (ndim-1)/2.
   ind = where(sqrt((x-x0)^2+(y-y0)^2) le fac*scale)
   kernel = replicate(0.d0,ndim,ndim)
   kernel(ind) = 1.d0
   end
2: begin
   odim = round(2*rout)>5                 ; kernel size is 2*(outer radius)
					  ; minimal size is 5 pixels
   if odim mod 2 eq 0 then odim = odim+1  ; make odim odd
   ndim = odim
   while ndim lt 100 do ndim = 3*ndim
   fac = ndim/odim
   x = lindgen(ndim^2.) mod ndim
   y = fix(lindgen(ndim^2.)/ndim)
   x0 = (ndim-1)/2.
   y0 = (ndim-1)/2.
   ind = where(sqrt((x-x0)^2+(y-y0)^2) ge fac*scale and $
               sqrt((x-x0)^2+(y-y0)^2) le fac*rout)
   kernel = replicate(0.d0,ndim,ndim)
   kernel(ind) = 1.d0
   end
3: begin
   fac = 1
   ndim = round(scale)
   kernel = replicate(0.d0,ndim+2,ndim+2)
   kernel[1:ndim,1:ndim] = 1.
   end
endcase

if fac gt 1 then kernel = rebin(kernel,odim,odim)

;if keyword_set(invert) then kernel = -kernel+2*total(abs(kernel))/odim/odim
if keyword_set(invert) then kernel = max(kernel)-kernel
kernel = kernel/total(kernel)

return,kernel

end

