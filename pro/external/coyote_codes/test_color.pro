pro test_color

  y=findgen(100)/100.*2.*!pi
  y=sin(y)
  
  s = N_Elements(y)
  x = Indgen(s)
  colors = Round(Scale_Vector(Findgen(s), 0, 255))
  Plot, x, y, /NoData, Background=FSC_Color('ivory'),$
	Color=FSC_Color('Charcoal')
  LoadCT, 34
  Device, Decomposed=0, Get_Decomposed=theState
  FOR j=0,s-2 DO PlotS, [x[j], x[j+1]], [y[j], y[j+1]],$
       Color=colors[j], Thick=2
  Device, Decomposed=theState

  window,1
  s = N_Elements(y)
  x = Indgen(s)
  colors = Scale_Vector(Findgen(s), Min(y), Max(y))
  elevColors = Value_Locate(colors, y)
  elevColors = Scale_Vector(elevColors, 0, 255)
  Plot, x, y, /NoData, Background=FSC_Color('ivory'), $
	Color=FSC_Color('Charcoal')
  LoadCT, 34
  Device, Decomposed=0, Get_Decomposed=theState
  FOR j=0,s-2 DO PlotS, [x[j]], [y[j]],$
       Color=elevColors[j], Thick=7,psym=4
  Device, Decomposed=theState


  


  
end
