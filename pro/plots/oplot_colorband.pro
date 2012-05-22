pro oplot_colorband,x,ylower,yupper,cptct,cptctdir=cptctdir,nband=nband


  if (n_elements(cptctdir) eq 0 ) then cptctdir = !HEXSKYROOT+'/pro/data/cpt-city/' 
  if (n_elements(cptct) eq 0 ) then cptct = 'Red_White' 
  if (n_elements(nband) eq 0 ) then nband = 200 

  colortable =  cptctdir+cptct+'.cpt'
  tvlct,vis_cpt2ct(colortable)

;  tvlct,vis_cpt2ct('GMT_gray.cpt')
;  tvlct,vis_cpt2ct('GMT_gebco.cpt')
;  tvlct,vis_cpt2ct('GMT_ocean.cpt')
;  tvlct,vis_cpt2ct('Cyan_Transparent.cpt')
;  tvlct,vis_cpt2ct('Cyan_White.cpt')
;  tvlct,vis_cpt2ct('Red_White.cpt')
;  tvlct,vis_cpt2ct('Fire.cpt')
;  tvlct,vis_cpt2ct('yellow.cpt')
;  tvlct,vis_cpt2ct('sky-blue.cpt')

  
  for nn = 0, nband-1l do begin
     if (nn lt floor(float(nband)/2.)) then begin
        color = 256 - floor(float(2.*nn*256)/float(nband-1))
     endif else begin
        color = floor(float(2*(nn-float(nband)/2.)*256)/float(nband-1))
     endelse
     oplot, x, ylower + (yupper-ylower)*float(nn)/(float(nband)-1.),thick=4,color=color
  endfor

  loadct,0


end
