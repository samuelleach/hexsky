function GET_BORESIGHT

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns detector struct with boresight informations

  boresight={detector}
  boresight.power = 1
  boresight.channel = 150

  return,boresight

end
