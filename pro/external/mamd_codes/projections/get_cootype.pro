function get_cootype, astr

;
; Determine coordinate system from an ASTRON astrometry structure
;
; OUTPUT
;      0 : unknown type
;      1 : celestial
;      2 : galactic
;      3 : ecliptic

ctype1 = strupcase(strmid(astr.ctype(0),0,4))
ctype2 = strupcase(strmid(astr.ctype(1),0,4))

result = 0
if (ctype1 eq 'RA--' and ctype2 eq 'DEC-' ) then result=1
if (ctype1 eq 'GLON' and ctype2 eq 'GLAT' ) then result=2
if (ctype1 eq 'ELON' and ctype2 eq 'ELAT' ) then result=3

if (result eq 0) then print, 'unknown coordinate system ', ctype1, ' ', ctype2

return, result

end
