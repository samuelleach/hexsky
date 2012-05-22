pro test_get_bandcentre


  nabs                 = 20
  ntop                 = nabs/4
  nu                   = 130 + dindgen(nabs)/(nabs-1)*50
  response             = make_array(nabs,value=0.)

  ps_start,file='band.ps'
  
  response[nabs/4:nabs/4+ntop] = 1./ntop
  bandcentre = get_bandcentre(nu,response,bandwidth=bandwidth)
  print,bandcentre,abs(bandwidth),abs(bandwidth)/bandcentre

;  response = exp(- ((nu-150.)/(0.02*150.))^2/2.)
;  bandcentre = get_bandcentre(nu,response,bandwidth=bandwidth)
;  print,bandcentre,abs(bandwidth),abs(bandwidth)/bandcentre

  
  readcol,!HEXSKYROOT+'/data/band_150.txt',nu,response
  bandcentre = get_bandcentre(nu,response,bandwidth=bandwidth)
  print,bandcentre,abs(bandwidth),abs(bandwidth)/bandcentre

  readcol,!HEXSKYROOT+'/data/band_250.txt',nu,response
  bandcentre = get_bandcentre(nu,response,bandwidth=bandwidth)
  print,bandcentre,abs(bandwidth),abs(bandwidth)/bandcentre

  readcol,!HEXSKYROOT+'/data/band_410.txt',nu,response
  bandcentre = get_bandcentre(nu,response,bandwidth=bandwidth)
  print,bandcentre,abs(bandwidth),abs(bandwidth)/bandcentre


  readcol,!HEXSKYROOT+'/data/blast_500um.dat',nu,response
  nu = 3e5/nu
  bandcentre = get_bandcentre(nu,response,bandwidth=bandwidth)
  print,bandcentre,abs(bandwidth),abs(bandwidth)/bandcentre

  readcol,!HEXSKYROOT+'/data/blast_350um.dat',nu,response
  nu = 3e5/nu
  bandcentre = get_bandcentre(nu,response,bandwidth=bandwidth)
  print,bandcentre,abs(bandwidth),abs(bandwidth)/bandcentre

  readcol,!HEXSKYROOT+'/data/blast_250um.dat',nu,response
  nu = 3e5/nu
  bandcentre = get_bandcentre(nu,response,bandwidth=bandwidth)
  print,bandcentre,abs(bandwidth),abs(bandwidth)/bandcentre




  ps_end

end
