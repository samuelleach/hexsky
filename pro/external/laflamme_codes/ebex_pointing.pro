;---------------------------------------------------------------------
;PURPOSE
;   Transforms the az and el input offsets as well as boresight
;   pointing, into individual bolometer pointing timestreams. Includes
;   the parameter beta - which rotates the focal entire focal array
;                        once it has reached its final positioning. 
;
;INPUTS:
;  BS_AZ/BS_ALT - boresight pointing, in az/el [deg]
;  LST - the stream of LST
;  BETA - the third degree of freedom - where the focal array is
;         rotated to [deg]
;  SCOPE
;
;KEYWORDS:
;   LAT - will default to 34.472
;
;OUTPUT:
;   SCOPE - an anonymous structure with all the following fields:
;     *RA - offsets in ra [arcminutes]    
;     *DEC - offsets in dec [arcminutes] 
;     *AZ - offsets in az [arcminutes]    
;     *ALT - offsets in alt [arcminutes]
;     *CART - cartesian coordinates of all bolometer offsets

;ROUTINES USED:
;  APPLY_PIXEL_OFFSET_SCAN - rotates the coordinate system in order to
;                            apply offsets which are defined only at
;                            az/el of (0,0)
;  ALTAZ2HADEC- transforms to ra/dec coordinates
;---------------------------------------------------------------------


FUNCTION ebex_pointing, bs_az, bs_alt, lst, beta, scope, lat = lat

if keyword_set(lat) eq 1 then lat = lat else lat = 34.472

n_bolos = n_elements(scope.alt)

ra = fltarr(n_bolos, n_elements(bs_az))
dec = fltarr(n_bolos, n_elements(bs_az))

;apply_pixel_offset_scan rotates the offsets to each boresight
;pointing location in the sky - returning pointing information for
;                               each individual bolometer.
;BOLO_AZ/BOLO_DEC have dimensions (n_elements, n_bolos)

apply_pixel_offset_scan, bs_az,bs_alt, scope.az*1/60., scope.alt*1/60., bolo_az, bolo_alt

bolo_ra = fltarr(n_elements(bs_az[*,0]), n_bolos)
bolo_dec = fltarr(n_elements(bs_az[*,0]), n_bolos)

;Now we transform az/alt into ra/dec coordinates at the given LAT.

for j = 0, n_bolos-1 do begin
altaz2hadec, bolo_alt[*,j], bolo_az[*,j], lat, ha, dec_bolo
bolo_dec[*,j] = dec_bolo
bolo_ra[*,j] = (lst - ha)
endfor

;The final step is the parameter beta which will rotate the focal
;array by the parameter beta. First rotate into the frame of reference
;where the focal array is on the x_prime, y_prime plane, then rotate
;by angle beta. Just applying Euler Angles. Then rotate back to the
;original x, y, z frame. 
;We apply three rotation matrices, for el az and beta. 
;To transform back we only apply the inverse of el and az. 

beta *= !DTOR

M = fltarr(3,3,n_elements(beta))
carts = fltarr(n_elements(bs_az),3)
new_carts=fltarr(n_elements(beta),3)

for j = 0, n_bolos-1 do begin

az = bolo_ra[*,j]*!DTOR
el = bolo_dec[*,j]*!DTOR

M[0,0,*] = cos(el)*cos(az)*cos(beta[*])+sin(az)*sin(beta[*])
M[1,0,*] = cos(el)*cos(beta[*])*sin(az)+cos(az)*sin(beta[*])
M[2,0,*] = cos(beta[*])*sin(el)
M[0,1,*] = -1*sin(beta[*])*cos(az)*cos(el)-sin(az)*cos(beta[*])
M[1,1,*] = -1*sin(az)*sin(beta[*])*cos(el)+cos(az)*cos(beta[*])
M[2,1,*] = -1*sin(beta[*])*sin(el)
M[0,2,*] = -1*sin(el)*cos(az)
M[1,2,*] = -1*sin(el)*sin(az)
M[2,2,*] = cos(el)

