pro write_na_commands

  missionfile = !HEXSKYROOT+'/schedulefiles/na_mission.par'
  mission     = read_parameterfile(missionfile)
  
  year  = 2009
  month = 5
  day   = 1
  reference_date = [year,month,day]

;  write_saturn_commands,reference_date,mission

  write_jupiter_commands,reference_date,mission

  
end