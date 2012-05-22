;+
; NAME:
;     DIPOLE
;
; PURPOSE:
;     To calculate the expected CMB dipole signal for a given scan
;
; CALLING SEQUENCE:
;     DIPOLE, ra, dec, signal
;
; INPUTS:
;     ra, dec:
;	   Vectors of RA (hours) and dec (degrees) for the given scan
;
; OUTPUTS
;     signal:
;	   A vector containing the dipole signal in K for the given scan 
;
; EXAMPLE:
;     Calculate the expected CMB dipole signal for the set of
;     coordinates in the vectors 'ra' and 'dec', and store the result
;     in the vector 'dipole':
;
;     IDL> DIPOLE, ra, dec, dipole
;
; REFERENCES:
;	Lineweaver et al., 1996, astro-ph/9601151, for the dipole best
;	fit from the 4 year COBE data
;
; MODIFICATION HISTORY:
;	Created, Amedeo Balbi, June 1998
;-	 
pro DIPOLE, ra, dec, signal

pi = 3.1415926535
ra_r = ra/12.*pi                ; hours   ------> radians
dec_r = dec*!dtor               ; degrees ------> radians
ra_d = 167.99*!dtor             ; RA (J2000) of dipole direction (radians)
dec_d = -7.22*!dtor             ; dec (J2000) of dipole direction (radians)
s = 3.358e-3                    ; dipole intensity (kelvin) 

; dipole direction

x_d = sin(ra_d)*cos(dec_d)
y_d = cos(ra_d)*cos(dec_d)
z_d = sin(dec_d)

; scan direction

x   = sin(ra_r)*cos(dec_r)
y   = cos(ra_r)*cos(dec_r)
z   = sin(dec_r)

; the signal is modulated by a simple dot product...

signal = s * ( x_d*x + y_d*y + z_d*z )

return
end
