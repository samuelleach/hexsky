PRO DUST_CALC_TEST

  ;Author : C.Bao
  ;Purpose: Practice of calculating statistics of dust level
  ;         for a specific region



;------map---------
inmap = !HEXSKYROOT+'/data/dust_carlo_150ghz_512_radec.fits'

;----test values---------
ctr_ra = 150
ctr_dec = 45
resol = 1.5
pxsize = 500
pysize = 500

;----center position to theta and phi
ctr_ra_rad = ctr_ra / !radeg
ctr_dec_rad= !pi/2-ctr_dec/ !radeg

;----angular size of desired calculating region-----
half_x_ang = resol/60.*pxsize/2/!radeg
half_y_ang = resol/60.*pysize/2/!radeg


;-----vertices of such region------------
vertex_theta = [ctr_dec_rad-half_y_ang,ctr_dec_rad-half_y_ang,$
                ctr_dec_rad+half_y_ang,ctr_dec_rad+half_y_ang]
vertex_phi = [ctr_ra_rad-half_x_ang,ctr_ra_rad+half_x_ang,$
                ctr_ra_rad+half_x_ang,ctr_ra_rad-half_x_ang]


;------convert to cartesian coord-----------
ang2vec,vertex_theta,vertex_phi,vertex_vec

;-----get pixel numbers-----------
query_polygon,512,vertex_vec,pixels



;----calculate the statistics of the data------
read_fits_map,inmap,map
result = moment(map[pixels,0])
print,result
  
END
