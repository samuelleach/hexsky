pro hexsky_example


  ;AUTHOR: S. Leach
  ;PURPOSE: Quick start code to demonstrate the hexsky driver program.


  ;Simulate a 'UTC' style schedule file (hexsky internal format)
  hexsky_test_driver,schedulefile='schedulefiles/cmb_calib_example.sch',/boresight,output='output_hexsky',$
		      missionfile='missionfiles/ldb_mission.par'

  ;Simulate a 'LST' style schedule file (scheduler format)
  hexsky_test_driver,schedulefile='schedulefiles/cmb_battsim1.sch',/boresight,output='output_battsim1',$
		      missionfile='missionfiles/ldb_mission.par',/lstschedule

  
end
