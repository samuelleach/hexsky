pro idljobs

  schedule_shift,'june12_flightplan1.sch','june13_flightplan1_tmp.sch',23.934
  schedule_shift,'june12_flightplan2.sch','june13_flightplan2_tmp.sch',23.934
  schedule_shift,'june12_flightplan3.sch','june13_flightplan3_tmp.sch',23.934
	
  
  if 0 then begin
  
  mission   = read_parameterfile('na_mission.par')
;  shift     = 48. + [-2.,-1.5,-1,-0.5,0.,0.5,1,1.5,2.,2.5]
;  shift     = 48. + [8.5,9.,9.5,10,10.5,11.,11.5,12.]
;  shift     = 5.*24. + [-2.,-1.5,-1.,-0.5,0.,0.5,1.0,1.5]
  shift     = 7.*24. + [3,3.5,4.,4.5,5,5.5,6.,6.5]
  ref_day   = 20
  ref_month = 9
  ref_year  = 2008


  string = ['1','2','3','4','5','6','7','8','9','10']  
  alt= 46.5 & az = 85.
  lon= -104.233 & lat = 34.467
  yr = 2009 & mn = 5 & day = 22  
  satscan = [12.66,13.00,14.,14.33]
  command = [2,3,6,7]
  tz =  -6.
  for ss=0,n_elements(shift) -1 do begin
     newschedfile = 'may29_flightsimulation_'+$
                   string[ss]+'.sch'

     schedule_shift,'may22_flightsimulation1.sch',$
                    newschedfile,shift[ss],shift_ra=1

     sched = read_schedulefile(newschedfile)

    for ii = 0, n_elements(satscan)-1 do begin
       hr = satscan[ii]+shift[ss]
       JDCNV, YR, MN, DAY, hr-tz, JULIAN
       hor2eq,alt,az,julian,ra  ,dec,lon=lon,lat=lat
       print,string[ss],' '+number_formatter((satscan[ii]+shift[ss]) mod 24.,dec=3),$
             ' '+number_formatter(ra/15.,dec=3),' '+number_formatter(dec,dec=3)

       sched.command[command[ii]].parameters[2]= ra/15.
       sched.command[command[ii]].parameters[3]= dec

    endfor
    write_schedulefile,newschedfile,sched
    convert_utcschedule_to_lstschedule,newschedfile,$
                                       '../../schedulefiles/ebextest'+number_formatter(ss+1)+'.sch',$
                                       mission,[ref_year,ref_month,ref_day]
    
  endfor

  endif
  
  skipdetectors=3
  
  if 0 then begin
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_may25.sch'
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_may26.sch'
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_may27.sch'
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_may28.sch'
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_may29.sch'
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_may30.sch'
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_may31.sch'
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_june1.sch'
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_june2.sch'
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_june3.sch'
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_june4.sch'
  hexsky_test_driver,schedulefile='schedulefiles/jupiter_june5.sch'
  end

;  hexsky_test_driver,schedulefile='schedulefiles/saturn_may15.sch'
;  hexsky_test_driver,schedulefile='schedulefiles/saturn_may16.sch'
;  hexsky_test_driver,schedulefile='schedulefiles/saturn_may17.sch'
;  hexsky_test_driver,schedulefile='schedulefiles/saturn_may18.sch'
;  hexsky_test_driver,schedulefile='schedulefiles/saturn_may19.sch'
;  hexsky_test_driver,schedulefile='schedulefiles/saturn_may20.sch'
;  hexsky_test_driver,schedulefile='schedulefiles/saturn_may21.sch'
;  hexsky_test_driver,schedulefile='schedulefiles/saturn_may22.sch'
;  hexsky_test_driver,schedulefile='schedulefiles/saturn_may23.sch'
;  hexsky_test_driver,schedulefile='schedulefiles/saturn_may24.sch'
;  hexsky_test_driver,schedulefile='schedulefiles/saturn_may25.sch',$
;		      skipdetectors=skipdetectors



end
