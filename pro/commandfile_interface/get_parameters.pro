function get_parameters,command_string,nparameters=nparameters

  ;AUTHOR: S. Leach
  ;PURPOSE: Extract an array of parameters (floats) from a command string

;  read_schedulefile,'temp/happy.mid.sch',commands,skip=1
;  commands=commands(*,where(commands(0,*) eq 'box'))
;  command=commands(*,0)
;  print,get_parameters(command)

  parameter_string = command_string[1] 

  i                = strpos(parameter_string,'#')
  if (i  gt -1) then parameter_string =strmid(parameter_string, 0, i)

  parameter_array = strsplit(parameter_string,/extract)  
  nparameters     = n_elements(parameter_array)
  return,float(parameter_array)

end
