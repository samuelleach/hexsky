function fl_highpass,lmax,fwhm_arcmin,nu_highpass,v_az_cosel


  ;AUTHOR: S. Leach
  ;PURPOSE: Implement an harmonic space filter for a high pass
  ;         filtered scanning experiment.
  ;         See Appendix B of Hivon et al, ApJ, 567 : 2-17, 2002


  l  = dindgen(lmax+1)
  fl = gaussbeam(fwhm_arcmin,lmax)

  l_c                = 2. * !pi * nu_highpass/ v_az_cosel
  fl[0:floor(l_c)]   = 0.
  fl[ceil(l_c):lmax] =   fl[ceil(l_c):lmax] * (1. - 2./!pi * asin(l_c/l))
  
  return,fl


end
