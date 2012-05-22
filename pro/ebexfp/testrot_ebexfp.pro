pro testrot_ebexfp

  readcol,'./data/ebex_fpdb.txt',detnum,wafer,row,col,xoff,yoff,channel,power

  yoff=yoff(where(power eq 1))
  xoff=xoff(where(power eq 1))

  ;Rotation angle
  phi=!pi/4.

  xoff_rot= cos(phi)*xoff + sin(phi)*yoff
  yoff_rot= -sin(phi)*xoff + cos(phi)*yoff
  xoff=xoff_rot
  yoff=yoff_rot
  
  
  ;Should be both > 0 
  el_bs= -80./!RADEG
  az_bs=10./!RADEG

  ;Code from SPT guys
  el_out = (!pi/2 - acos( $
			 sin(el_bs)*cos(yoff)*cos(xoff) $
			 + cos(el_bs)*sin(yoff) $
			 ))
  
  az_out = -atan( $
		 ( $
		  - sin(az_bs)*cos(el_bs)*cos(xoff) $
		  - cos(az_bs)*sin(xoff) $
		  + sin(az_bs)*sin(el_bs)*tan(yoff) $
		  ) $
		 / $
		 ( $
		  cos(az_bs)*cos(el_bs)*cos(xoff) $
		  - sin(az_bs)*sin(xoff) $
		  - cos(az_bs)*sin(el_bs)*tan(yoff) $
		  ) $
		 )

  ;Code from hexsky a la EBEX Proposal hitmaps
  el_out2 =   acos( cos(el_bs)*cos(yoff)-sin(el_bs)*sin(yoff))
  az_out2 =   acos( cos(az_bs)*cos(xoff/cos(el_out2))-sin(az_bs)*sin(xoff/cos(el_out2)))

  ;Nico
  el_out3 = asin( $
		     sin(el_bs)*cos(yoff)*cos(xoff) $
		   + cos(el_bs)*sin(yoff) $
	       	 )
  
  az_out3 = atan( $
		 ( $
		  + sin(az_bs)*cos(el_bs)*cos(xoff)*cos(yoff) $
		  + cos(az_bs)*sin(xoff)*cos(yoff) $
		  - sin(az_bs)*sin(el_bs)*sin(yoff) $
		  ) $
		 / $
		 ( $
		  cos(az_bs)*cos(el_bs)*cos(xoff)*cos(yoff) $
		  - sin(az_bs)*sin(xoff)*cos(yoff) $
		  - cos(az_bs)*sin(el_bs)*sin(yoff) $
		  ) $
		 )
  
  ;Make a plot
  plot,(az_bs+xoff)*!radeg,(el_bs+yoff)*!radeg,psym=3,$
    xrange=minmax(az_out)*!radeg+[-0.5,0.5],yrange=minmax(el_out)*!radeg+[-0.5,0.5],$
    xtitle='Azimuth [deg]',ytitle='Elevation [deg]',chars=1.4,xstyle=1,ystyle=1
  oplot,az_out*!radeg,el_out*!radeg,psym=1;square
;  oplot,az_out2*!radeg,el_out2*!radeg,psym=4
  oplot,az_out3*!radeg,el_out3*!radeg,psym=4
  al_legend,['No projection','Nico','SPT code'],psym=[3,1,4],box=0,chars=1.2
  

 
end
