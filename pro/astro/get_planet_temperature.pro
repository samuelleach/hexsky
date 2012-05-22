function get_planet_temperature,  JD, PLANET, FWHM, FREQ_GHZ,$
	 planet_diameter_arcmin=planet_diameter_arcmin,$
         planet_distance_km=planet_distance_km    

;  AUTHOR: S. Leach (SISSA) with input from D. Polsgrove (UMN)
;  PURPOSE: Returns the antenna temperature of planets.
;           Uses Moreno'98 Jupiter and Saturn models.
;
;  T_a = T_b x Omaga_planet/Omega_beam
;  T_b(jup) ~ 175K, T_b(sat) ~ 145K   (~10% accuracy)
;
;
; JD - Julian day.  
; PLANET- Planet number. Must be 6 (Saturn) or 5 (Jupiter)
;   1. Mercury
;   2. Venus
;   3. Earth
;   4. Mars
;   5. Jupiter
;   6. Saturn
;   7. Uranus
;   8. Neptune
; FWHM - FWHM of the beam in arcmin.
; FREQ_GHZ - Observation frequency in GHz.

  if((freq_ghz lt 12.) or (freq_ghz gt 964.)) then begin 
     message,'Moreno98 model only implemented for 12. < FREQ_GHZ < 964.'
  endif

  case strupcase(strtrim(planet,2)) of
      'JUPITER': file='moreno98_jupiter.dat'
      'SATURN': file='moreno98_saturn.dat'
      else: begin
          message,planet+' not implemented. Returning Temp = 0',/continue
          return,0.
      end

  endcase
  defsysv, '!HEXSKYROOT', exist=exist
  if not exist then dir = '.' else dir = !HEXSKYROOT+'/data'
  readcol,dir+'/'+file,f,t,/silent
  T_B=interpol(t,f,freq_ghz)
    
  diameter = planet_diameter(planet=planet)
  planet_distance_km     = planet_distance(jd,planet=planet,/jd)

  const1 = (180./!pi*60.) ; RAD2ARCMIN
  planet_diameter_arcmin = const1*diameter[0]/planet_distance_km[*];arcmin

  planet_solid_angle = 0.25*!pi*planet_diameter_arcmin^2
  ;Page el al ApJ 2003 quote Omega_jup = 2.481e-8sr when Jupiter is at closest approach to Earth (5.2AU).

;  beam_solid_angle =  0.25 *!pi * FWHM^2   ; =0.79 FWHM^2
  beam_solid_angle =  2 *!pi * FWHM^2/ (8. *alog(2.))  ; =0.79 FWHM^2

  T_A = T_B * planet_solid_angle/beam_solid_angle

  return,T_A
  
; Jupiter model

; Daniel Edward Polsgrove <polsgrove@physics.umn.edu>     Mon, Dec 15, 2008 at 8:31 PM

; To: Samuel Leach <leach@sissa.it>
; Cc: tjj@astro.umn.edu

; Sam -

; Great, appreciate the clarification.  Your model is correct as long as what
; we're looking for is the signal incident at EBEX; if we want what the
; detectors will actually see, we'd of course have to throw in some extra
; attenuation factors to account for losses through the optics (grid, lenses,
; etc.).  I just took a quick look at my literature source (Goldin et al, 1996
; - pdf attached), my previous calculations, and verified solid angles with my
; star charting software:

; - The brightness temp part... Goldin reports Jupiter brightness temps in
; bands observed by SCUBA: 172, 286, 492, 675 GHz.  Those temps are 169, $
; 165, 133, and 129 K respectively.  Each has a photometric error of +/- 2K, $
; as well as an uncertainty on the Mars model of +/- 10K.  They include a plot
; of T_RJ vs. freq, from which I made some rough guesses at brightness temps
; in the EBEX bands (see Figure 1 in Goldin): 150 GHz ~ 167K 250 GHz ~ 165K
; (same as that for SCUBA's 286 GHz... the plot looks pretty flat to me in
; this regime) 410 GHz ~ 150K (this is the trickiest one as the spectrum is
; dropping steeply into the ammonia absorption line)

; - The solid angle part... on 1 May 2009, Jupiter's equatorial angular diam =
; 37.86" and polar diam = 35.41" (as seen from Earth).  On 30 May 2009, it's
; equatorial = 41.48" and polar = 38.80".  Let's just call it a circle and use
; 36.6" for 1 May and 40.1" for 30 May.

; With these numbers, here are expected signals assuming 8' (480") beams...
; 150 GHz band:
; 1 May 09 - 167K x (36.6"/480")^2 = 0.97K
; 30 May 09 - 167K x (40.1"/480")^2 = 1.17K

; 250GHz band:
; 1 May 09 - 165K x (36.6"/480")^2 = 0.96K
; 30 May 09 - 165K x (40.1"/480")^2 = 1.15K

; 410 GHz band:
; 1 May 09 - 150K x (36.6"/480")^2 = 0.87K
; 30 May 09 - 150K x (40.1"/480")^2 = 1.05K

; So the change in solid angle with flight date actually does dominate the
; uncertainty (the 1 May to 30 May difference in effective brightness temp due
; to solid angle change is about a factor of 2 larger than that caused by a
; +/- 10K uncertainty in the emission model). I've never used helio.pro, but
; it sounds like that program could do the solid angle part to daily precision
; if you need that level of accuracy for your purposes.

; Ok, let me know if that's sufficient for now or if you need more data or
; details. Dan 
  




end
