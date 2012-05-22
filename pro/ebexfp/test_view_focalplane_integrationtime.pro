pro test_view_focalplane_integrationtime


  fp         = get_na_wafer([150,250,410])  
  ndet       = n_elements(fp.el)

  fp.integration_time = 5. + randomn(4,ndet)

  view_focalplane_integrationtime,fp,'plot.ps'

end
