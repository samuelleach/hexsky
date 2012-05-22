;---------------------------------------------------------------------
;PURPOSE
;   Makes a timestream of CMB polarisation.
;
;INPUTS:
;   SCOPE - an anonymous structure which has all of the following:
;     *BOLO_ARRAY  - a 2 by N array giving the offsets of each of
;       the bolometers from the central pointing of the scope,
;       in arcminutes.
;     *FWHM_ARCMIN - the full width half max of your scope's beam.
;
;   SCAN - an anonymous structure with all the following fields:
;     *RA_DEC - a 2 by N array of the right ascesion and declination of
;       your scope pointing, transformed from azi_alt.
;     *DATA_RATE - the rate at which pointing and lsts are calculated, in Hz.
;     *INTEGRATE_TIME - the total time the scan represents, in
;                       seconds.
;                            **OR**
;   POINTING - an array of the ra/dec of each bolo at each time
;
;   SYNFAST_ARRAY - an array created as the output of the synfast
;                   program read_fits_s.Contains the following:
;     *TEMPERATURE - an array of the sqrt of the stokes parameter I.
;     *Q_POLARISATION - an array of the sqrt of the stokes parameter Q
;                       (microKelvin)
;     *U_POLARISATION -  an array of the sqrt of the stokes parameter U
;                       (microKelvin)
;
;KEYWORDS:
;    SPEED - Angular Velocity of half wave plate. If not set will
;            default to 4Hz.
;    SCRAMBLE - Will alter the starting angle of the half wave plate.
;    DELTA - Will include the stream of delta parameters.(angle of polarisation); 
;
;OUTPUT:
;   TIMESTREAM - an anonymous structure with all the following fields:
;     *POLARISATION_STREAM - a n_bolo by N array representing the value sampled
;       a each instant for each bolometer, in delta T micro Kelvin.     
;     *N_BOLO - the number of bolometers in your array.  This uniquely
;       identifies which scope was used to form the timestream.
;     *RESO_ARCMIN - the resolution, in arcminutes, of the image this
;       timestream was made from.  Arcminutes on side of one pixel.
;     *DATA_RATE - the rate at which data was collected to form this
;       timestream, in Hz.
;
;ROUTINES USED:
;   ANG2PIX_RING - A HEALpix procedure which takes ra dec coordinates
;                  and finds the corresponding index in the large
;                  synfast array. *careful how the input is entered!
;
;   POLARISATION_FAST - Takes 3 stokes parameters as input, runs the
;                       information through the HWP and grid and
;                       outputs the temperature in microK that the
;                       bolometer picks up. 
;---------------------------------------------------------------------

;FUNCTION make_synfast_timestream, scope, scan, synfast_array,$
;                                   speed=speed, scramble = scramble
FUNCTION make_synfast_timestream, pointing, synfast_array,$
                                  speed= speed, scramble = scramble,$
                                                           delta = delta

timer = systime(/seconds)
reso_arcmin = 0.85887

;N - number of samples in the timestream
;N_BOLO - the number of bolometers in our array
n = n_elements(pointing.ra[0,*])
n_bolo = n_elements(pointing.ra[*,0])

;POLARISATION_STREAM - will have the polarisation information recorded
;                      by each bolometer at each point in time
polarisation_stream =fltarr(n_bolo,n)

;OPTIONAL information
;polarisation_2_stream =fltarr(n_bolo,n)
;delta_stream = fltarr(n_bolo,n)
;stream = fltarr(n_bolo,n)

;SYNFAST_PIXEL- pixel used from synfast array - for error checking
;synfast_pixel = fltarr(n_bolo, n)

;RA_DEC_BOLO -the individual ra and dec of each bolometer
;ra_dec_bolo = fltarr(2, n)


for i=0, n_bolo-1 do begin

;ra_dec_bolo[1,*] = scope.bolo_array[1,i]/60. + scan.ra_dec[1,*]
;ra_dec_bolo[0,*] = scope.bolo_array[0,i]/60.*1./cos(ra_dec_bolo[1,*]*!DTOR)$
;                                         + scan.ra_dec[0,*] 

;ang2pix_ring, 4096, (90-ra_dec_bolo[1,*])*!DTOR, ra_dec_bolo[0,*]*!DTOR, synfast_pix
ang2pix_ring, 4096, (90-pointing.dec[i,*])*!DTOR, pointing.ra[i,*]*!DTOR, synfast_pix


if keyword_set(scramble) eq 0 then begin
if i eq 0 then print,'No scramble'
endif else begin
if i eq 0 then print,'Scramble'
synfast_pix = [synfast_pix[5:n-1],synfast_pix[0:4]]
endelse

;synfast_pixel[i,*]= synfast_pix
;stream[i,*] = synfast_array.temperature[synfast_pix]

;polar = polarization(Q[synfast_pix],U[synfast_pix],t[synfast_pix], n)

if keyword_set(speed) eq 0 then begin

   if keyword_set(delta) eq 0 then begin
   polar = polarization_fast(synfast_array.q_polarisation[synfast_pix],$
                     synfast_array.u_polarisation[synfast_pix],$
                      synfast_array.temperature[synfast_pix], n, n_bolo)
   endif else begin
   polar = polarization_fast(synfast_array.q_polarisation[synfast_pix],$
                     synfast_array.u_polarisation[synfast_pix],$
                      synfast_array.temperature[synfast_pix], n, n_bolo, $
                       delta = 1)
   endelse

endif else begin

  if keyword_set(delta) eq 0 then begin
  polar = polarization_fast(synfast_array.q_polarisation[synfast_pix],$
                          synfast_array.u_polarisation[synfast_pix],$
                          synfast_array.temperature[synfast_pix], $
                           n, n_bolo, speed=speed) 
   endif else begin
   polar = polarization_fast(synfast_array.q_polarisation[synfast_pix],$
                          synfast_array.u_polarisation[synfast_pix],$
                          synfast_array.temperature[synfast_pix], $
                           n, n_bolo, speed=speed, delta= 1)
   endelse

endelse

if keyword_set(scramble) eq 0 then begin
polarisation_stream[i,*] = transpose(polar.spt_vec)

endif else begin
polarisation_stream[i,*] = transpose([polar.spt_vec[n-5:n-1],polar.spt_vec[0:n-6]])
endelse

;polarisation_2_stream[i,*]= polar.not_spt
if keyword_set(delta) eq 1 then delta_stream = fltarr(n_bolo,n)
if keyword_set(delta) eq 1 then delta_stream[i,*] = transpose(polar.delta)

;PROGRESS!
if i mod 25  eq 0 then  print,'Finished Bolometers:', i

endfor

;timestream = {stream:stream, n_bolo:n_bolo, reso_arcmin:reso_arcmin,$
     ;       data_rate:scan.data_rate,polarisation:polarisation_stream}

;timestream = {n_bolo:n_bolo, reso_arcmin:reso_arcmin,$
      ;      data_rate:scan.data_rate,polarisation:polarisation_stream, $
      ;      polarisation_2:polarisation_2_stream}
if keyword_set(delta) eq 0 then begin
timestream = {n_bolo:n_bolo, reso_arcmin:reso_arcmin,$
                                            polarisation:polarisation_stream}

endif else begin
timestream = {n_bolo:n_bolo, reso_arcmin:reso_arcmin,$
                         delta:delta_stream, polarisation:polarisation_stream}
endelse

print, 'EndTime:',systime(/seconds)-timer

return, timestream

END


