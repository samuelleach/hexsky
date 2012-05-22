pro oplot_circle, x_centre,y_centre,radius,_extra=extra

  ;AUTHOR: S. Leach
  ;PURPOSE: for overplotting circles.

  ncircle=n_elements(radius)

  phi = dindgen(100)/99*2*!pi
  for cc=0,ncircle-1 do begin
    r = radius[cc]
    x = x_centre + r*cos(phi)
    y = y_centre + r*sin(phi)
    oplot, x, y,col=1000,thick=1.7,_extra=extra
  endfor

end
