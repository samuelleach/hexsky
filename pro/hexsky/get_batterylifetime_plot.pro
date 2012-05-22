pro get_batterylifetime_plot,psfile,dirfile,$
                             solar_module_temp_celsius=solar_module_temp_celsius,$
                             pointingfile=pointingfile

  ;AUTHOR: S. Leach
  ;PURPOSE: Make a plot showing the battery lifetime.

  if(n_elements(pointingfile) eq 0) then pointingfile= 'test.dat'
  if(n_elements(solar_module_temp_celsius) eq 0) then solar_module_temp_celsius = 110.

  
  approx_freq_hz  = 0.02 
  outpointingfile = pointingfile+'.bat'


  ;-----------------------------------------------------------------------
  ; Write the Sun az and el to the pointing dirfile if not already present
  ;-----------------------------------------------------------------------
  mydirfile = dirfile
  hexsky_write_sunazel_fields,mydirfile,/moonazel

  ; Write the dirfile pointing to a ascii file for use
  ; with the battery simulation code
  mydirfile = dirfile
  hexsky_write_pointing,mydirfile,pointingfile,approx_freq_hz
   
  ; Run the battery simulation code
  command = !HEXSKYROOT+'/python/batterySimulation.py '+pointingfile+' '+outpointingfile+' '+$
            number_formatter(long(solar_module_temp_celsius))
  message,'Spawning: '+command,/continue
  spawn,command

  ; Read in the data and plot
  readcol,outpointingfile, ACS_percent,BOLO_percent,ACS_time,BOLO_time
  readcol,pointingfile,    JD,pointingAZ,pointingEL,sunAZ,sunEL,lon,lat

  ps_start,file=psfile

  red    = fsc_color('red')
  blue   = fsc_color('blue')
  green  = fsc_color('green')
  brown  = fsc_color('brown')
  violet = fsc_color('violet')

  title = 'Start date, location: '+jd2dateandtime(!constant.rjd0+jd[0])+$
          ', ['+number_formatter(lon[0],dec=1)+$
          ', '+number_formatter(lat[0],dec=1)+']'
  plot,jd,acs_percent*100.,line=6,xtitle='RJD [day]',ytitle=' ',/nodata,thick=3,chars=1.5,$
       xthick=2,ythick=2,yrange=[-20,180],ystyle=1,title=title

  ra     = readfields(dirfile,'RA')
  dec    = readfields(dirfile,'DEC')  
  rjd    = readfields(dirfile,'RJD')  
  azmoon = readfields(dirfile,'AZ_MOON')  
  elmoon = readfields(dirfile,'EL_MOON')  
  elsun  = readfields(dirfile,'EL_SUN')  
  az     = readfields(dirfile,'AZ')
  nsamp  = n_elements(ra[0,*])
  
  ;DOWNSAMPLE HERE JD here
  sample_rate        = ((rjd[1]-rjd[0])*24.*3600)^(-1) ; Hz
  target_sample_rate = 0.1                             ; Hz
  compression_factor = sample_rate/target_sample_rate
  nsamp_compressed   = floor(nsamp/compression_factor)
  rjd_compressed     = congrid(reform(rjd),nsamp_compressed)
  ra_compressed      = congrid(reform(ra),nsamp_compressed)
  dec_compressed     = congrid(reform(dec),nsamp_compressed)
  az_compressed      = congrid(reform(az),nsamp_compressed)
  azmoon_compressed  = congrid(reform(azmoon),nsamp_compressed)
  elmoon_compressed  = congrid(reform(elmoon),nsamp_compressed)
  elsun_compressed   = congrid(reform(elsun),nsamp_compressed)

  euler, ra_compressed*!radeg,dec_compressed*!radeg,lon,lat,1
  oplot, rjd_compressed, abs(lat),line=6,color=violet,thick=3
  oplot, rjd_compressed, elsun_compressed,line=2,color=green,thick=3
  oplot, rjd_compressed, elmoon_compressed,line=2,color=brown,thick=3
  oplot, rjd_compressed, abs(modpos(Az_compressed*!radeg-(azmoon_compressed+180.),wrap=180,/zero_cent)),$
         line=6,color=brown,thick=3
  oplot,jd,abs(modpos(pointingAz-(sunaz+180.),wrap=180,/zero_cent)),line=6,color=green,thick=3
  oplot, jd, acs_percent*100,line=6,color=red,thick=3
  oplot, jd, bolo_percent*100,line=6,color=blue,thick=3


  
  al_legend, ['ACS batteries [%]','Bolo batteries [%]',$
           '|Az - (Sun Az + 180)| [deg]',$
           'Sun el [deg]',$
           '|Az - (Moon Az + 180)| [deg]',$
           'Moon el [deg]',$
           '|Gal. Lat.| [deg]'],$
          color=[red,blue,green,green,brown,brown,violet],$
          /top,/right,box=0,line=[6,6,6,2,6,2,6],thick=5

  ps_end

end
