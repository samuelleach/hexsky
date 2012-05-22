FUNCTION get_bandcentre, nu,response,bandwidth=bandwidth,nu_l=nu_l,nu_u=nu_u,noplots=noplots

  ;AUTHOR: S. Leach
  ;PURPOSE: Calculate the effective frequency and bandwith of a bandpass.
  ;         Implementation of Runyan et al (astro-ph/0303515) Appendix A.

  
  bandcentre  = total(nu*response,/double)/total(response,/double)
  
  nabs          = n_elements(response)
  deriv         = response
  deriv[0]      = 0.
  deriv[nabs-1] = 0.
  deltanu       = make_array(nabs-1)


  ; Get first derivative of the bandpass
  for aa=1,nabs-2 do begin
      deriv[aa] = (response[aa+1] - response[aa-1])/(nu[aa+1] - nu[aa-1])
  endfor

  ; Get average delta_nu
  for aa=0,nabs-2 do begin
      deltanu[aa] = (nu[aa+1] - nu[aa])
  endfor
  deltanubar = total(deltanu,/double)/float(nabs)
  


  indexcentre = where(abs(nu-bandcentre) eq min(abs(nu-bandcentre)))
  if(n_elements(indexcentre) eq 2) then begin
     ;indexcentre = indexcentre[1]
     print,'here'
     nu_l = total(deriv[0:indexcentre[0]]*nu[0:indexcentre[0]],/double)/total(deriv[0:indexcentre[0]],/double)
     nu_u = total(deriv[indexcentre[1]:nabs-1]*nu[indexcentre[1]:nabs-1],/double)/total(deriv[indexcentre[1]:nabs-1],/double)
     dnu  = 0.
  endif else begin
     nu_l = total(deriv[0:indexcentre]*nu[0:indexcentre],/double)/total(deriv[0:indexcentre],/double)
     nu_u = total(deriv[indexcentre+1:nabs-1]*nu[indexcentre+1:nabs-1],/double)/total(deriv[indexcentre+1:nabs-1],/double)
     dnu  = 0.
;     dnu  = nu[indexcentre] - bandcentre
  endelse

  bandwidth = nu_u - nu_l

  nu_u = nu_u + dnu
  nu_l = nu_l + dnu

  if not keyword_set(noplots) then begin
     thick =5
     plot,nu,response,chars=1.5,xtitle='Frequency [GHz]',yrange=[0,max(response)*1.2],ystyle=2,$
          ytitle='Spectral response, '+textoidl('f(\nu)'),thick=thick,xthick=thick,ythick=thick
     oplot,[nu[0]*0.8,nu[nabs-1]*1.2],[0,0],line=1,thick=thick
     oplot,[nu_l,nu_l],[0,max(response)*1.2],line=2,thick=thick
     oplot,[nu_u,nu_u],[0,max(response)*1.2],line=2,thick=thick
     oplot,[bandcentre,bandcentre],[0,max(response)*1.2],line=6,thick=thick
     al_legend,[textoidl('\nu_0 = ')+number_formatter(bandcentre,dec=1),$
             textoidl('\nu_L = ')+number_formatter(nu_l,dec=1),$
             textoidl('\nu_U = ')+number_formatter(nu_u,dec=1),$
             textoidl('\Delta\nu = ')+number_formatter(bandwidth,dec=1),$
             textoidl('\Delta\nu/\nu_0 = ')+number_formatter(bandwidth/bandcentre,dec=2),$
             textoidl('\delta\nu = ')+number_formatter(deltanubar,dec=2),$
             textoidl('\Delta\nu/\delta\nu = ')+number_formatter(bandwidth/deltanubar,dec=1)],$
            /top,/right,box=0
     
     plot,nu,deriv,chars=1.5,xtitle='Frequency [GHz]',yrange=[min(deriv)*1.2,max(deriv)*1.2],ystyle=2,$
          ytitle='Spectral derivative, '+textoidl('df(\nu)/d\nu'),thick=thick,xthick=thick,ythick=thick
     oplot,[nu[0]*0.8,nu[nabs-1]*1.2],[0,0],line=1,thick=thick
     oplot,[nu_l,nu_l],[min(deriv)*1.2,max(deriv)*1.2],line=2,thick=thick
     oplot,[nu_u,nu_u],[min(deriv)*1.2,max(deriv)*1.2],line=2,thick=thick
     oplot,[bandcentre,bandcentre],[0,max(response)*1.2],line=6,thick=thick
  endif


  return, bandcentre


end
