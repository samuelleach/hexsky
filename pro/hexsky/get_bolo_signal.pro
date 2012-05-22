function get_bolo_signal,signal,tsamp,taubolo,Nsum=Nsum

  ;AUTHOR: S. Leach (SISSA)
  ;Implemention of bolometer time constant smoothing from
  ;Reinecke et al 2005 (method 1)
  ;Method 2: From N. Ponthieu
  method=2

  tsamp=float(tsamp)
  taubolo=float(taubolo)

  nsamp = n_elements(signal)
  nsamp = long(nsamp)
  bolo_signal =make_array(nsamp,value=0.)
    
  if method eq 1 then begin
    if(n_elements(Nsum) eq 0) then Nsum= 500
    
    t_sum= taubolo*alog((1+findgen(Nsum))/float(Nsum))
    t_sum= fix(t_sum/tsamp)
    
    unconv= long(-min(t_sum))
    print,'Number of sample not convolved = ',unconv
    for ii= unconv,nsamp-1L do begin
      pix=ii+t_sum
      bolo_signal(ii)=total(signal(pix))
    endfor
    bolo_signal=  bolo_signal/float(Nsum)
  endif else if (method eq 2) then begin

    const1 = exp(-tsamp/taubolo)
    const2 = 1.-const1

;    for ii= 1L,nsamp-1L do begin
;        bolo_signal[ii]= const1*bolo_signal[ii-1] + const2*signal[ii]
;    endfor

    bolo_signal = const2*signal 
    for ii= 1L,nsamp-1L do begin
        bolo_signal[ii] += const1*bolo_signal[ii-1]
    endfor

  endif
    
  return,bolo_signal

end
