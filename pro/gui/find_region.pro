PRO FIND_REGION,lat_deg,lon_deg,tz,year,month,day,hour,minute,$
                rot_code=rot_code,rot_ang = rot_ang,$
                missionfile=missionfile,$
                _extra = extra,field=field,color_field=color_field,$
                show_visibility=show_visibility,$
                utcschedfile=utcschedfile

   ;Author : C.Bao, S. Leach
   ;Purpose: Find out available patch of sky for observation
   ;         at given location and time (constraints set for
   ;         EBEX) and outline the region on top of desired map

   if n_elements(missionfile)     eq 0 then missionfile     = !HEXSKYROOT+'/schedulefiles/na_mission.par'
   if n_elements(show_visibility) eq 0 then show_visibility = 0


   mission          = read_parameterfile(missionfile)

   minel_calibrator = mission.elevation_calibrator_lowerlimit_deg
   minel            = mission.elevation_lowerlimit_deg
   maxel            = mission.elevation_upperlimit_deg

   horizon_at_float = -10.
   moon_constraint  = mission.antimoon_constraint_deg
   tolerance        = 180.- [mission.antimoon_constraint_deg,mission.antisun_constraint_deg]

   juldate,[year,month,day,hour,minute,0],jd
   jd = double(jd - tz/24.) + 2400000d
   jd2lst,jd,lon_deg,lst

   
   loadct,39
   yellow = FSC_Color("yellow")
   white  = FSC_Color("white")
   black  = FSC_Color("black")
   pink   = FSC_Color("pink")
   green  = FSC_Color("green")
   maroon = FSC_Color("maroon")
   gray   = FSC_Color("gray")

   Coord =['C','C'] 
   if show_visibility then begin
      map   = get_visibilitymap(jd,24.,lon_deg,lat_deg,minel=minel,maxel=maxel,tolerance=tolerance)
      units = 'hr/day (max: '+number_formatter(max(map),dec=1)+')'
      map(where(map eq 0.))= !healpix.bad_value
      max = 24.
   endif else begin
      dustfreq = 150
      inmap    = !HEXSKYROOT+'/data/dust_carlo_150ghz_512_radec.fits'
      factor   = conversion_factor('uK_RJ','uK_CMB',dustfreq)
      nested   = 0 &    max=2000
      read_fits_map,inmap,map
      map      = map*factor       ; Convert from RJ to Thermodynamic units
      units    = textoidl('\muK_{CMB}')
   endelse

   
   sunpos,jd,sun_ra,sun_dec
   moonpos,jd,moon_ra,moon_dec
   
   eq2hor,sun_ra,sun_dec,jd,sun_alt,sun_az,lat=lat_deg,lon=lon_deg
   eq2hor,moon_ra,moon_dec,jd,moon_alt,moon_az,lat=lat_deg,lon=lon_deg


   sun      = outline_circle(sun_ra,sun_dec,8.)
   moon     = outline_moonpos(jd,diameter=5.)
;   moon_gc  = outline_moonpos(jd,diameter=2.*moon_constraint)
   antimoon = outline_antimoon(jd,lat_deg,lon_deg,constraint=moon_constraint,el_lower=minel,el_upper=maxel)
   antimoon_planet = outline_antimoon(jd,lat_deg,lon_deg,constraint=moon_constraint,el_lower=minel_calibrator,el_upper=maxel)
