function GET_DETECTORPAIR

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns detector struct with the boresight and
  ;         one adjacent detector.

  pair =  make_array(2,value={detector})
  pair.power = 1
  pair.channel = 150

;  pair[1].az = 24./60. * !pi/180.
  pair[1].az = 32./60. * !pi/180.

  return,pair

end
