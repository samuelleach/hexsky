PRO pix2ang, nside, ipring, theta, phi, ordering=ordering

if N_params() ne 4 then begin
    print,' syntax = pix2ang, nside, ipix, theta, phi [,ordering=]'
    goto,sortie
endif

IF not keyword_set(ordering) THEN BEGIN
  sch='RING'
ENDIF ELSE BEGIN
  CASE ordering OF
    'RING': sch='RING'
    'NESTED': sch='NESTED'
    ELSE: BEGIN
      message,'Unknown pixelisation ordering: '+ordering,/info
      message,'Must be either RING or NESTED'
    END
  ENDCASE
ENDELSE

CASE sch of
  'RING': pix2ang_ring, nside, ipring, theta, phi
  'NESTED': pix2ang_nest, nside, ipring, theta, phi
ENDCASE

sortie:

END