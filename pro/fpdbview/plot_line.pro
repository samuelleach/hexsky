;-------------------------------------------------------------
;+
; NAME:
;       PLOT_LINE
; PURPOSE:
;       Plot specified line on the current plot device.
; CATEGORY:
; CALLING SEQUENCE:
;       ellipse, length, tilt, x0, y0
; INPUTS:
;       length = length of line (data units).                        in
;	tilt = angle of major axis (deg CCW from X axis, def=0).     in
;       x0, y0 = line center (def=0,0).                              in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEVICE means use device coordinates .
;         /DATA means use data coordinates (default).
;         /NORM means use normalized coordinates.
;         COLOR=c  plot color (scalar or array).
;         LINESTYLE=l  linestyle (scalar or array).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: all parameters may be scalars or arrays.
; MODIFICATION HISTORY:
;	D P Steele, ISR, 27 Oct. 1994: modified from ARCS.PRO by R. Sterner.
;	Department of Physics and Astronomy
;	The University of Calgary
;-
;-------------------------------------------------------------
 
pro plot_line, length, tilt, xx, yy, help=hlp,$
               color=clr, linestyle=lstyl, $
               device=device, data=data, norm=norm

np = n_params(0)
if (np lt 1) or keyword_set(hlp) then begin
;  doc_library,'ellipse'
  print,' Plot specified line on the current plot device.'
  print,' ellipse, length, tilt, x0, y0'
  print,' Keywords:'
  print,'   /DEVICE means use device coordinates .
  print,'   /DATA means use data coordinates (default).
  print,'   /NORM means use normalized coordinates.
  print,'   COLOR=c  plot color (scalar or array).
  print,'   LINESTYLE=l  linestyle (scalar or array).
  print,' Notes: all parameters may be scalars or arrays.'
  return
endif
 
;------  Determine coordinate system  -----
if n_elements(device) eq 0 then device = 0    ; Define flags.
if n_elements(data)   eq 0 then data   = 0
if n_elements(norm)   eq 0 then norm   = 0
if device+data+norm eq 0 then data = 1        ; Default to data.
 
if n_elements(clr) eq 0 then clr = !p.color
if n_elements(lstyl) eq 0 then lstyl = !p.linestyle
 
if np lt 2 then tilt = 0.
if np lt 3 then xx = 0.
if np lt 4 then yy = 0.
 
xx=FLOAT(xx)
yy=FLOAT(yy)
tilt=FLOAT(tilt)
 
nl = n_elements(length)-1		; Array sizes.
nt = n_elements(tilt)-1
nxx = n_elements(xx)-1
nyy = n_elements(yy)-1
nlstyl = n_elements(lstyl)-1
nclr = n_elements(clr)-1
n = nl>nt>nxx>nyy		; Overall max.
 
for i = 0, n do begin   	; loop thru lines.
  li  = length(i<nt)
  ti  = tilt(i<nt)
  xxi = xx(i<nxx)
  yyi = yy(i<nyy)
  clri = clr(i<nclr)
  lstyli = lstyl(i<nlstyl)
  xn=[-li/2.,li/2.]
  yn=[0.,0.]
  if abs(ti) lt 1e30 then begin
      rotate_xy,xn,yn,ti,0,0,x,y,/degrees
      plots, x + xxi, y + yyi, color=clri, linestyle=lstyli, $
             data=data, device=device, norm=norm
  endif
endfor
 
return
 
end
