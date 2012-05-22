FUNCTION PLANCK_COVERAGE, ringpointing, dtheta_rad, coordsys=coordsys, nside=nside, ordering=ordering

;; Default values
;;----------------
  IF NOT KEYWORD_SET(nside) THEN nside=2048L
  IF NOT KEYWORD_SET(coordsys) THEN coordsys='G'
  IF NOT KEYWORD_SET(ordering) THEN ordering='RING'

;; Make empty map
;;----------------
  npix = NSIDE2NPIX(nside)
  map = FLTARR(npix)

;; Definitions
;;-------------
  nring = N_ELEMENTS(ringpointing)
  min_pts_per_pix = 4L
  pixsize_deg = SQRT(4*!pi/npix)/!dtor
  pix_per_ring = SIN(85.*!dtor)*360./pixsize_deg
  factor_oversampling = CEIL(min_pts_per_pix*pix_per_ring/FLOAT(nside))
  nperring = factor_oversampling*nside        ; typically factor_oversampling/4 points per pixel to avoid holes and discontinuity
  psi_phase = 2d0*!dpi * DINDGEN(nperring)/DOUBLE(nperring)

  ;; reorder psi_phase in 10 rings more sparsely sampled to coadd observation per block later on
  psi_phase = REFORM(psi_phase, factor_oversampling, nside)
  psi_phase = TRANSPOSE(psi_phase)
  psi_phase = REFORM(psi_phase, nperring)
  theta_open = 85d0 * !dpi / 180d0 + dtheta_rad

;; Loop on rings
;;---------------
  FOR i = 0L, nring-1 DO BEGIN
     ;; number of seconds per sample
     sec_per_sample = FLOAT(ringpointing[i].duration)/nperring

     ;; compute coordinates of ring samples
     CASE coordsys OF
        'G': RING_ON_SKY, !dpi/2d0-ringpointing[i].glat_rad, ringpointing[i].glon_rad, th, ph, theta_open=theta_open, psi_phase=psi_phase
        'E': RING_ON_SKY, !dpi/2d0-ringpointing[i].elat_rad, ringpointing[i].elon_rad, th, ph, theta_open=theta_open, psi_phase=psi_phase
        ELSE: MESSAGE, 'invalid coordinates'
     ENDCASE

     ;;compute pixel numbers
     CASE ordering OF
        'RING': ANG2PIX_RING, nside, th, ph, ipix
        'NESTED': ANG2PIX_RING, nside, th, ph, ipix
     ENDCASE
     
     ;;add observation time to map (loop needed to handle samples falling in same pixel)
     FOR j=0L, factor_oversampling-1 DO BEGIN
        indices = LINDGEN(nside) + j*nside
        map[ipix[indices]] = map[ipix[indices]] + sec_per_sample
     ENDFOR

  ENDFOR

RETURN, map

END
