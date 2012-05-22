function map2hpix, m1, h1, nside, exact=exact, ring=ring, nested=nested
;+
; NAME:
;       MAP2HPIX
;
; PURPOSE:
;       Project a square map m1 (with associated header h1) on a
;       healpix map of a given nside
;
; CALLING SEQUENCE:
;       m2 = map2hpix( m1, h1, nside, [/exact, /ring, /nested] )
;
; INPUTS:
;       m1 : square map to project
;       h1 : header of m1
;       nside : nside of healpix map
;
; KEYWORD PARAMETERS:
;       exact - if this keyword is set, the precession from B1950 to J2000
;               or from J2000 to B1950 is done using BPRECESS or JPRECESS
;               instead of PRECESS. Using the exact keyword slows down
;               significantly MPROJ but the astrometry is more
;               accurate.
;
;       ring - if set, output healpix map will be in RING ordering
;              
;       nested - if set, output healpix map will be in NESTED ordering (default)
;
; OUTPUTS:
;       m2 : projected map
;
; COMMON BLOCKS:
;       none
;
; SIDE EFFECTS:
;       none
;
; RESTRICTIONS:
;       needs ASTRON and HEALPIX libraries
;
; PROCEDURE:
;       get_equinox, extast, sxpar, xy2ad, get_cootype, euler, mprecess, ang2pix_ring, ang2pix_nest
;
; MODIFICATION HISTORY:
;       2 April 2008 - Creation Marc-Antoine Miville-Deschenes
;-

; check ordering
if keyword_set(ring) then ordering = 'RING'
if keyword_set(nested) then ordering = 'NESTED'
if not keyword_set(ordering) then ordering = 'NESTED'

; astrometry of healpix map
equi2 = 2000.
sysco2 = 2   ; we assume Galactic coordinate for the Healpix map

; extract astrometry structure of square map
extast, h1, astr1
equi1 = get_equinox(h1)
sysco1 = get_cootype(astr1)
m1size = size(m1)
nax = m1size(1)
nay = m1size(2)

npix = nside2npix(nside)
;ipix = findgen(npix)
ipix = lindgen(npix)
if (ordering eq 'RING') then begin
    pix2ang_ring, nside, ipix, d2, a2
endif else begin
    pix2ang_nest, nside, ipix, d2, a2
endelse
a2 = a2*180./!pi
d2 = 90.-d2*180/!pi 

if (sysco1 ne sysco2) then begin
    if (sysco2 eq 1 and sysco1 eq 2) then eulertype = 1
    if (sysco2 eq 2 and sysco1 eq 1) then eulertype = 2
    if (sysco2 eq 1 and sysco1 eq 3) then eulertype = 3
    if (sysco2 eq 3 and sysco1 eq 1) then eulertype = 4
    if (sysco2 eq 3 and sysco1 eq 2) then eulertype = 5
    if (sysco2 eq 2 and sysco1 eq 3) then eulertype = 6
    if (sysco2 eq 2) then equi2 = equi1 ; force to arrive in equi1 if galactic coordinates
    if (equi2 eq 1950) then fk4=1 else fk4=0
    euler, a2, d2, select=eulertype, fk4=fk4
endif

; Precess coordinates if TO and FROM map don't have the same equinox
mprecess, a2, d2, equi2, equi1, exact=exact

; find pixel numbers of "FROM" map for each coordinates of the "TO" map 
ad2xy, a2, d2, astr1, x1, y1

;stop

; project each pixel on the sphere
output = fltarr(npix)
ind = where(x1 ge 0 and x1 le nax-1 and y1 ge 0 and y1 le nay-1, nbind)
for i=0L, nbind-1 do begin & $
   result = bilinear(m1, x1(ind(i)), y1(ind(i))) & $
   output(ind(i)) = result(0) & $
endfor

return, output

end
