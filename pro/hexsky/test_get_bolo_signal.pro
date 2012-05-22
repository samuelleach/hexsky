pro test_get_bolo_signal

  tsamp   = 0.002d0
  taubolo = 0.009d0

  signal          = make_array(500,value=0.)
  signal          = [signal,make_array(1000,value=1.)]
  signal(580:600) = 2

  bolo_signal     = get_bolo_signal(signal,tsamp,taubolo)

  nsamp = n_elements(bolo_signal)
  time  = findgen(nsamp)*tsamp
  plot,time,signal,chars=1.5,xtitle='Time',ytitle='Signal'
  oplot,time,bolo_signal,psym=4

  window,1
  plot,time,bolo_signal,xrange=[480*tsamp,520*tsamp],psym=4,chars=1.5,xtitle='Time',ytitle='Signal'
  oplot,time,signal

  window,2
  plot,time,bolo_signal,xrange=[570*tsamp,610*tsamp],psym=4,chars=1.5,xtitle='Time',ytitle='Signal'
  oplot,time,signal

;  print,bolo_signal


  
end
