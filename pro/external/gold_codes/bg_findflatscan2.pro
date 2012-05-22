pro bg_findflatscan2, dir, filemid,net=net


  ;AUTHOR: B. Gold (minor edits by S. Leach)
  ;PURPOSE: Take an inhomogeneous integration time map and approximate it as
  ;         two homogeneous scans.

  if n_elements(net) eq 0 then net = 184.
    
  read_fits_map, dir+'/maps/150/tint_bycommand_'+filemid+'_utc.fits', tint , nside=nside
  cmbtint = tint[*,0]
  cmbtint = cmbtint[where(cmbtint gt 0)]
  
  print, 'mean/median/max ', mean(cmbtint), median(cmbtint), max(cmbtint)
  window, 0
  plothist, cmbtint, xr=[0,max(cmbtint)], xh,yh, bin=max(cmbtint)/50.,xtitle='Integration time [sec]',$
	    chars=1.5
  
  cumul  = total(yh, /cumul, /double)
  pixang = sqrt(4d0*!dpi/3145728) * 180d0/!dpi
  
  window, 1
  plot, xh, (max(cumul)-cumul) * pixang^2,xtitle='Time [sec]',ytitle='Area [sq. deg]',$
	chars=1.6
  
  area     = (max(cumul)-cumul)*pixang^2
  depth    = sqrt(xh)
  opt      = sqrt(area)*depth^2
  opt_time = (xh[where(opt eq max(opt))])[0]
  opt_area = (area[where(xh eq opt_time)])[0]
  
  pix_arcmin = sqrt(4d0*!dpi / nside2npix(nside) ) * 180/!dpi * 60
  opt_weight = net * sqrt(2) / sqrt(opt_time) * pix_arcmin
  print, 'optimum time (s), area (sqdeg), inv Q depth (microK arcmin for 150): '
  print, opt_time, opt_area, opt_weight
  
  window, 2
  plot, area, sqrt(area) * depth^2,xtitle='Area [sq. deg]',ytitle='sqrt(Area) x time',$
	chars=1.6
  
  opt_area2 = opt_area
  stepsiz = 1e3
  i=1
  while (abs(opt_area2-opt_area)/opt_area lt 0.2) do begin
    opt2 = sqrt(area) * depth^2 + stepsiz * i * sqrt(area)
    opt_time2 = (xh[where(opt2 eq max(opt2))])[0]
    opt_area2 = (area[where(opt2 eq max(opt2))])[0]
    opt_weight2 = net * sqrt(2) / sqrt(opt_time2) * pix_arcmin
    i += 1
  endwhile
  print, 'second peak:'
  print, opt_time2,  opt_area2, opt_weight2
  
  stop
end
