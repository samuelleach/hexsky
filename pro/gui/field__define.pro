PRO FIELD__DEFINE

  ;FIELD struct. Angles in degrees.

; type = 1 : Annulus.
; type = 2 : Circlular field with diameter = abs(dec_max-dec_min)
;            and centre given by dec= (dec_max+dec_min)/2, RA= (RA_max+RA_min)/2
; type = 3 : Read outline from file given by 'name'.

   field = { FIELD, $
              type : 0, $
              name : '', $
              RA_MIN : 0e0, $
              RA_MAX : 0e0, $
              DEC_MIN : 0e0
              DEC_MAX : 0e0
            }

END
