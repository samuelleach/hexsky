pro warning_message,message,type=type,index=index,parameter=parameter,$
                    warning_file=warning_file,warning=warning,$
                    silent=silent
  

  ;AUTHOR:  S. Leach
  ;PURPOSE: Print out a warning statement.

  if n_elements(type)      eq 0 then type = 0     
  if n_elements(index)     eq 0 then index = 0     
  if n_elements(parameter) eq 0 then parameter = 0.

  wparam                 = make_array(3,value=0.)
  nparameter             = n_elements(parameter)
  wparam[0:nparameter-1] = parameter

  warning           = {warning}
  warning.message   = message
  warning.type      = type
  warning.type      = index
  warning.parameter = wparam

  if (not keyword_set(silent)) then begin
     print,'WARNING: '+message
  endif

  warning_string = number_formatter(type) +' '+number_formatter(index) +' '+number_formatter(wparam[0],dec=4) +' '+$
                   number_formatter(wparam[1],dec=4) +' '+number_formatter(wparam[2],dec=4) + ' # '+message

  ;------------------------------------
  ;Append the warning to a warning file
  ;------------------------------------
  if n_elements(warning_file) gt 0 then  asc_append,warning_file,warning_string


end

pro test_warning_message

  maxel = 62.5
  type  = 1
  index = 2
  warning_message,'Elevation too high',warning_file='WARNING_readme',type=type,index=index,parameter=maxel


end
