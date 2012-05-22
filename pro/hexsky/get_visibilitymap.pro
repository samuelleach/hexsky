pro test_get_visibilitymap

  nside = 32
  yr  = 2012
  day = 15
  hr  = 0

  mn  = 13
  JDCNV, YR, MN, DAY, HR, JULIAN0

  mn  = 12
  JDCNV, YR, MN, DAY, HR, JULIAN1


  mn  = 6
  JDCNV, YR, MN, DAY, HR, JULIAN2

  
  ;ALMA site
  lon   = 68. + 45./60. + 11.44/3600. 
  lat   = - (23. + 1./60. + 9.42/3600.)
  minel = 45.
  maxel = 90

  jd0   = julian1
  map1 = get_visibilitymap(jd0,24,lon,lat,minel=minel,maxel=maxel,nside=nside)
  jd0   = julian2
  map2 = get_visibilitymap(jd0,24,lon,lat,minel=minel,maxel=maxel,nside=nside)


  ;McMurdo (balloon-borne)
  lon   = 100.
  lat   = -77.8
  minel = 30.
  maxel = 60

  ;EBEX
  jd0   = julian1
  map3 = get_visibilitymap(jd0,24,lon,lat,minel=minel,maxel=maxel,nside=nside)
  jd0   = julian0
  map4 = get_visibilitymap(jd0,24,lon,lat,minel=minel,maxel=maxel,nside=nside)
  ;SPIDER
  tol = [45.,90.]
  minel = 28.
  maxel = 40
  jd0   = julian1
  map7 = get_visibilitymap(jd0,24,lon,lat,minel=minel,maxel=maxel,nside=nside,tol=tol)
  jd0   = julian0
  map8 = get_visibilitymap(jd0,24,lon,lat,minel=minel,maxel=maxel,nside=nside,tol=tol)
  

  ;South pole (ground based)
  lon   = 100.
  lat   = -89.9
  minel = 45.
  maxel = 90

  jd0   = julian1
  map5 = get_visibilitymap(jd0,24,lon,lat,minel=minel,maxel=maxel,nside=nside)
  jd0   = julian2
  map6 = get_visibilitymap(jd0,24,lon,lat,minel=minel,maxel=maxel,nside=nside)

  
  units = 'hr/day'
  chars= 1.5
  outlinemoon = outline_moonpos(julian1,diameter=15)
  outlinesun = outline_sunpos(julian1,diameter=25)
  mollview,map1,coord=['C','G'],outline=[outline_galacticplane(),outlinemoon,outlinesun],$
    units=units,title='Atacama visibility in December 15',chars=chars,png='december15_act.png'
  outlinemoon = outline_moonpos(julian2,diameter=15)
  outlinesun = outline_sunpos(julian2,diameter=25)
  mollview,map2,coord=['C','G'],outline=[outline_galacticplane(),outlinemoon,outlinesun],$
    units=units,title='Atacama visibility in June 15',chars=chars,png='june15_act.png'
  
  write_fits_map,'december15_act.fits',map1,order='ring'
  write_fits_map,'june15_act.fits',map2,order='ring'
  write_fits_map,'december15_ebex.fits',map3,order='ring'
  write_fits_map,'jan15_ebex.fits',map4,order='ring'
  write_fits_map,'december15_spider.fits',map7,order='ring'
  write_fits_map,'jan15_spider.fits',map8,order='ring'
  write_fits_map,'december15_spt.fits',map5,order='ring'
  write_fits_map,'june15_spt.fits',map6,order='ring'



  outlinemoon = outline_moonpos(julian1,diameter=15)
  outlinesun = outline_sunpos(julian1,diameter=25)
  mollview,map3,coord=['C','G'],outline=[outline_galacticplane(),outlinemoon,outlinesun],$
    units=units,title='EBEX visibility in December 15',chars=chars,png='december15_ebex.png'
  outlinemoon = outline_moonpos(julian0,diameter=15)
  outlinesun = outline_sunpos(julian0,diameter=25)
  mollview,map4,coord=['C','G'],outline=[outline_galacticplane(),outlinemoon,outlinesun],$
    units=units,title='EBEX visibility in January 15',chars=chars,png='jan15_ebex.png'

  outlinemoon = outline_moonpos(julian1,diameter=15)
  outlinesun = outline_sunpos(julian1,diameter=25)
  mollview,map7,coord=['C','G'],outline=[outline_galacticplane(),outlinemoon,outlinesun],$
    units=units,title='SPIDER visibility in December 15',chars=chars,png='december15_spider.png'
  outlinemoon = outline_moonpos(julian0,diameter=15)
  outlinesun = outline_sunpos(julian0,diameter=25)
  mollview,map8,coord=['C','G'],outline=[outline_galacticplane(),outlinemoon,outlinesun],$
    units=units,title='SPIDER visibility in January 15',chars=chars,png='jan15_spider.png'

  
  outlinemoon = outline_moonpos(julian1,diameter=15)
  outlinesun = outline_sunpos(julian1,diameter=25)
  mollview,map5,coord=['C','G'],outline=[outline_galacticplane(),outlinemoon,outlinesun],$
    units=units,title='SPT visibility in December 15',chars=chars,png='december15_spt.png'
  outlinemoon = outline_moonpos(julian2,diameter=15)
  outlinesun = outline_sunpos(julian2,diameter=25)
  mollview,map6,coord=['C','G'],outline=[outline_galacticplane(),outlinemoon,outlinesun],$
    units=units,title='SPT visibility in June 15',chars=chars,png='june15_spt.png'
  

  
end


function get_visibilitymap,jd0,duration_hr,lon,lat,tolerance=tolerance,$
                           minel=minel,maxel=maxel,targetsetel=targetsetel,$
                           nside=nside,vismap_firsthalf=vismap_firsthalf

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns a Healpix map showing the visibility in hours of
  ;         the sky from jd0 to jd0+duration_hr/24

  if n_elements(minel) eq 0       then minel = 30.
  if n_elements(maxel) eq 0       then maxel = 60.
  if n_elements(targetsetel) eq 0 then targetsetel = -10.
  if n_elements(nside) eq 0       then nside = 16
  if n_elements(tolerance) eq 0   then tolerance   = [45.,135.] ; Moon and Sun tolerance
  target      = ['moon','sun']
  
  vismap   = make_array(nside2npix(nside),value=0.)
  nstep = 300
  jd    = jd0 + findgen(nstep)/float(nstep-1)*duration_hr/24. 

  
  ;Loop over time steps
  counter = 0.
  for hh = 0, n_elements(jd) -1L do begin
     ;Loop over targets
     for tt = 0,n_elements(target)-1 do begin
        query_antitargetregion, jd[hh], lon, lat, target[tt], tolerance[tt],$
                                minel,maxel,targetsetel, nside, temp_listpix
        if tt eq 0 then begin
           listpix = temp_listpix
        endif else begin
           intersection = Setintersection(listpix,temp_listpix)
           if intersection[0] ne -1 then begin
              listpix = intersection
           endif else begin
              delvarx,listpix
           endelse
        endelse           
     endfor

     npix = n_elements(listpix)
     if npix[0] ne -1 then begin
        counter = counter + 1.0
        for pp = 0L , npix-1 do begin 
           vismap[listpix[pp]] = vismap[listpix[pp]] + 1.
        endfor
     endif

     ; Save vismap of first half of the visibility period
     if (hh + 1 eq floor(nstep/2)) then begin
        vismap_firsthalf = vismap
     endif

  endfor

  vismap_firsthalf = vismap_firsthalf/counter*duration_hr
  vismap           = vismap/counter*duration_hr
  return,vismap

end
