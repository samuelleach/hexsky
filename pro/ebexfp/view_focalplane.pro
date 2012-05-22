pro view_focalplane,focalplane

  ;AUTHOR: S. Leach
  ;PURPOSE: Plot detectors in the focalplane struct  

  focalplanefile = !HEXSKYROOT+'/data/ebex_fpdb.txt'
  fp = read_focalplanefile(focalplanefile)

  Position = ASPECT(1.)
  plot,fp.az*!radeg,fp.el*!radeg,xtitle='Az [deg]',ytitle='El [deg]',$
       psym=3,xchar=1.4,ychar=1.4,/nodata,position=position,$
       title='Detectors in focalplane'

  oplot,[focalplane.az*!radeg],[focalplane.el*!radeg],psym=1

  index  = where(focalplane.power eq 1, complement = index2)
  if (index[0] ne -1) then begin
     oplot,[focalplane[index].az*!radeg],[focalplane[index].el*!radeg],psym=sym(6)
  endif

  
end	
