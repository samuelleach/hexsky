pro test_convert_utcschedule_to_lstschedule

  ;AUTHOR: S. Leach
  ;PURPOSE: Test the conversion of a "UTC" schedule file to an "LST"
  ;         file (and back again).

  
  schedulefile = !HEXSKYROOT+'/schedulefiles/cmb_example_0.4.sch'
  missionfile  = !HEXSKYROOT+'/missionfiles/ldb_mission.par'
;  missionfile  = !HEXSKYROOT+'/missionfiles/ldb_mission_orbit.par'
  mission      = read_parameterfile(missionfile)


  ;Reference date that the guys have been using in their LST schedule files.
;  day   = 20  & month = 09 &  year  = 2008  
;  day   = 15  & month = 12 &  year  = 2011  
  day   = 1  & month = 12 &  year  = 2011  
  convert_utcschedule_to_lstschedule,schedulefile,'test_lst.sch',mission,[year,month,day]
  
  
  lstschedule = read_schedulefile('test_lst.sch')
  jd          = get_jd_from_lstschedule(lstschedule,mission,lon=lon)

  utcschedule = read_schedulefile(schedulefile)
  jd2         = get_jd_from_utcschedule(utcschedule)
  get_earthpos_from_utcschedule,utcschedule,mission,lon2,lat2


  print,'DJD'
  print,jd2-jd
  window,0
  plot,jd2-jd,ytitle='dJD',chars=1.5

  print,'DLON'
  print,lon2-lon
  window,1
  plot,lon2-lon,ytitle='dLON',yrange=minmax(lon2-lon)+[-10,10],chars=1.5




  day   = 1
  month = 12
  year  = 2011
  timezone = 0

  convert_lstschedule_to_utcschedule,'test_lst.sch','test_utc.sch',$
                                     missionfile,[year,month,day]
  

end
