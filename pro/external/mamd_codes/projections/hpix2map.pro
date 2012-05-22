function hpix2map, m1, h1, h2, exact=exact, ring=ring, nested=nested;, nearest=nearest
;+
; NAME:
;       HPIX2MAP
;
; PURPOSE:
;       Project a Healpix map m1 (with associated header h1) on header
;       h2 using nearest neighbord
;
; CALLING SEQUENCE:
;       m2 = hpixproj( m1, h1, h2, /exact )
;
; INPUTS:
;       m1 : Healpix vector to project
;       h1 : header of m1
;
; KEYWORD PARAMETERS:
;       exact - if this keyword is set, the precession from B1950 to J2000
;               or from J2000 to B1950 is done using BPRECESS or JPRECESS
;               instead of PRECESS. Using the exact keyword slows down
;               significantly MPROJ but the astrometry is more accurate.
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
;       2 June 2006 - Creation Marc-Antoine Miville-Deschenes
;-

if (n_elements(h1) gt 1) then begin
    nside = sxpar(h1, 'NSIDE')
    ordering = strcompress(sxpar(h1, 'ORDERING'), /rem)
    equi1 = get_equinox(h1)
endif else begin
    ordering = 'NESTED'
    nside = sqrt(n_elements(m1)/12.)
endelse
if keyword_set(ring) then ordering = 'RING'
if keyword_set(nested) then ordering = 'NESTED'
if not keyword_set(equi1) then begin
    print, "Equinox of Healpix vector undefined, take J2000"
    equi1 = 2000.
endif
equi2 = get_equinox(h2)

; extract astrometry structure of "TO" headers
extast, h2, astr2

; pixel coordinates map of the "TO" map
xsize = sxpar(h2, 'NAXIS1')
ysize = sxpar(h2, 'NAXIS2')
x2 = findgen(xsize)#replicate(1,ysize)
y2 = replicate(1,xsize)#findgen(ysize)

; sky coordinates map of the "TO" map
xy2ad, x2, y2, astr2, a2, d2

; Transform the sky coordinates of the "TO" map in the coordinate
; system of the "FROM" map (i.e. celestial, ecliptic or galactic)
coordsys = strc(sxpar(h1, 'COORDSYS'))
case coordsys of
    'C' : sysco1 = 1
    'G' : sysco1 = 2
    'E' : sysco1 = 3
    else : sysco1 = 2
endcase
;if not keyword_set(sysco1) then begin
;    sysco1 = 2                  ; assume Galactic system for Healpix map
;    print, "assume Galactic system for Healpix map."
;endif
sysco2 = get_cootype(astr2)
if (sysco1 eq 0 or sysco2 eq 0) then $
  return, -1                    ; abort if unknown coordinate system
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
a2 = a2*!pi/180.
d2 = (90.-d2)*!pi/180.

;stop

; fill result map with closer neighbor
;if keyword_set(nearest) then begin
   if (ordering eq 'RING') then ang2pix_ring, nside, d2, a2, ipix else ang2pix_nest, nside, d2, a2, ipix
   result = reform(m1(ipix), xsize, ysize)
;endif else begin
;   ipix = findgen(nside2npix(nside))
;   if (ordering eq 'RING') then pix2ang_ring, nside, ipix, d1, a1 else pix2ang_nest, nside, ipix, d1, a1
;   a1 = a1*180./!pi
;   d1 = 90.-d1*180./!pi
;   ad2xy, a1, d1, astr2, x1, y1
;   x2 = findgen(xsize)
;   y2 = findgen(ysize)
;   ind = where(x1 ge -2 and x1 le max(x2)+2 and y1 ge -2 and y1 le max(y2)+2)
;   result = krig2d(m1(ind), x1(ind), y1(ind), bounds=[0,0,xsize,ysize], gs=[1,1], expon=[0.25, 0.0])
;endelse


return, result

end
