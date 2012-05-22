function getdata_type_converter, type_in=type_in,value=value

;AUTHOR: S. Leach
;PURPOSE: to convert between IDL and GetData type handles. Use as input either
;         type_in (an IDL or GetData type) or value (some data).

if (n_elements(type_in) ge 1) and (n_elements(value) ge 1) then begin
  print,'getdata_type_converter.pro: Error- use one of either type_in or value'
  stop
endif

if (n_elements(type_in) ge 1) then begin
  tt = type(type_in)
endif else if (n_elements(value) ge 1) then begin
  tt=2
  type_in = type(value)
endif
  
undefined='UNDEFINED'
getdata_type=[undefined,'UINT8','INT16','INT32','FLOAT32','FLOAT','FLOAT64',$
	      'DOUBLE',undefined,undefined,undefined,undefined,undefined,undefined,$
	      'UINT16','UINT32','INT64','UINT64','u','U','s','S','c','d']

binary_type=[0,1,2,3,4,4,5,5,6,7,8,9,10,11,12,13,14,15,12,13,2,3,1,5] ; As used by read_binary.pro
; See eg. http://idlastro.gsfc.nasa.gov/idl_html_help/SIZE.html

;* UINT8: unsigned 8-bit integer    
;* INT8: signed 8-bit integer       **Can be handled by read_binary.pro ?
;* UINT16: unsigned 16-bit integer  
;* INT16: signed 16-bit integer     
;* UINT32: unsigned 32-bit integer  
;* INT32: signed 32-bit integer     
;* UINT64: unsigned 64-bit integer  
;* INT64: signed 64-bit integer     
;* FLOAT32 or FLOAT: IEEE-754 standard 32-bit (single precision) floating point number
;* FLOAT64 or DOUBLE: IEEE-754 standard 64-bit (double precision) floating point number 


case tt of
  7: begin ; String: type is a GetData type.
       index = where(getdata_type eq type_in)
       if index[0] ne -1 then begin
	 type_out=binary_type[index]
       endif else begin
	 print,'getdata_type_converter.pro: type not implmented.'
	 stop
       endelse
     end
  2: begin ; Integer: type in is an integer
       index = where(binary_type eq type_in)
       if index[0] ne -1 then begin
	 type_out=getdata_type[index]
       endif else begin
	 print,'getdata_type_converter.pro: type not implmented.'
	 stop
       endelse
     end
   else: begin
     print,'getdata_type_converted.pro: type not implmented.'
     stop
   end
 endcase

return, type_out[0]

end
