FUNCTION CMB_TEMPERATURE

   DEFSYSV, 'psm_cosmo_param', exists = cosmo_is_defined
   IF cosmo_is_defined EQ 0 THEN temp = 2.725d0 ELSE temp = !psm_cosmo_param.t_cmb

RETURN, temp

END
