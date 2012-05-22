pro plot_ebex_trajectory

  ;AUTHOR: S. Leach
  ;PURPOSE: Make a plot of the EBEX NA flight trajectory over NM.

  csbfdatafile  = !HEXSKYROOT+'/data/csbf_ebex_trajectory_11june09.dat'
  
  statenames = ['CA', 'OR', 'WA', 'AZ', 'UT', 'ID','NM','TX','UT','CO','NV','OK']
  nstates    = n_elements(statenames)
  limit      = [29, -120, 38., -100]
  
;  Window, XSize=700, YSize=800

  filename='ebex_trajectory_nograt2.ps'
  ps_start,filename=filename;,landscape=0
  Map_Set, 33, -110, /IsoTropic, Limit=limit,$
;    Position=[0.02, 0.02, 0.98, 0.98],/continents,/hires;,/albers
   Position=[0.05, 0.05, 0.95, 0.95],/continents,/hires;,/albers
  DrawStates,Statenames = statenames, Thick=4.5, $
    Colors = make_array(nstates,value='indian red'), $
    Fill   = make_array(nstates,value=0)

  ;  Map_Grid,lats=28+findgen(18)*2,lons=-122+findgen(20)*2,$
  ;    /Box_Axes, charsize=0.85,/no_grid
  
  readcol,csbfdatafile,hr,mnt,sec,BAR_ALT,MBS,AIRT,DRAD,$
    LAT_deg,lat_mnt,LON_deg,LON_mnt,GPS_ALT
  LAT = LAT_deg + sign(lat_deg)*LAT_mnt/60.
  LON = LON_deg + sign(lon_deg)*LON_mnt/60.
  
  ;Plot trajectory
  oplot, lon,lat,thick=6.5,color=FSC_Color('navy'),line=6
  ;Plot starting point at Ft Sumner
  oplot, make_array(2,value=lon[0]),make_array(2,value=lat[0]),$
	 color=FSC_Color('maroon'),psym=sym(1)
  xyouts,lon[0]-1.16,lat[0]-0.32,['Ft Sumner'],color=FSC_Color('maroon'),charsize=0.9

  ;Plot Winslow downrange station
  winslow_lon= -110.70
  winslow_lat=   35.02 
  oplot, make_array(2,value=winslow_lon),make_array(2,value=winslow_lat),$
	 color=FSC_Color('maroon'),psym=sym(1)
  xyouts,winslow_lon-0.94,winslow_lat-0.38,['Winslow'],color=FSC_Color('maroon'),charsize=0.9


  ;Plot state capitals
  statecap_lat = [35.+5./60.  ,35.+11./60.  ,33.+29./60]
  statecap_lon = [-106.-39/60.,-101.-50./60.,-112.-4./60.]  
  oplot, statecap_lon,statecap_lat,$
	 color=FSC_Color('navy'),psym=sym(5)
  xyouts,statecap_lon-0.25,statecap_lat+0.25,['Albuquerque','Amarillo','Phoenix'],$
	  charsize=0.8

  ;Plot state names
  placename     = ['New Mexico','Texas','Arizona']
  placename_lon = statecap_lon + [-1.3,-0.2,-0.9]
  placename_lat = statecap_lat + [1.,-2.7,2.]
  xyouts,placename_lon,placename_lat,placename,charsize=1.4
  xyouts,-119.5,35,'California',charsize=1.4  

  ;Title
  xyouts,-116.2,38.7+0.25,'EBEX Test Flight, 11!Uth!N June 2009',charsize=1.6,$
	  color=FSC_Color('navy')

  ;Scale
  oplot,[-119.7,-119.7+3.50],[30.23,30.45],thick=5.5
  xyouts,-118.7,30.4,'200 miles',charsize=0.8
  
  ps_end

 spawn,'cp '+filename+' /u/ap/leach/public_html/ebex'
  
end
