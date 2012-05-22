pro warning__define

  ;AUTHOR: S. Leach
  ;PURPOSE: This is where the warning struct information gets defined.
  ;         The warning is supposed to have an integer definition (type),
  ;         an index (another integer), several float parameters,
  ;         and a readable message string.
  
  warning = { WARNING,$
	      type      : 0,$
	      index     : 0,$
	      parameter : make_array(3,value=0.),$
              message   : ' '$
	   }
  
end
