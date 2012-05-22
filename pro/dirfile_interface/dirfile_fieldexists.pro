FUNCTION dirfile_fieldexists,dirfile,field

  ;AUTHOR: S. Leach
  ;PURPOSE: Check whether a field exists in a dirfile (format file).

  
  format   = dirfile_get_format(dirfile)  
  infield  = format.gd_entry_t.field
  index    = where(field eq infield) 

  field_exists = 0
  if index[0] ne -1 then begin
     field_exists = 1
  endif

  return,field_exists

end
