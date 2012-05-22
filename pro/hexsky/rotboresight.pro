pro rotboresight,az_bs,el_bs,cosxoff,cosyoff,sinxoff,sinyoff,az_out,el_out

 cosel_bs= cos(el_bs)
 sinel_bs= sin(el_bs)
 cosaz_bs= cos(az_bs)
 sinaz_bs= sin(az_bs)

 el_out = asin( $
                sinel_bs*cosyoff*cosxoff $
                + cosel_bs*sinyoff $
              )
  
 az_out =        atan( $
                      ( $
                        + sinaz_bs*cosel_bs*cosxoff*cosyoff $
                        + cosaz_bs*sinxoff*cosyoff $
                        - sinaz_bs*sinel_bs*sinyoff $
                      ) $
                      , $
                      ( $
                        cosaz_bs*cosel_bs*cosxoff*cosyoff $
                        - sinaz_bs*sinxoff*cosyoff $
                        - cosaz_bs*sinel_bs*sinyoff $
                      ) $
                    ) 
; index=where(az_out lt 0.)
; az_out(index) = az_out(index) +2.*!pi

 
end
