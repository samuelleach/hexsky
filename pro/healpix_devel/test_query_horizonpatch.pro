pro test_query_horizonpatch

  nside = 128
  minel = 30
  maxel = 60
;  minaz = -135
;  maxaz = 135

  targetaz = 360
  minaz    = -45 + targetaz
  maxaz    =  45 + targetaz
    

  query_horizonpatch,nside,minel,maxel,minaz,maxaz,listpix,npix

  map = make_array(nside2npix(nside),value=0)
  map[listpix] = 1
  mollview,map,window=1,grat=[15,15],glsize=1.5;,ps='test.ps'


end


