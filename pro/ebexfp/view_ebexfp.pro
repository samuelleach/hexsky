pro view_ebexfp,phi0_deg=phi0_deg

;Program illustrates how to read in the focalplane file for plotting.
  
  if(n_elements(phi0_deg) eq 0) then phi0_deg=60.


;fpfile = !HEXSKYROOT+'/data/ebex_fpdb.txt'
fpfile = !HEXSKYROOT+'/data/ebex_fpdb_v3.txt'
readcol,fpfile,index,wafer,row,col,az,el,channel,power

phi    =  phi0_deg*!dtor
aztmp  =  cos(phi)*az + sin(phi)*el
eltmp  = -sin(phi)*az + cos(phi)*el
az     = aztmp
el     = eltmp  

position = aspect(1.)
ps_start,file='ebexfp.ps'
plot,az*!radeg,el*!radeg,xtitle='Az [deg]',ytitle='El [deg]',$
     psym=1,chars=1.4,/nodata,position=position,/iso
;     title='Row 7 number 1 = alignment marker, Row 8 number 7 = mounting screw',$


red   = fsc_color('red')
blue  = fsc_color('blue')
green = fsc_color('green')

channel1 = where(channel eq 150 and power eq 1)
channel2 = where(channel eq 250 and power eq 1)
channel3 = where(channel eq 410 and power eq 1)
oplot,az(channel1)*!radeg,el(channel1)*!radeg,psym=sym(1),color=red
oplot,az(channel2)*!radeg,el(channel2)*!radeg,psym=sym(1),color=green
oplot,az(channel3)*!radeg,el(channel3)*!radeg,psym=sym(1),color=blue

al_legend,box=0,['150 GHz','250 GHz','410 GHz'],psym=[sym(1),sym(1),sym(1)],charsize=1.,color=[red,green,blue]
ps_end,/nofix


end	
