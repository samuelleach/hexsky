pro view_focalplane_integrationtime,focalplane,psfile,$
                                    minimap_size_arcmin=minimap_size_arcmin,$
                                    load_ct=load_ct

  ;AUTHOR: S. Leach
  ;PURPOSE: Plot the integration time in the focalplane struct

  if n_elements(load_ct) eq 0 then load_ct = 1

  focalplanefile = !HEXSKYROOT+'/data/ebex_fpdb.txt'
  fp             = read_focalplanefile(focalplanefile)

  ps_start,file=psfile


  title = 'Calibrator integration time [sec]'
  if n_elements(minimap_size_arcmin) ne 0 then begin
      mapsize = number_formatter(minimap_size_arcmin,dec=1)+"'" ;'
      title   = title+', '+mapsize+'x'+mapsize 
  endif

  ; Plot a empty axes (using /nodata)
  Position = ASPECT(1.)
  plot,fp.az*!radeg,fp.el*!radeg,xtitle='Az [deg]',ytitle='El [deg]',$
    psym=3,xchar=1.4,ychar=1.4,/nodata,position=position,$
    title=title

  
  ; Overplot empty detector symbols
  oplot,[focalplane.az*!radeg],[focalplane.el*!radeg],psym=sym(6)

  ; Overplot boresight
  oplot,[0.],[0.],psym=sym(12)
  
  
  ; Create color scale (elevColors) according to data range.
  ndet       = n_elements(focalplane.el)
  mintime    = min(focalplane.integration_time)
  maxtime    = max(focalplane.integration_time)  
  if mintime eq maxtime then maxtime = mintime + 1.
  colors     = Round(Scale_Vector(Findgen(ndet),mintime,maxtime))
  if ndet gt 1 then begin
     elevColors = Value_Locate(colors,focalplane.integration_time )
     elevColors = Scale_Vector(elevColors, 0, 255)
  endif else begin
     elevColors = 1
  endelse

    
  ; Fill in symbols and plot corresponding colorbar.
  if load_ct then begin 
     LoadCT, 34
  endif

  nmissed    = 0
  plotlegend = 0
  FOR jj = 0, ndet-1 DO begin
     if focalplane[jj].integration_time gt 0.d0 then begin
        PlotS, [focalplane[jj].az*!radeg], [focalplane[jj].el*!radeg],$
               Color=elevcolors[jj], Thick=10,psym=sym(1) ;4
     endif else begin
        nmissed    = nmissed + 1
        plotlegend = 1
     endelse
  endfor
  if (not is_gdl()) then begin
     fsc_colorbar,range=[mintime,maxtime],/vertical,charsize=1.5,format='(F5.2)'
  endif else begin
     message,'Device PS does not support TV in fsc_colorbar.pro',/continue
  endelse

  if (not is_gdl()) then begin
    if plotlegend then begin
      black = getcolor('black',0)
      al_legend,number_formatter(nmissed)+' missed detectors',box=0,/top,/right,psym=[sym(6)]
    endif
  endif else begin
    message,'Keyword parameter WIDTH not allowed in call to: XYOUTS, in legend.pro',/continue
  endelse
  ps_end

  
end	
