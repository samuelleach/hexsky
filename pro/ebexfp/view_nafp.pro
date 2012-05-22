pro view_nafp

;Program illustrates how to read in the focalplane file for plotting.


  focalplanefile = !HEXSKYROOT+'/data/ebex_fpdb.txt'
  fp = read_focalplanefile(focalplanefile)

  Position = ASPECT(1.)
  plot,fp.az*!radeg,fp.el*!radeg,xtitle='Az [deg]',ytitle='El [deg]',$
       psym=3,xchar=1.4,ychar=1.4,/nodata,position=position,$
       title='Row 7 number 1 = alignment marker   ,   Row 8 number 7 = mounting screw'
  
  channel1 = where(fp.channel eq 150 and fp.power eq 1)
  channel2 = where(fp.channel eq 250 and fp.power eq 1)
  channel3 = where(fp.channel eq 410 and fp.power eq 1)
  
  oplot,fp[channel1].az*!radeg,fp[channel1].el*!radeg,psym=1
  oplot,fp[channel2].az*!radeg,fp[channel2].el*!radeg,psym=3
  oplot,fp[channel3].az*!radeg,fp[channel3].el*!radeg,psym=4
  
  al_legend,box=0,['150','250','410'],psym=[1,3,4],charsize=1.4
;  saveimage,'fp_full.png',/png


  window,1
  plot,fp.az*!radeg,fp.el*!radeg,xtitle='Az [deg]',ytitle='El [deg]',$
       psym=3,xchar=1.4,ychar=1.4,/nodata,position=position

  wafer=get_na_wafer(150)
  oplot,wafer.az*!radeg,wafer.el*!radeg,psym=1
  wafer=get_na_wafer(250)
  oplot,wafer.az*!radeg,wafer.el*!radeg,psym=3
  wafer=get_na_wafer(410)
  oplot,wafer.az*!radeg,wafer.el*!radeg,psym=4
  al_legend,box=0,['150','250','410'],psym=[1,3,4],charsize=1.4
;  saveimage,'fp_na.png',/png


end	
