pro test_get_pse_s_over_n

  clfile       = !HEXSKYROOT+'/data/cl_WMAP-5yr_r0.05_lens.fits'
;  NEP          = 6e-17 ;W/sqrt(Hz)  ; From Hannes
;  NET          = NEP * 96./1.12e-17 ; Conversion factor from NA spec sheet.  ;193.33

  NET          = 500.   ; From Shaul  (for 150GHz; 700 for 250GHz)
  NEQ          = NET*sqrt(2.)
  fwhm_arcmin  = 8.
  tobs         = 6.*3600.
  ndet         = 75
  noise_factor = [1.,2.,4.]

  fsky        = 0.00002*(1.+findgen(75))
  nf          = n_elements(fsky)
  nn          = n_elements(noise_factor)
  s_over_n    = make_array(nf,nn,value=0.)

  for ss=0,nf-1 do begin
    for dd=0,nn-1 do begin
      s_over_n[ss,dd] = get_pse_s_over_n(clfile,NET*noise_factor[dd],$
				      NEQ*noise_factor[dd],fwhm_arcmin,$
				      tobs,fsky[ss],ndet)
    endfor
  endfor
  
  plot,fsky*41253.,s_over_n[*,0],charsize=1.7,$
	xtitle='Survey area [deg!U2!N]',ytitle='Total S/N on E mode power spectrum',$
	title='NEQ = '+number_formatter(NEQ,dec=1)+textoidl(' \muK s^{1/2}')+$
	', N!Ddet!N = '+strtrim(ndet,2)+$
	', t!Dobs!N = '+number_formatter(tobs/3600.,dec=1)+' hrs'
  
  legendtitle = make_array(nn-1,value='a')
  lines       = make_array(nn-1,value=1)
  for dd=1,nn-1 do begin
      line = dd
      oplot,fsky*41253.,s_over_n[*,dd],line=line
      legendtitle[dd-1] = 'x '+strtrim(fix(noise_factor[dd]),2)+' noise'
      lines[dd-1]       = line
  endfor
  al_legend,legendtitle,line=lines,box=0,/bottom,/right,charsize=1.7

;  saveimage,'PSE_S_OVER_N.png',/png
  
end
