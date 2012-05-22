function get_comment,command_string

  parameter_string = command_string(1) 

  i = strpos(parameter_string,'#')
  if (i  gt -1) then begin
      comment_string =strmid(parameter_string, i+1)
  endif else begin
      comment_string = ''
  endelse

  return,comment_string

end
