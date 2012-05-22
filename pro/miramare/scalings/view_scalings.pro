pro view_scalings,pixel,filestring,dir=dir,nside=nside,order=order,xrange=xrange,yrange=yrange,$
		   in_units=in_units,out_units=out_units,unitsstring=unitsstring,_extra=extra

  ;AUTHOR: S. Leach
  ;PURPOSE: Illustrate ploting of miramare scalings,derivatives and data files.
  
  if(n_elements(dir) eq 0) then dir='./'
  if(n_elements(order) eq 0) then order='NESTED'

  pixelstring = strtrim(pixel,2)
  scalings    = ddread(dir+'/'+filestring+'_scalings_'+pixelstring+'.dat',type=5) 
  data        = ddread(dir+'/'+filestring+'_data_'+pixelstring+'.dat')     

  derivatives = ddread(dir+'/'+filestring+'_derivatives_1_'+pixelstring+'.dat')
;  derivatives = ddread(dir+'/'+filestring+'_derivatives_2_'+pixelstring+'.dat')
  

  dummy   = size(data)
  nstokes = (dummy[1]-1)/2

  dummy   = size(scalings)
  npoint  = dummy[2]
  ncomp   = (dummy[1]-1)/nstokes
  freq    = scalings[0,*]
  npoint  = n_elements(freq)
  ndata   = n_elements(data[0,*]) 
  factor  = make_array(npoint,value=1.)
  factor2 = make_array(ndata,value=1.)

  if( n_elements(xrange) eq 0) then xrange = minmax(freq)+[-20,20]
  if( n_elements(out_units) gt 0) then begin
     factor  = conversion_factor(in_units,out_units,freq*1e9)
     factor2 = conversion_factor(in_units,out_units,data[0,*]*1e9)
   endif else begin
     factor  = make_array(npoint,value=1.)
     factor2 = make_array(ndata,value=1.)
   endelse
   if( n_elements(yrange) eq 0) then begin
     if keyword_set(ylog) then begin
       yrange = minmax(data[1,*]*factor2)*[0.001,1.3]
     endif else begin
       yrange = minmax(data[1,*]*factor2)*[1.3,1.3]
     endelse
   endif
   
  if( n_elements(unitsstring) eq 0) then unitsstring = textoidl('\muK_{RJ}')


  ;---------------------------------------------------------
  ;Make the title - Working out the lon and lat of the pixel
  ;---------------------------------------------------------
  title = ' '
  if(n_elements(nside) gt 0) then begin
      if order eq 'NESTED' then begin
          pix2ang_nest,nside,pixel,theta,phi
      endif else begin
          pix2ang_ring,nside,pixel,theta,phi
      endelse          
      ll = 90.-theta*!radeg
      if (abs(ll) lt 0.01) then ll = 0.
      phi = phi*!radeg
      phi = phi - (long(phi)/180)*360.0
      title = 'b = '+number_formatter(ll,dec=2)+'!Uo!N, '+$
        ell()+' = '+number_formatter(phi,dec=2)+'!Uo!N '+$
        '('+strtrim(pixel,2)+')'
  endif
  

  ;--------------------------------------------------
  ; Plot frequency scalings for each Stokes parameter
  ;--------------------------------------------------
  for ss = 0, nstokes - 1 do begin
      index1 = 1 + ss * ncomp
      index2 = 1 + ss * 2

      plot,freq,abs(scalings[index1,*]*factor),xtitle='Frequency [GHz]',ytitle='Signal ['+unitsstring+']',$
        chars=1.7,/nodata,/xlog,xstyle=1,ystyle=1,yrange=yrange,xrange=xrange,ylog=ylog,title=title,$
        xthick=6,ythick=6,_extra=extra
      
      totalsig = make_array(npoint,value=0.)
      line = 1
      for cc = index1, index1 + ncomp - 1 do begin
          oplot,freq,abs(scalings[cc,*]*factor),line=line,thick=3.5
          totalsig = totalsig + scalings[cc,*]

          deltabeta = 0.3
;          deltabeta = 4. 
          oplot,derivatives[0,*], scalings[cc,*] + derivatives[cc,*]*deltabeta,line=line
          oplot,derivatives[0,*], scalings[cc,*] - derivatives[cc,*]*deltabeta,line=line

          line     = line + 1


      endfor
      oplot, freq, totalsig*factor,thick=5.4
      oploterror, data[0,*], data[index2,*]*factor2,data[index2+1,*]*factor2, psym=1,errthick=3.5


      ;---------------------
      ;Make plot of residual
      ;---------------------
      residual = reform(data[index2,*])*factor2 - interpol(totalsig*factor,freq,reform(data[0,*]))      
      range    = max(abs(minmax(residual)))
      yrange2  = [-range,range]*1.7
      plot,freq,scalings[0,*]*factor,xtitle='Frequency [GHz]',ytitle='Residual ['+unitsstring+']',$
        chars=1.7,/nodata,/xlog,xstyle=1,ystyle=1,yrange=yrange2,xrange=xrange,title=title,$
        xthick=6,ythick=6
      oploterror,data[0,*],residual,data[index2+1,*]*factor2,psym=1,errthick=3.5
      oplot,xrange,[0,0],line=1

      
  endfor


end