carts[*,0] = $
cos((bolo_dec[*,j])*!DTOR)*cos((bolo_ra[*,j])*!DTOR)
;cos((flat_offsets_dec[j]+bs_dec)*!DTOR)*cos((flat_offsets_ra[j]+bs_ra)*!DTOR)
carts[*,1] = $
cos(bolo_dec[*,j]*!DTOR)*sin((bolo_ra[*,j])*!DTOR)
;cos((flat_offsets_dec[j]+bs_dec)*!DTOR)*sin((flat_offsets_ra[j]+bs_ra)*!DTOR)
carts[*,2] = $
sin(bolo_dec[*,j]*!DTOR)
;sin((flat_offsets_dec[j]+bs_dec)*!DTOR)

;Rotate by the parameter beta
new_carts[*,0] = M[0,0,*]*carts[*,0]+M[1,0,*]*carts[*,1]+M[2,0,*]*carts[*,2]
new_carts[*,1] = M[0,1,*]*carts[*,0]+M[1,1,*]*carts[*,1]+M[2,1,*]*carts[*,2]
new_carts[*,2] = M[0,2,*]*carts[*,0]+M[1,2,*]*carts[*,1]+M[2,2,*]*carts[*,2]

;Now go back into original frame by (almost) inverse of M
M[0,0,*] = cos(el)*cos(az)
M[1,0,*] = -1*cos(el)*sin(az)
M[2,0,*] = -1*sin(el)
M[0,1,*] = sin(az)
M[1,1,*] = cos(az)
M[2,1,*] = 0
M[0,2,*] = sin(el)*cos(az)
M[1,2,*] = -1*sin(el)*sin(az)
M[2,2,*] = cos(el)

new_carts[*,0] = M[0,0,*]*new_carts[*,0]+$
                          M[1,0,*]*new_carts[*,1]+M[2,0,*]*new_carts[*,2]
new_carts[*,1] = M[0,1,*]*new_carts[*,0]+$
                          M[1,1,*]*new_carts[*,1]+M[2,1,*]*new_carts[*,2]
new_carts[*,2] = M[0,2,*]*new_carts[*,0]+$
                          M[1,2,*]*new_carts[*,1]+M[2,2,*]*new_carts[*,2]

delvarx, M
;Again, the arctan may give results up to +/- pi....

ra[j,*] = atan(new_carts[*,1]/new_carts[*,0])/!DTOR 
dec[j,*]= asin(new_carts[*,2]/sqrt(new_carts[*,2]^2+new_carts[*,0]^2+new_carts[*,1]^2))/!DTOR
endfor

pointing = {ra:ra, dec:dec}

return, pointing


END


;old code 
;n_bolos = n_elements(scope.alt)

;ra = fltarr(n_bolos, n_elements(bs_ra))
;dec = fltarr(n_bolos, n_elements(bs_ra))

;Offsets are defined at a az/el of (0,0) but this corresponds to and
;ra/dec of (180, 55.528)
;apply_pixel_offset_scan, bs_ra-180, bs_dec-55.528, scope.ra*1/60., scope.dec*1/60., bolo_ra, bolo_dec

;apply_pixel_offset_scan, bs_ra, bs_dec, scope.ra*1/60., scope.dec*1/60., bolo_ra, bolo_dec

;bolo_ra += 180
;bolo_dec +=55.528

;stop

;This is a terrible way of correcting for a bug in
;apply_pixel_offset_scan that gives a final ra of the true ra +/-
;pi... Trying to figure this one out...
;plot, bolo_ra[0,*], bolo_dec[1,*], /ps
;index = where(bolo_ra[0,*] gt 280,nbad)
;if nbad gt 1 then bolo_ra[*,index]-=180

;STEP ONE: find offsets in terms of ra/dec.
;for j = 0 , n_bolos-1 do begin;

;altaz2hadec, scope.alt*1./60+0, scope.az*1/60.+0, lat, ha, dec

