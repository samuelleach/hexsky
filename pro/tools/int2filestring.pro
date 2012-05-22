function int2filestring, int,nchar

;Function to convert an integer to string.

;eg int2filestring, 15,3
; returns the string '015'
  
  
  outstring = strtrim(fix(int),2)

  if int eq 0 then begin
    nzero = nchar -1
  endif else begin
    nzero = nchar - floor(alog10(float(int))) - 1
  endelse

  
  for ii=1,nzero do begin
    outstring='0'+outstring
  end
  
  return,outstring
  
end
