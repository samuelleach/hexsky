pro rotboresight3,cosra_bs,cosdec_bs,sinra_bs,sindec_bs,costheta_bs,sintheta_bs,$
                  xoff,yoff,ra_out,dec_out,sindec_out
; Rotates boresight RA, Dec, and beta by xoff and yoff (Focalplane az
; and el of detector) to get detector coordinates.

; theta= beta+pi

   ;---------------
   ;Rotate detector
   ;---------------
   xoff_rot =  costheta_bs*xoff - sintheta_bs*yoff
   yoff_rot =  sintheta_bs*xoff + costheta_bs*yoff
   cosxoff  =  cos(xoff_rot)
   cosyoff  =  cos(yoff_rot)
   sinxoff  =  sin(xoff_rot)
   sinyoff  =  sin(yoff_rot)

;   dec_out = asin( $
;                   sindec_bs*cosyoff*cosxoff $
;                   + cosdec_bs*sinyoff $
;                 )
   
   sindec_out = sindec_bs*cosyoff*cosxoff + cosdec_bs*sinyoff
   dec_out = asin( sindec_out)
   
   ra_out =  +  atan( $
                      ( $
                        + sinra_bs*cosdec_bs*cosxoff*cosyoff $
                        + cosra_bs*sinxoff*cosyoff $
                        - sinra_bs*sindec_bs*sinyoff $
                      ) $
                      , $
                      ( $
                        cosra_bs*cosdec_bs*cosxoff*cosyoff $
                        - sinra_bs*sinxoff*cosyoff $
                        - cosra_bs*sindec_bs*sinyoff $
                      ) $
                    ) 
   ra_out = ((2*!pi) + ra_out) MOD (2*!pi)

end
