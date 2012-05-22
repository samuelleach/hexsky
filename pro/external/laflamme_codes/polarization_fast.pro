;---------------------------------------------------------------------
;PURPOSE
;   Takes information of a photon and gives back what the bolometer
;   would record on the other side of a spinning HWP and fixed
;   polarimeter grid. 
;
;INPUTS:
;   Q/U/T - arrays of stokes parameter (in truth the sqrt of the
;           parameters, such that the units are microKelvin. If the
;           units are already microK ^2 just comment out the squaring)
;                                 ;
;  N - number of samples
;  N_BOLO - number of bolometers
;   
;KEYWORDS:
;    SPEED - Angular Velocity of half wave plate. If not set will
;            default to 4Hz.
;OUTPUT:
;   POLAR - A vector containing the perceived signal of the photon after
;           it passes through a half-wave plate, and a fixed
;           grid. Arbitrarily I chose the bolometers to record only
;           the A_y component but this can be easily adjusted to the
;           A_x. 
 
;ROUTINES USED:
;   NONE
;---------------------------------------------------------------------

FUNCTION polarization_fast, Q,U, T, n,n_bolo,speed=speed, delta = delta 

;****First step is to obtain the A_x,and  A_y from the input.

A_y = ((T^2-Q^2)/2.)^(1/2.)
A_x = ((T^2+Q^2)/2.)^(1/2.)

if keyword_set(delta) eq 1 then begin
delta = acos((float(U^2)/((T^2)^2-(Q^2)^2))^(1/2.))
;final_delta = !pi - delta
endif

delvarx, U
delvarx, Q
delvarx, T

vec_initial = [[A_x],[A_y]]
delvarx, A_x
delvarx, A_y

;****The half-wave plate is spinning at a default speed of 4 Hz. The
;telescope takes data at 190Hz so at every  0.00263158s we need to know the
;position of the plate. We set arbitrarily the fast axis to be at an
;angle phi = 0 at t=0.   

if keyword_set(speed) eq 0 then speed = 6.

;print, 'Simulating A Sample Rate of 190 Hz'
time_steps = findgen(n)* 1./190

;****Now we apply a transform into the reference frame of the wave
;plate, where phi' = 0. In this frame the wave plate simply retards the
;component of light which is on the slow axis by half a wavelength, ie
;flips its sign. The light on the fast axis is left untouched. Then we
;apply the inverse transform to get back to the regular frame of
;reference. 

;****Because the HWP spins through an angle of 2*pi with a frequency
;given, we have to compute a finited number (n_cycle) of transform
;matrices.We will create these 2x2 transform matrices right of the
;bat, and store them.

phi = speed*2*!pi*time_steps
;time_cycle = where(phi gt 6.28)

;n_cycle = time_cycle[0]

transform = fltarr(2,2,n)
;angs = phi[0:n_cycle-1]
phi = phi mod (2*!pi)

;delvarx, phi

;index = fltarr(n_cycle, float(n)/n_cycle)

timer = systime(/seconds)

;for i = 0, n_cycle-1 do begin

;transform[*,*,i]=[[-1*cos(angs[i])^2+sin(angs[i])^2,-2*cos(angs[i])*sin(angs[i])],$
 ;               [-2*cos(angs[i])*sin(angs[i]), cos(angs[i])^2-sin(angs[i])^2]] 

transform[0,0,*]=-1*cos(phi)^2+sin(phi)^2
transform[0,1,*]=-2*cos(phi)*sin(phi)
transform[1,0,*]=-2*cos(phi)*sin(phi)
transform[1,1,*]=cos(phi)^2-sin(phi)^2

;***** The first attempt at this code i messed around with this
;variable index, n_cycle  etc... but now i think i've got it working better and
;faster....

;Now weve got to split up the time stream so that we have (n_cycle) vectors,each containing 1/(n_cycle)th of the timestream, corresponding to times when
;the angle of the half wave plate will be in the identical
;position. For example, all points in the timestream when the HWP is
;at an angle pi...

;*****INDEX are the indices of each group corresponding to each
;angle of the HWP.

;index[i,*] = findgen(float(n)/n_cycle)*n_cycle + i 

;endfor

;print, 'EndTime:',systime(/seconds)-timer
vec_final = fltarr(n,2)

timer_2 = systime(/seconds)

;***** Now we do the linear algebra for each matrix multiplication
;each seperatly, because I couldn't figure out how to get IDL to do it
;all in one step.

;for i = 0, n_cycle-1 do begin

vec_final[*,0]= transform[0,0,*]*vec_initial[*,0]+$
                      transform[1,0,*]*vec_initial[*,1]
vec_final[*,1]= transform[0,1,*]*vec_initial[*,0]+$
                      transform[1,1,*]*vec_initial[*,1]

;endfor

;******** Trying to save memory by not created copies of the same information
;final_vec = fltarr(n,n_bolo)
;final_vec = reform(vec_final[*,1,*])

;*****Our detector looses all information that comes in as A_x, so we
;take only the A_y vector.

if keyword_set(delta) eq 0 then begin
polar = {spt_vec:reform(vec_final[*,1])}
endif else begin
polar = {spt_vec:reform(vec_final[*,1]), delta:delta}
endelse

return, polar


END
