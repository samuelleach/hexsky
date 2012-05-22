function oof_noise, nsamp, tsamp_sec,white_noise,fknee_hz,alpha,$
		    dc_offset=dc_offset

  ; Copied from B. Johnson's PhD thesis, Appendix B.

  if n_elements(dc_offset) eq 0 then dc_offset=0.

  if ((nsamp mod 2) eq 0) then begin
    length=nsamp
  endif else begin
    length = nsamp+1L
  endelse
  
  length = long(length) ; Must be an even number
  N = double(length)
;  tsamp_sec = 4.8e-3        ;  [sec] -- sample period
  nyquist = 1./(2.*tsamp_sec);  [Hz]  -- Nyquist frequency
  delta_nu = 1./(N*tsamp_sec);  [Hz]  -- FFT resolution

  frequency = delta_nu*dindgen(length)
  frequency[(length/2)+1:length-1] = (-1)*reverse(frequency[1:(length/2)-1])

;  white_noise = 10e-9 ; [V/sqrt(Hz)]
;  fknee_hz = 0.2 ; [Hz]
;  alpha = 1.4
;  dc_offset = 0. ; [V]
  model = white_noise*(1.+ (fknee_hz/frequency[1:(length/2)-1])^alpha)

  fnoise = dcomplexarr(length)

  real = sqrt(delta_nu*model^2/2.)*randomn(seed,(length/2)-1)*(1./sqrt(2.))
  imag = sqrt(delta_nu*model^2/2.)*randomn(seed,(length/2)-1)*(1./sqrt(2.))

  fnoise[1:(length/2)-1] = dcomplex(real,imag)
  fnoise[(length/2)+1:length-1] = dcomplex(reverse(real),(-1)*reverse(imag))

  temp = (sqrt(delta_nu)*white_noise*(1.+(fknee_hz/nyquist)^alpha))*$
	randomn(seed,1)
  fnoise[length/2] = dcomplex(temp,0.)
  fnoise[0] = dcomplex(dc_offset,0.)

  noise = double( fft(fnoise,1))

  return, noise[0:nsamp-1]
  
end
