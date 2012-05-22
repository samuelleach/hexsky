pro gd_entry_t__define

  ;AUTHOR: S. Leach
  
  ;See struct _gd_unified_entry in src/getdata.h
  
  data = { GD_ENTRY_T, $
	field: ' ',$
	field_type: ' ',$; Should be GD types (byte).
	field_string: ' ',$; Invented by SL.
	fragment_index: 0,$
	;RAW
        spf: 0$;Deal with this later      	  
	}  

end
