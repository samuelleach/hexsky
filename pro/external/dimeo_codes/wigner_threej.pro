function wigner_threeJ,j1,j2,j3,m1,m2,m3
; Routine which calculates the Wigner 3-J numbers based on
; eqs (3.6.10) and (3.7.3) in Edmond's book "Angular Momentum
; in Quantum Mechanics".
;
;         / j1  j2  j3 \
; coef = |              |
;         \ m1  m2  m3 /
;
; Written by R.M.Dimeo (8/18/2000)
; Modified (02/20/02) by RMD.
;

jj1 = j1 & jj2 = j2 & jj3 = j3
mm1 = m1 & mm2 = m2 & mm3 = m3
t1 = (m1+m2+m3) ne 0
t2 = (j1+j2-j3) lt 0
t3 = (j1+j3-j2) lt 0
t4 = (j3+j2-j1) lt 0
t5 = 0
if (t1 or t2 or t3 or t4 or t5) then return,0.D0

m1 = double(m1) & m2 = double(m2) & m3 = -1.0*double(m3)
j1 = double(j1) & j2 = double(j2) & j3 = double(j3)
term1 = ds_delta(m1+m2,m3)
term2 = (2.0*j3+1)*nfact(j1+j2-j3)*nfact(j1-m1)*$
        nfact(j2-m2)*nfact(j3+m3)*nfact(j3-m3)
term2 = term2/(nfact(j1+j2+j3+1.0)*nfact(j1-j2+j3)*$
        nfact(-j1+j2+j3)*nfact(j1+m1)*nfact(j2+m2))
coef = term1*sqrt(term2)
sum = 0.0
nbig = 200
for s = 0,nbig-1 do begin
  z = double(s)
  den1 = j1-m1-z & den2 = j3-m3-z & den3 = j2-j3+m1+z
  if den1 ge 0.0 and den2 ge 0.0 and den3 ge 0.0 then begin
    num = nfact(j1+m1+z)*nfact(j2+j3-m1-z)
    den = nfact(z)*nfact(den1)*nfact(den2)*nfact(den3)
    sum = sum+((-1.0)^(z+j1-m1))*num/den
  endif
endfor
coef = coef*sum
newcoef = ((-1.0)^(j1-j2-m3))*(1.0/sqrt(2.0*j3+1))*coef
coef = newcoef
j1 = jj1 & j2 = jj2 & j3 = jj3
m1 = mm1 & m2 = mm2 & m3 = mm3
return,coef
end