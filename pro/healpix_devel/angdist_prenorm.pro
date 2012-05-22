; -----------------------------------------------------------------------------
;
;  Copyright (C) 1997-2008  Krzysztof M. Gorski, Eric Hivon, Anthony J. Banday
;
;
;
;
;
;  This file is part of HEALPix.
;
;  HEALPix is free software; you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation; either version 2 of the License, or
;  (at your option) any later version.
;
;  HEALPix is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with HEALPix; if not, write to the Free Software
;  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;
;  For more information about HEALPix see http://healpix.jpl.nasa.gov
;
; -----------------------------------------------------------------------------
pro angdist_prenorm, v1, v2, dist

;+
; angdist, v1, v2, dist
; computes the angular distance dist (in rad) between 2 vectors v1 and v2
; in general dist = acos ( v1 . v2 )
; except if the 2 vectors are almost aligned.
;
;
; HISTORY : Oct 2003,
;    EH, corrected bug on scalar product boundary
;
;-

if (n_params() ne 3) then begin
    print,'Syntax : ANGDIST, vec1, vec2, angular_dist'
    return
endif

;; normalize both vectors
;r1 = v1 / sqrt(total(v1*v1))
;r2 = v2 / sqrt(total(v2*v2))

r1 = v1 
r2 = v2 


; scalar product
sprod = total(v1*v2)


; case (abs(sprod) lt 0.999d0) of
;     1: begin
;         dist = acos( sprod )
;     end
;     0: begin
;         case (sprod gt 0.999d0) of
;             1: begin
;                 ; almost colinear vectors
;                 vdiff = r1 - r2
;                 diff = sqrt(total(vdiff*vdiff)) ; norm of difference
;                 dist = 2.0d0 * asin(diff * 0.5d0)
;             end
;             0: begin
;                 ; almost anti-colinear vectors
;                 vdiff = r1 + r2
;                 diff = sqrt(total(vdiff*vdiff)) ; norm of sum
;                 dist = !DPI - 2.0d0 * asin(diff * 0.5d0)
;             end
;         endcase
;     endcase

if(abs(sprod) lt 0.999d0) then begin
; other cases
    dist = acos( sprod )
endif else if (sprod > 0.999d0) then begin
; almost colinear vectors
    vdiff = r1 - r2
    diff = sqrt(total(vdiff*vdiff)) ; norm of difference
    dist = 2.0d0 * asin(diff * 0.5d0)

endif else begin ;if (sprod < (-0.999d0)) then begin
; almost anti-colinear vectors
    vdiff = r1 + r2
    diff = sqrt(total(vdiff*vdiff)) ; norm of sum
    dist = !DPI - 2.0d0 * asin(diff * 0.5d0)
endelse

; endif else begin
; ; other cases
;     dist = acos( sprod )
; endelse

return
end


