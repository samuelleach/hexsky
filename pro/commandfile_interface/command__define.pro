pro command__define

  ;AUTHOR: S. Leach
  ;PURPOSE: This is where the command struct information gets defined.

  ;Notes: Need to make scanning code aware of time_to_next_command. This parameter
  ;       should act as the maximum amount of samples to be outputted by hexsky.
  
  command = { COMMAND,$
	      name : ' ',$
	      parameters : make_array(15,value=0.),$
	      nparameters : 0S,$
              comment : ' ',$
	      time_to_next_command : 0E,$
	      expected_duration : 0E,$
              first_sample_index : 0L,$
              nsample            : 0L$
	   }
  
end
