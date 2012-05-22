pro rigid_dust_frequency_scaling,nu_1,nu_2,scaling

scaling=0.

; dust frequency scaling from nu=nu_1 GHz to nu=nu_2 GHz in antenna temperature

; best fit model 8 for dust rigid scaling according to ApJ Finkbeiner et al. 524, 867, 1999:
h=6.626176e-27                  ; erg * s
k=1.380662e-16                  ; erg / K
c=2.99792458e10                 ; cm / s
nu0_Hz=c/0.01                   ; nu observation in Hz
f_1=0.0363
f_2=1.-f_1
alpha_1=1.67
alpha_2=2.70
q_1_over_q_2=13.
T_1=9.4                         ; K
T_2=16.2                        ; K

; the following factor brings dust flux i100 to nu_1 GHz: 
factor_nu_1=f_1*q_1_over_q_2*                                        $
(nu_1*1.e9/nu0_Hz)^(alpha_1+3.)/(exp(h*nu_1*1.e9/k/T_1)-1.)+         $
f_2*(nu_1*1.e9/nu0_Hz)^(alpha_2+3.)/(exp(h*nu_1*1.e9/k/T_2)-1.)
factor_nu_1=factor_nu_1/(f_1*q_1_over_q_2/(exp(h*nu0_Hz/k/T_1)-1.)+  $
f_2/(exp(h*nu0_Hz/k/T_2)-1.))

; the following factor brings dust flux i100 to nu_2 GHz: 
factor_nu_2=f_1*q_1_over_q_2*                                        $
(nu_2*1.e9/nu0_Hz)^(alpha_1+3.)/(exp(h*nu_2*1.e9/k/T_1)-1.)+         $
f_2*(nu_2*1.e9/nu0_Hz)^(alpha_2+3.)/(exp(h*nu_2*1.e9/k/T_2)-1.)
factor_nu_2=factor_nu_2/(f_1*q_1_over_q_2/(exp(h*nu0_Hz/k/T_1)-1.)+  $
f_2/(exp(h*nu0_Hz/k/T_2)-1.))

;print,'brightness dust scaling between ',nu_1,' GHz and ',nu_2,' GHz:',factor_nu_2/factor_nu_1

; since antenna temperature is defined as the equivalent black body
; temperature in the Raylegh-Jeans region, T=I_nu *(c^2/2/nu^2/k), 
; in our units, going to K antenna temperature yields a factor
; 3.25478e1/(freq^2):
factor_nu_1=factor_nu_1*3.25478e1/nu_1^2
factor_nu_2=factor_nu_2*3.25478e1/nu_2^2

scaling=factor_nu_2/factor_nu_1

return
end
