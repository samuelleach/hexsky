FUNCTION solidangle,fwhm_arcmin

  ;AUTHOR: S. Leach
  ;PURPOSE: Get the solid angle of a Gaussian beam with a supplied FWHM in arcmin.

  solidangle = 2.*!pi*(fwhm_arcmin*!pi/180./60.)^2/ (8.*alog(2.))

  return, solidangle
  
end