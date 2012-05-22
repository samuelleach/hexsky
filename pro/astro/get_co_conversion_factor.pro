function get_co_conversion_factor,nuline_ghz,nuband_ghz,band_response,$
                                  band_response_coline=band_response_coline

  ;AUTHOR: S. Leach
  ;PURPOSE: Work out the conversion factor to go from K_RJ km s^-1 to K_RJ^{eff}.
  
  ; nuline_ghz is the frequency [GHz] of the line emission
  ; nuband_ghz are the abscissae of the bandpass.
  ; band_response are the bandpass values.
  ; Optionally one may supply band_response_coline which is the value of
  ;  the bandpass (same units as band_repsonse) specified at the nuline_ghz.

  ;-------------------------------------------------------------------
  ; First normalise the bandpass so that the integral of the band is 1
  ;-------------------------------------------------------------------
  normfactor         = int_tabulated(nuband_ghz,band_response,/double,/sort)
  print,'normfactor  = ',normfactor
  norm_band_response = band_response/normfactor

  ;--------------------------------------------------------
  ; Next evaluate the response at the frequency of the line
  ;--------------------------------------------------------
  if( n_elements(band_response_coline) ne 0) then begin
     norm_band_response_coline = band_response_coline/normfactor
  endif else begin
     norm_band_response_coline = interpol(norm_band_response,nuband_ghz,nuline_ghz)
  endelse

  factor = nuline_ghz*1e9 / 299792458 * norm_band_response_coline

  return,factor

end


pro test_get_co_conversion_factor

  
  asc_read,!HEXSKYROOT+'/data/band_410.txt',nuband,response,/silent
  nuline = 345.796
  print, nuline,get_co_conversion_factor(nuline,nuband,response,band_response_coline = 0.02)
  nuline = 461.041
  print, nuline,get_co_conversion_factor(nuline,nuband,response,band_response_coline = 0.02)

  asc_read,!HEXSKYROOT+'/data/band_250.txt',nuband,response,/silent
  nuline = 230.578
  print, nuline,get_co_conversion_factor(nuline,nuband,response)
  nuline = 220.399
  print, nuline,get_co_conversion_factor(nuline,nuband,response)

  asc_read,!HEXSKYROOT+'/data/band_150.txt',nuband,response,/silent
  nuline = 115.271
  print, nuline,get_co_conversion_factor(nuline,nuband,response,band_response_coline = 0.01)
  nuline = 110.201
  print, nuline,get_co_conversion_factor(nuline,nuband,response,band_response_coline = 0.01)


end
