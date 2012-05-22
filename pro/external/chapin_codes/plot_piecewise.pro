;------------------------------------------------------------------------------
; plot_piecewise.pro: procedure for overplotting piecewise data
; 
; Required Inputs:
;
; x           = independent variable
; y           = dependent variable
;
; Optional Inputs:
;
; piece_index = index of 1 and 0 to define which elements of x / y to use
; rangetol    = size of jump in x to consider for periodic function 
; ytol        = same as rangetol, but looks for jumps in y
;
;------------------------------------------------------------------------------

pro plot_piecewise, x, y, piece_index=piece_index, rangetol=rangetol, $
                    ytol=ytol, _EXTRA=extra

  n = n_elements(x)
  startpiece=0
  endpiece=0

  ; If we're just checking for jumps in x (periodic function)
  if( keyword_set(rangetol) )then begin
    diff = abs(x(1:n-1)-x(0:n-2))  ; all the step sizes between points

    jumps = where(diff ge rangetol)
    if jumps(0) ne -1 then $
      segments = [transpose([0,jumps+1]),transpose([jumps,n-1])] $
    else segments = [0,n-1]  ; If no jumps, 1 segment   
  endif

  ; Jumps in the y direction
  if( keyword_set(ytol) )then begin
    diff = abs(y(1:n-1)-y(0:n-2))  ; all the step sizes between points

    jumps = where(diff ge ytol)
    if jumps(0) ne -1 then $
      segments = [transpose([0,jumps+1]),transpose([jumps,n-1])] $
    else segments = [0,n-1]  ; If no jumps, 1 segment
    
  endif

  ; If we have a piece_index defining the pieces:
  flag = 0

  if keyword_set(piece_index) then begin

    startpiece = (where(piece_index(0:n-1) eq 1))(0)  ; Initial indices
    if startpiece ne -1 then begin
      endpiece = (where(piece_index(startpiece:n-1) eq 0))(0)
      if endpiece ne -1 then begin
        endpiece = endpiece+startpiece 
        if not(keyword_set(rangetol)) then $ ; If we don't check jumps
          segments = [startpiece,endpiece-1] $
        else begin                           ; Checking jumps in segment
          if endpiece gt (startpiece+2) then begin
            diff = abs(x(startpiece+1:endpiece-1) - $
                       x(startpiece:endpiece-2))
            jumps = where(diff ge rangetol) 
          endif $
          else jumps = -1

          if jumps(0) ne -1 then $
            segments = [transpose([startpiece,startpiece+jumps+1]), $
                        transpose([startpiece+jumps,endpiece-1])] $
          else segments = [startpiece,endpiece-1] ; If no jumps
        endelse
      endif $
      else flag = 1
    endif $
    else flag = 1
    
    while flag eq 0 do begin
      ; We now have the indices for a segment, add to the list

      if not(keyword_set(rangetol)) then $ ; If we don't check jumps
        segments = transpose( [transpose(segments), $
                              transpose([startpiece,endpiece-1])] ) $
      
      else begin                           ; Checking jumps in segment
        if endpiece gt (startpiece+2) then begin
          diff = abs(x(startpiece+1:endpiece-1) - $
                     x(startpiece:endpiece-2))
          jumps = where(diff ge rangetol)
        endif $
        else jumps = -1

        if jumps(0) ne -1 then begin
          segjumps = [transpose([startpiece,startpiece+jumps+1]), $
                      transpose([startpiece+jumps,endpiece-1])] 
          segments = transpose([transpose(segments),transpose(segjumps)])
        endif $
        else $ ; If no jumps
          segments = transpose( [transpose(segments), $
                                 transpose([startpiece,endpiece-1])] )
      endelse
 

      startpiece = (where(piece_index(endpiece:n-1) eq 1))(0)   ; new start
      if startpiece eq -1 then flag = 1 $
      else begin 
        startpiece = startpiece+endpiece
        endpiece = (where(piece_index(startpiece:n-1) eq 0))(0) ; new end
        if endpiece eq -1 then flag = 1 $
        else endpiece = endpiece + startpiece
      endelse
     
    endwhile

    segjumps=0

    if startpiece ne -1 then begin  ; do the last piece if it exists
      if endpiece eq -1 then endpiece = n
      
      if keyword_set(rangetol) then begin
        if endpiece gt (startpiece+2) then begin
          diff = abs(x(startpiece+1:endpiece-1) - $
                     x(startpiece:endpiece-2))
          jumps = where(diff ge rangetol)
        endif $
        else jumps = -1

        if jumps(0) ne -1 then $
          segjumps = [transpose([startpiece,startpiece+jumps+1]), $
                        transpose([startpiece+jumps,endpiece-1])] 
      endif

      if not(keyword_set(segments)) then begin
        if keyword_set(segjumps) then segments = segjumps $
        else segments = [startpiece,endpiece-1]
      endif $
      else begin
        if not(keyword_set(segjumps)) then $
          segments = transpose( [transpose(segments), $
                                transpose([startpiece,endpiece-1])] ) $
        else $
          segments = transpose( [transpose(segments), $
                                transpose(segjumps)] )
      endelse

    endif

  endif

  ; Now we have the segments, plot them:

  if keyword_set(segments) then $
    for i=0, n_elements(segments(0,*))-1 do $
      oplot,x(segments(0,i):segments(1,i)), $
            y(segments(0,i):segments(1,i)), _EXTRA=extra

end
