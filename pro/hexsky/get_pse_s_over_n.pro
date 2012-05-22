function get_pse_s_over_n,clfile,NET,NEQ,fwhm_arcmin,tobs,fsky,ndet,$
                          band_edges=band_edges,bmode=bmode

   ;AUTHOR: S. Leach
   ;PURPOSE: Estimate the signal to noise of bandpower estimates.

   ;clfile is a Cl fits file in uK^2
   ;tobs is the total integration time in seconds.
   ;fsky is the fraction of sky
   ;ndet is the total number of detectors
   ;NET is the NET in uK.sqrt(sec)
   ;NEQ is the NEQ in uK.sqrt(sec)
   ;fwhm_arcmin is the FWHM of the beam in arcmin.
   ;band_edges are the nband+1 abscissae in l for the bandpowers.

   if(n_elements(band_edges) eq 0) then band_edges=[200,300,400,500,600,700,800,900,1000,1100,1200]

   ;------------
   ;Read in data
   ;------------
   fits2cl,cl,clfile,/silent
   lmax        = n_elements(cl(*,0))-1
   ll          = lindgen(lmax+1)
   
   ;----------------------------
   ;Selection of bandpower edges
   ;----------------------------
;   lmin        = round(fsky^(-1)/4.)   ; From Bowden et al 2004 - Just after equation 14.
;   lmax        = round(!pi/(fwhm_arcmin/60.*!dtor))
;   band_edges = lmin + lmin*lindgen(round((lmax-lmin)/lmin)+1)

   ;-----------------------------
   ;Work out expected noise level
   ;-----------------------------
   inverse_weight_TT = NET^2*fsky*4.*!pi/tobs/float(ndet)
   inverse_weight_EE = NEQ^2*fsky*4.*!pi/tobs/float(ndet)
   Nl_TT             = inverse_weight_TT/gaussbeam(fwhm_arcmin,lmax)^2
   Nl_EE             = inverse_weight_EE/gaussbeam(fwhm_arcmin,lmax)^2
   
   ;---------------------------------------------------
   ;Define bands and count number of modes in each band
   ;---------------------------------------------------
   nband    = n_elements(band_edges)-1
   l_mean   = make_array(nband,value=0.)
   delta_l  = make_array(nband,value=0.)
   n_modes  = make_array(nband,value=0.)
   for bb = 1,nband do begin
       l_mean[bb-1]   = round((band_edges[bb]+band_edges[bb-1])/2.)
       delta_l[bb-1]  = band_edges[bb]-band_edges[bb-1]
       ell            = dindgen(band_edges[bb]-band_edges[bb-1]+1) + double(band_edges[bb-1])
       n_modes[bb-1]  = total(2.*ell+1.,/double)*fsky
   endfor
   
   ;-----------------------------------
   ;Work out delta(Cl)/Cl for each band
   ;-----------------------------------
   dcl_over_cl_ee = make_array(nband,value=0.)
   dcl_over_cl_bb = make_array(nband,value=0.)
   for bb = 1,nband do begin
       dcl_over_cl_ee[bb-1] = sqrt(2./n_modes[bb-1])*(1.+Nl_EE[l_mean[bb-1]]/cl(l_mean[bb-1],1))
       dcl_over_cl_bb[bb-1] = sqrt(2./n_modes[bb-1])*(1.+Nl_EE[l_mean[bb-1]]/cl(l_mean[bb-1],2))
   endfor

   if(keyword_set(bmode)) then begin
      total_s_over_n = sqrt(total((1./dcl_over_cl_bb)^2))
   endif else begin
      total_s_over_n = sqrt(total((1./dcl_over_cl_ee)^2))
   endelse
   ;------------
   ;Plot results
   ;------------
   if 0 then begin
      window,4
      plot,ll,cl(*,1),xtitle='Multipole l',ytitle='E mode C!Dl!N ['+textoidl('\muK^2')+']',charsize=1.6,$
           title='f!Dsky!N = '+number_formatter(fsky,dec=4)+$
           ', NEQ = '+number_formatter(NEQ,dec=1)+textoidl(' \muK s^{1/2}'),$
           yrange=[min(cl(200:max(band_edges),1))*0.9,max(cl(*,1))*2],ystyle=2,/ylog,xrange=[1,max(band_edges)+100]
      oplot,ll,nl_ee,line=2
      al_legend,['E mode signal','Estimated noise level = '+number_formatter(nl_ee[0],dec=5)],line=[0,2],box=0,charsize=1.6
      al_legend,['Total S/N = '+number_formatter(total_s_over_n,dec=1)],box=0,/bottom,/left,charsize=1.8
      oploterror,l_mean,cl[l_mean,1],delta_l/2.,cl[l_mean,1]*dcl_over_cl_ee/2.,psym=2
   endif
   
   return,total_s_over_n

   
end
