pro asc_append,file,string

  ;AUTHOR: S. Leach
  ;PURPOSE: Append a line of ascii to a an ascii file.

  openw,lun,file,/get_lun,/append
  printf,lun,string
  free_lun,lun

end
