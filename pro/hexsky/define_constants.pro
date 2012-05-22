pro define_constants

; pc = {physical_constants, $
;             c:299792458d, $
;             h:6.6260693d-34, $
;             h_bar:1.05457168d-34, $
;             k:1.3806505d-23, $
;             G:6.6742d-11, $
;             m_e:9.1093826d-31, $
;             e:1.60217653d-19, $
;             m_p:1.67262171d-27, $
;             eps0:8.854187817d-12, $ ;permitivity of free space
;             n_a:6.0221415d23, $     ;Avogadro constant
;             m_s:1.98844d30 $        ;Solar Mass
;            }
   pc= { rjd0:2.45490e6,$ ; For converting between JD and a reduced JD.    
         fwhm2sigma:1.00d0/sqrt(8.000d0*alog(2.000d0)), $ ; For converting between FWHM and Gaussian sigma.
         arcmin2rad:1.000d0/60.000d0*!dtor $ ; For converting from arcmin to radians.
       }
   
   DEFSYSV, '!constant', pc
   
end
