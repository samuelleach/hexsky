FUNCTION beta_cmb,nu_ghz


   ;AUTHOR: S. Leach
   ;PURPOSE: Return the spectral index of the CMB anisotropies

   x        = nu_ghz/56.8
   beta_cmb = 2. - x - 2.*x/(exp(x) - 1.)
   return, beta_cmb

end
