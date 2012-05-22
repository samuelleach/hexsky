pro estimate_pse_s_over_n,clfile,integrationtimefile,NET,NEQ,fwhm_arcmin,$
                          band_edges=band_edges,make_homogeneous=make_homogeneous
  
   ;AUTHOR: S. Leach
   ;PURPOSE: Estimate the signal to noise of bandpower estimates.

   ;clfile is a Cl fits file in uK^2
   ;hitmapfile is a Healpix map of hit counts.
   ;time_per_sample is the time per sample in seconds.
   ;NET is the NET in uK.sqrt(sec)
   ;NEQ is the NEQ in uK.sqrt(sec)
   ;fwhm_arcmin is the FWHM of the beam in arcmin.
   ;band_edges are the nband+1 abscissae in l for the bandpowers.

   if(n_elements(band_edges) eq 0) then band_edges = [20,100,200,300,400,500,600,700,800,900,1000,1100,1200]

   ;------------
   ;Read in data
   ;------------
   read_fits_map,integrationtimefile,tint,nside=nside
   npixtot     = float(nside2npix(nside))
   index       = where(tint gt 0.)
   npix        = float(n_elements(index))
   fsky        = npix/npixtot

   ;------------------------------------------------------
   ; Spread out the integration time evenly within the map.
   ;------------------------------------------------------
   if(keyword_set(make_homogeneous)) then begin
      tint[index] = total(tint[index],/double)/npix
   endif

   ;------------------------------------------
   ;Work out expected noise level and get fsky
   ;------------------------------------------
   fits2cl,cl,clfile
   lmax        = n_elements(cl(*,0))-1
   ll          = lindgen(lmax+1)
   
   ;----------------------------
   ;Selection of bandpower edges
   ;----------------------------
;   lmin        = round(fsky^(-1)/4.)   ; From Bowden et al 2004 - Just after equation 14.
;   lmax        = round(!pi/(fwhm_arcmin/60.*!dtor))
;   band_edges  = lmin + lmin*lindgen(round((lmax-lmin)/lmin)+1)

     
   ;---------------------
   ; Noise power spectrum
   ;---------------------
   Nl_TT = 4.*!pi*NET^2/npixtot^2*total(1.d0/tint(index),/double)
   Nl_EE = 4.*!pi*NEQ^2/npixtot^2*total(1.d0/tint(index),/double)
   beam  = gaussbeam(fwhm_arcmin,lmax)
   Nl_TT = NL_TT/beam^2
   Nl_EE = NL_EE/beam^2
   
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
   total_s_over_n_ee = sqrt(total((1./dcl_over_cl_ee)^2))
   total_s_over_n_bb = sqrt(total((1./dcl_over_cl_bb)^2))

   ;------------
   ;Plot results
   ;------------
   ;--------
   ; E-modes
   ;--------
   window,4
   plot,ll,cl(*,1),xtitle='Multipole l',$
        ytitle='E mode C!Dl!N ['+textoidl('\muK^2')+']',charsize=1.6,$
        title='f!Dsky!N = '+number_formatter(fsky,dec=4)+$
        ', NEQ = '+number_formatter(NEQ,dec=1)+textoidl(' \muK s^{1/2}'),$
        yrange=[min(cl(200:max(band_edges),1))*0.9,max(cl(*,1))*2],ystyle=2,/ylog,xrange=[1,max(band_edges)+100]
   oplot,ll,nl_ee,line=2
   al_legend,['E mode signal','Estimated noise level = '+number_formatter(nl_ee[0],dec=5)],line=[0,2],box=0,charsize=1.6
   al_legend,['Total S/N = '+number_formatter(total_s_over_n_ee,dec=1)],box=0,/bottom,/left,charsize=1.8
   oploterror,l_mean,cl[l_mean,1],delta_l/2.,cl[l_mean,1]*dcl_over_cl_ee,psym=2
   
   ;--------
   ; B-modes
   ;--------
   window,3
   plot,ll,cl(*,2),xtitle='Multipole l',$
        ytitle='B mode C!Dl!N ['+textoidl('\muK^2')+']',charsize=1.6,$
        title='f!Dsky!N = '+number_formatter(fsky,dec=4)+$
        ', NEQ = '+number_formatter(NEQ,dec=1)+textoidl(' \muK s^{1/2}'),$
        yrange=[min(cl(200:max(band_edges),2))*0.1,max(cl(*,2))*2],ystyle=2,/ylog,xrange=[1,1000] ;xrange=[1,max(band_edges)+100]
   oplot,ll,nl_ee,line=2
   al_legend,['B mode signal','Estimated noise level = '+number_formatter(nl_ee[0],dec=5)],line=[0,2],box=0,charsize=1.6
   al_legend,['Total S/N = '+number_formatter(total_s_over_n_bb,dec=1)],box=0,/bottom,/left,charsize=1.8
   oploterror,l_mean,cl[l_mean,2],delta_l/2.,cl[l_mean,2]*dcl_over_cl_bb,psym=2


   lmin = 2
   lmax = 2000
   beam = gaussbeam(fwhm_arcmin,lmax)
   covCl = make_array(lmax+1,3,value=0d0)

   for XX = 1,2 do begin
      for ell = lmin,lmax do begin
         covCl[ell,XX] = total(2.*npixtot/float(ell+1)*(cl[ell,XX] + 4.*!pi*NEQ^2/npixtot/beam[ell]^2/tint[index])^2,/double)
      endfor
   endfor

   window,2
   plot,ll,sqrt(covCl[*,1]),xrange=[1,1500],/xlog,/ylog,yrange=[1e-5,0.1]
   oplot,ll,cl[*,1]
   print,total(cl[lmin:lmax,1]/sqrt(CovCl[lmin:lmax,1]),/double)

   window,1
   plot,ll,sqrt(covCl[*,2]),xrange=[1,1000],/xlog,/ylog,yrange=[1e-8,0.1]
   oplot,ll,cl[*,2]



   
end
