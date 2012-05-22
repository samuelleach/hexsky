function dmc2toi,object_name,$
                 object_type,$
                 cols          

; INPUTS:
; object_name   : <string> name of the input DMC object: 'TOODI%testl1%%nobstest_torsti:0%'
; object_type   : <string> name of the DMC object_type
; cols          : <long_integer_array> column numbers to be read: [2L,3L] time and data from DataDiff
; OUTPUTS:
; toi           : <double_array>


   manager=LSIO_MNG_CREATE ("TOODI%file")
   test=LSIO_HANDLE_NEW ()

   print,''
   print,'Object Type = ',object_type
   print,'Object Name = ',object_name

   LSIO_HANDLE_OPEN,test,object_name,object_type

   ncols = n_elements(cols)

   col_number = cols[0]
   col_len = LSIO_HANDLE_COLUMNLENGTH(test,col_number)

   print,'Read ',col_len,' rows.'

   apu = dblarr(col_len)
   toi = dblarr(col_len,ncols)

   for i = 0L,ncols-1 do begin
      col_number = cols[i]
      LSIO_HANDLE_READCOLUMN,test,col_number,apu
      toi[*,i] = apu
   end

   LSIO_HANDLE_CLOSE,test

   return,toi
   

end
