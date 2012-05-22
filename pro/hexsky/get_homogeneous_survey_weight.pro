function get_homogeneous_survey_weight,fsky_percent,net_muksqrtsec,tobs_sec,ndet


  ;AUTHOR:  S. Leach
  ;PURPOSE: Return the weight in [muK.arcmin]^-1 of a homogeneous 
  ;         noise survey.

  rad_per_arcmin = 2.*!pi/360./60.

  weight = tobs_sec * float(ndet) / net_muksqrtsec^2 / ( fsky_percent/100. * 4. * !pi)
  weight = sqrt(weight) * rad_per_arcmin

  return, weight


end


pro test_get_homogeneous_survey_weight


  net   = 193.33
  fsky  = 0.2 + 0.05*dindgen(30) 
  t_obs = 12.6*24.*3600.
  ndet  = 388*2

  weight = get_homogeneous_survey_weight(fsky,net,t_obs,ndet)
;  print,weight
  plot, weight, fsky/100.*41253., chars=1.5,ytitle=textoidl('f_{sky} [%]'),$
        xtitle=textoidl('Survey weight [(\muK.arcmin)^{-1}]'),xrange=[0,max(weight)],xstyle=2

  asc_read,'surveydata_cmb_scan_0.54.dat',sqrt_tint,depth,area,fsky

;  oplot,depth,fsky
  oplot,depth,area

  window,1
  plot,sqrt_tint,area


end
