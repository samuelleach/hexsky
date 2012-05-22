pro dirfile__define

  ;AUTHOR: S. Leach
  ;PURPOSE: This is where the dirfile struct gets defined.
  
  ;See internal.h in the getdata src/ directory.

  NMAXENTRIES=2000
  entry = {gd_entry_t}
  
  data = { DIRFILE, $
	;Error reporting
        error : 0,$
;        ;Field count
	n_entries : 0,$
;        n_string : 0,$
;	n_const : 0,$
;        n_meta : 0,$
	;Directory name
	name : ' ',$
	;Endian type
	endian : ' ',$
	;Entries
	gd_entry_t:make_array(NMAXENTRIES,value=entry)$	
	}  

;<field-name> BIT <input> <first-bit> [ <bits> ]
;<field-name> CONST <type> <value>
;<field-name> LINCOM <n> <field1> <a1> <b1> [ <field2> <a2> <b2> [ <field3> <a3> <b3> ]]
;<field-name> LINTERP <input> <table>
;<field-name> MULTIPLY <field1> <field2>
;<field-name> PHASE <input> <shift>
;<field-name> RAW <type> <sample-rate>
;<field-name> STRING <value>


end
