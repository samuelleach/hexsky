function endian
  ; PURPOSE: Ascertains the byte storage of the machine (little
  ;          or big endian).
  ; Taken from http://www.dfanning.com/tips/endian_machines.html.

  little_endian = (BYTE(1, 0, 1))[0]

  IF (little_endian) THEN begin
    my_endian='little'
  endif else begin
    my_endian='big'
  endelse

  return,my_endian
end
