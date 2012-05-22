FUNCTION get_dipole_map,nside,RA_deg,Dec_deg,vec_cart=vec_cart

;AUTHOR : S. Leach
;PURPOSE: Make a map of a dipole in Healpix nested format, where Ra_deg and
;         Dec_deg are the Ra and Dec of the dipole vector in degrees.
;
;eg Plot the cosmological dipole
;HIDL> map = get_dipole_map(1024,167.99.,-7.22)
;HIDL> molview,map,/nested,factor=3.358e-3 *1e3,units='mK'


if n_elements(vec_cart) eq 0 then begin
;Convert the Ra and Dec to a Cartesian vector
   x_d      = sin(ra_deg*!dtor)*cos(dec_deg*!dtor)
   y_d      = cos(ra_deg*!dtor)*cos(dec_deg*!dtor)
   z_d      = sin(dec_deg*!dtor)
endif else begin
   x_d      = vec_cart[0]
   y_d      = vec_cart[1]
   z_d      = vec_cart[2]
endelse


npix     = nside2npix(nside)
pix      = lindgen(npix)

pix2vec_nest, nside, pix, vec_out

; Take the dot product of the dipole vector and the pixel vector
map     = x_d*vec_out[*,0] + y_d*vec_out[*,1] +z_d*vec_out[*,2]

return,map

end