;   ecliptic = outline_ecliptic()
   saturn   = outline_planet('SATURN',jd,diameter=1.5) 
   jupiter  = outline_planet('JUPITER',jd,diameter=1.5) 
   mars     = outline_planet('MARS',jd,diameter=3.) 
   uranus   = outline_planet('URANUS',jd,diameter=3.) 
   cena     = outline_target('cena',2.5)
   rcw38    = outline_target('rcw38',5.)
   vycma    = outline_target('vycma',5.)
   mat5a    = outline_target('mat5a',2.5)
   pks0537441 = outline_target('pks0537-441',2.5)
   iras08576  = outline_target('iras08576',2.5)
   iras1022   = outline_target('iras1022',2.5)
   ngc3576    = outline_target('ngc3576',2.5)
   gp         = outline_galacticplane()
   gc         = outline_circle(266.43,-29.0,4.) ; Galactic centre

   quad_ba       = outline_survey('quad_brightarm')
   quad_fa       = outline_survey('quad_faintarm')
   bicep_gal     = outline_survey('bicep_galactic')
   atlas_south23 = outline_survey('herschel_atlas_south_23hr')
   atlas_south2  = outline_survey('herschel_atlas_south_2hr')
   b2k_deep      = outline_survey('boomerang_deep')
   spt87         = outline_survey('spt_87sqdeg')

   sparo1        = outline_target('ngc6334',2.5)
   sparo2        = outline_target('carina_nebula',2.5)
   sparo3        = outline_target('G333.6-0.2',2.5)
   sparo4        = outline_target('G331.5-0.1',2.5)


   if n_elements(rot_ang) eq 0 then begin
      hor2eq,90.,0.,jd,zenith_ra,zenith_dec,lat=lat_deg,lon=lon_deg
      rot_ang = [zenith_ra,zenith_dec,0.]
   endif
 
   if sun_alt ge horizon_at_float then begin

      antisun        = outline_antisun(jd,lat_deg,lon_deg,el_lower=minel,el_upper=maxel)
      antisun_planet = outline_antisun(jd,lat_deg,lon_deg,el_lower=minel_calibrator,el_upper=maxel)
      
      if moon_alt ge horizon_at_float then begin
         field       = [sun,antimoon,antimoon_planet,gp,gc,moon,antisun,antisun_planet]  
         color_field = [yellow,gray,     gray,        black,black, white, 12,     12]
      endif else begin
         field       = [sun,gp,gc,moon,antisun,antisun_planet]  
         color_field = [yellow,black,black,white,   12,    12]
      endelse

   endif else begin
 
       lat_20 = outline_lat(jd,minel_calibrator,lat_deg,lon_deg)
       lat_30 = outline_lat(jd,minel,lat_deg,lon_deg)
       lat_60 = outline_lat(jd,maxel,lat_deg,lon_deg)

       if moon_alt ge horizon_at_float then begin 
           field       = [sun,lat_20,lat_30,lat_60,antimoon,antimoon_planet,gp,gc,moon];,moon_gc] 
           color_field = [yellow,0,     0,     0,     gray,     gray,         black,black, white];, 120]
       endif else begin
           field       = [sun,lat_20,lat_30,lat_60,gp,gc,moon] 
           color_field = [yellow,0,     0,     0,     black,black, white]
       endelse

   endelse

   if tz eq 0 then begin
      timezone_string = ''
   endif else if tz lt 0 then begin
      timezone_string = '-'+strtrim(fix(abs(tz)),2)
   endif else if tz gt 0 then begin
      timezone_string = '+'+strtrim(fix(tz),2)
   endif
     

   title = strtrim(string(month),2)+'/'+strtrim(string(day),2)+'/'+$
           strtrim(string(fix(year)),2)+' '+int2filestring(hour,2)+':'+$
           int2filestring(minute,2)+' LT (UTC'+timezone_string+')'+$ 
           ', LST='+number_formatter(lst,dec=3);+$

   subtitle = 'Sun, Moon elevation [deg] = ['+$
	     number_formatter(sun_alt)+', '+$
	     number_formatter(moon_alt)+'], '+$
	     '[Lon,Lat]=['+number_formatter(lon_deg,dec=1)+$
	     ','+number_formatter(lat_deg,dec=1)+']'


;   ;Highbay door and artificial planet
;   highbay             = outline_annulus(75.,95.,30.,52., $
;                                         jd=jd,lon_deg=lon_deg,lat_deg=lat_deg, $
;                                         /convert_azel_to_radec)
;   artificial_planet   = outline_annulus(84.5,85.5,46.,47., $
;                                         jd = jd,lon_deg=lon_deg,lat_deg=lat_deg, $
;                                         /convert_azel_to_radec)
;   field = [field,highbay,artificial_planet] & color_field = [color_field,110,110] 


   ;Supernovae remnants
;   casa    = outline_target('casa',0.75)      & field = [field,casa]   & color_field = [color_field,pink] 
;   kepler  = outline_target('keplersnr',0.75) & field = [field,kepler] & color_field = [color_field,pink] 
;   tycho   = outline_target('tychosnr',0.75)  & field = [field,tycho]  & color_field = [color_field,pink] 

   ;Archeops clouds
;   get_archeops_cloud_data,ra=ra,dec=dec,area=area
;   diameter = sqrt(4.*area/!pi)
;   for ff = 0 ,n_elements(ra)-1 do begin
;      outline  = outline_circle(ra[ff],dec[ff],diameter[ff]) & field = [field,outline] & color_field = [color_field,230] 
;   endfor

;   ;HII regions
;   hii_region_read,ra,dec,S_jy,theta_arcmin
;   for ff = 0 ,n_elements(ra)-1 do begin
;      outline  = outline_circle(ra[ff],dec[ff],theta_arcmin[ff]/60.) & field = [field,outline] & color_field = [color_field,green] 
;   endfor


   ;Display Maxima region
;   maxima = outline_file(!HEXSKYROOT+'/data/MAXIMA.dat')
;   field  = [field,maxima] & color_field = [color_field,200]

   ; Display approximation to schedule
   if n_elements(utcschedfile) gt 0 then begin
      schedule         = read_schedulefile(utcschedfile)
      schedule_outline = outline_schedule(schedule,mission,noutline=noutline)
      field = [field,schedule_outline] & color_field = [color_field,make_array(noutline,value=maroon)]
   endif

   ; Display planets and other targets
   field       = [field,saturn,jupiter,mars,uranus,cena,quad_ba,quad_fa,$
                  bicep_gal,atlas_south23,atlas_south2,b2k_deep,spt87,$
                  pks0537441,iras08576,iras1022,ngc3576,rcw38,vycma,mat5a,$
	          sparo1,sparo2,sparo3,sparo4]
   color_field = [color_field,pink,pink,pink,pink,green,yellow,yellow,$
                  yellow,yellow,yellow,yellow,yellow,$
                  230,230,230,230,230,230,230,$
		  green,green,green,green]


   ;Make plot
   skyview,map,field = field,color_field=color_field,$
           rot_ang =rot_ang , proj = 'moll',max=max,$
           grat=[15.,15.],/glsize,title=title,subtitle=subtitle,$
           _extra = extra,units=units,iglsize=1.4
   


END   
