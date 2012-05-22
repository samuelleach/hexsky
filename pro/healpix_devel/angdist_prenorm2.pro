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
pro angdist_prenorm2, v1, v2, dist

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

;norm1 = sqrt(total(v1*v1,2))
;norm2 = sqrt(total(v2*v2,2))
;r1 = v1/norm1
;r2 = v2/norm2

; angdist_prenorm, v[i,*], vj[i,*], dd

; scalar product
;sprod = total(r1*r2,2)

;help,r1,r2,r3,v1,v2,norm1,norm2
r1 = v1
r2 = v2
r3 = r1*r2
sprod = total(r3,2)

index1 = where(abs(sprod) lt 0.999d0)
index2 = where(sprod gt 0.999d0)
index3 = where(sprod lt -0.999d0)


dist = sprod*0.0d0
if(index1[0] ne -1) then begin
    dist[index1] = acos( sprod[index1] )
endif

if(index2[0] ne -1) then begin
; almost colinear vectors
;    vdiff = r1 - r2
    vdiff = r1[index2,*] - r2[index2,*]
    diff = sqrt(total(vdiff*vdiff,2)) ; norm of difference
    dist[index2] = 2.0d0 * asin(diff * 0.5d0)
endif

if(index3[0] ne -1) then begin
; almost anti-colinear vectors
;    vdiff = r1 + r2
    vdiff = r1[index3,*] + r2[index3,*]
    diff = sqrt(total(vdiff*vdiff,2)) ; norm of difference
    dist[index3] = !DPI - 2.0d0 * asin(diff * 0.5d0)
endif


return
end


