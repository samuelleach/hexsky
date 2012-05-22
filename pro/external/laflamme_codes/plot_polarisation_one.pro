;----------------------------------------------------------------------
;NAME:
;   PLOT_POLARISATION_ONE
;
;PURPOSE:
;  Will take the information recorded by the bolometer of the
;  polarisation, run it backwards through the grid and the HWP
;  resulting in the incident A_x and A_y of the photon. 
;
;INPUTS:
;  TIMESTREAM - An array of the recorded polarisation temperature for
;               each bolometer in microK. 
;  SCOPE - an anonymous structure which has all of the following:
;     *BOLO_ARRAY  - a 2 by N array giving the offsets of each of
;       the bolometers from the central pointing of the scope,
;       in arcminutes.
;     *FWHM_ARCMIN - the full width half max of your scope's beam.
;  SCAN- an anonymous structure with all the following fields:
;     *RA_DEC - a 2 by N array of the right ascesion and declination of
;       your scope pointing, transformed from azi_alt.
;     *DATA_RATE - the rate at which pointing and lsts are calculated, in Hz.
;     *INTEGRATE_TIME - the total time the scan represents, in seconds.
;    
;OUTPUTS:
;   VEC_FINAL - an array which, for each bolometer, at each time, has
;               the A_x and A_y of the incident photon, in microK.
;
;KEYWORDS:
;  SPEED - Angular Velocity of half wave plate. If not set will
;            default to 4Hz.

;ROUTINES USED:
;   NONE
;------------------------------------------------------------------------------

;FUNCTION plot_polarisation_one, timestream, scope, scan, speed = speed
FUNCTION plot_polarisation_one, timestream, speed = speed


n = n_elements(timestream.polarisation[0,*])
n_bolo = timestream.n_bolo

;PIXEL.PIXEL_X/Y will be the pixel placement of each bolometer at each point in
;the scan, in terms of final map pixel.
;pixel = get_bolo_pixel(timestream, scope, scan, n_pix)

if keyword_set(speed) eq 0 then speed = 6. else speed=speed 

time_steps = findgen(n)* 1./190

print, 'Beginning with HWV speed of: ',strtrim(speed,2), '  Hz'

;PHI gives the angle of the half wave plate at every observation point.
phi = speed*2*!pi*time_steps

transform = fltarr(2,2,n)
phi = phi mod (2*!pi)

;index = fltarr(25, 14508)

print, 'Starting initial for loop'

;for i = 0, 24 do begin

;transform[*,*,i]=[[-1*cos(angs[i])^2+sin(angs[i])^2,-2*cos(angs[i])*sin(angs[i])],$
 ;               [-2*cos(angs[i])*sin(angs[i]), cos(angs[i])^2-sin(angs[i])^2]] 

;Now weve got to split up the time stream so that we have 25 vectors,
;each containing 1/25th of the timestream, corresponding to times when
;the angle of the half wave plate will be the same.

;index[i,*] = findgen(14508)*25 + i 

;endfor
transform[0,0,*]=-1*cos(phi)^2+sin(phi)^2
transform[0,1,*]=-2*cos(phi)*sin(phi)
transform[1,0,*]=-2*cos(phi)*sin(phi)
transform[1,1,*]=cos(phi)^2-sin(phi)^2


vec_initial = fltarr(n,2)
vec_final = fltarr(n,2,n_bolo)

print, 'Beginning Second series of loops:'

for j=long(0), n_bolo-1 do begin

vec_initial[*,1]= timestream.polarisation[j,*]

;for i = 0, 24 do begin

;vec_final[index[i,*],*,j]= transform[*,*,i]##vec_initial[index[i,*],*]

;endfor

;VEC_FINAL is the vector reconstructed after passing backwards
;(through the inverse Jones matrix). I perform the matrix
;multiplication element by element after becoming very frustrated with
;IDL's matrix multiplication ..... :) 
vec_final[*,0,j]= transform[0,0,*]*vec_initial[*,0]+$
                      transform[1,0,*]*vec_initial[*,1]
vec_final[*,1,j]= transform[0,1,*]*vec_initial[*,0]+$
                      transform[1,1,*]*vec_initial[*,1]




if j mod 25 eq 0 then print, 'Finished bolos:', j
endfor

return, vec_final

END