;if j mod 50 eq 0 then print, 'Finished:'

;endfor

;stop

;n_bolos = n_elements(scope.alt)
;n = n_elements(az)

;M = fltarr(3,3,n)
;new_carts = fltarr(n,3, n_bolos)
;az_off_new = fltarr(n_bolos,n)
;el_off_new = fltarr(n_bolos,n)
;az_actual = fltarr(n_bolos,n)
;el_actual = fltarr(n_bolos,n)
;ra = fltarr(n_bolos, n)
;ha = fltarr(n_bolos,n)
;dec= fltarr(n_bolos,n)

;carts = fltarr(n_bolos, 3)
;carts[*,0] = cos(scope.alt*1/60.*!DTOR)*cos(scope.az*1/60.*!DTOR)
;carts[*,1] = cos(scope.alt*1/60.*!DTOR)*sin(scope.az*1/60.*!DTOR)
;carts[*,2] = sin(scope.alt*1/60.*!DTOR)


;M[0,0,*] = cos(az*!DTOR)
;M[1,0,*] = -1*sin(az*!DTOR)
;;M[2,0,*] = 0
;M[0,1,*] = cos(alt*!DTOR)*sin(az*!DTOR)
;M[1,1,*] = cos(alt*!DTOR)*cos(az*!DTOR)
;M[2,1,*] = -1*sin(alt*!DTOR)
;M[0,2,*] = sin(alt*!DTOR)*sin(az*!DTOR)
;M[1,2,*] = sin(alt*!DTOR)*cos(az*!DTOR)
;M[2,2,*] = cos(alt*!DTOR)
;STEP 1: finiding the new (0,0) point (ie. bolometer # 925 is defined
;as the boresight and always has an offset of (0,0)
;j=925

;new_carts[*,0,j] = M[0,0,*]*carts[j,0]+M[1,0,*]*carts[j,1]+M[2,0,*]*carts[j,2]
;new_carts[*,1,j] = M[0,1,*]*carts[j,0]+M[1,1,*]*carts[j,1]+M[2,1,*]*carts[j,2]
;new_carts[*,2,j] = M[0,2,*]*carts[j,0]+M[1,2,*]*carts[j,1]+M[2,2,*]*carts[j,2]

;boresight_az = atan(new_carts[*,1,j]/new_carts[*,0,j])
;boresight_el = atan(new_carts[*,2,j]/sqrt(new_carts[*,0,j]^2+new_carts[*,1,j]^2))

;delvarx, j

;for j = 0, n_bolos-1 do begin

;new_carts[*,0,j] = M[0,0,*]*carts[j,0]+M[1,0,*]*carts[j,1]+M[2,0,*]*carts[j,2]
;new_carts[*,1,j] = M[0,1,*]*carts[j,0]+M[1,1,*]*carts[j,1]+M[2,1,*]*carts[j,2]
;new_carts[*,2,j] = M[0,2,*]*carts[j,0]+M[1,2,*]*carts[j,1]+M[2,2,*]*carts[j,2]

;az_off_new[j,*] = atan(new_carts[*,1,j]/new_carts[*,0,j]) - boresight_az
;el_off_new[j,*] = atan(new_carts[*,2,j]/sqrt(new_carts[*,0,j]^2+new_carts[*,1]^2))-boresight_el

;az_actual[j,*] = az*!DTOR + az_off_new[j,*]
;el_actual[j,*] = alt*!DTOR+ el_off_new[j,*]

;altaz2hadec, el_actual[j,*]*180/!pi, az_actual[j,*]*180/!pi, lat, ha_temp, dec_temp


;ha[j,*]=ha_temp
;dec[j,*] = dec_temp
;ra[j,*]= (lst[*] - ha[j,*]) mod 360.

;if j mod 50 eq 0 then print, 'Finished ',strtrim(j/float(n_bolos)*100,2),'%'

;endfor

;pointing = {az:az_actual*180/!pi, el:el_actual*180/!pi, ra:ra, dec:dec}
;stop


