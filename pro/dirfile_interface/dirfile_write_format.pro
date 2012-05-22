pro dirfile_write_format, dirfile

  ;AUTHOR: S. Leach
  ;PURPOSE: To write the dirfile format information into a
  ;         dirfile format file. An existing format file is overwritten.
  ;         dirfile is a {dirfile} struct.

  formatfilename = dirfile.name+'/format'

  ; Write comments in format file
  openw,lun,formatfilename,/get_lun
  printf,lun,'# This is a dirfile format file.'
  printf,lun,'# It was written using an IDL dirfile interface.'
  timestring='# Written on '+systime()
  if !version.os_family eq 'unix' then begin
      spawn,'whoami',  username
      spawn,'uname -n',machinename
      timestring = timestring+' by '+username+'@'+machinename+'.'
  endif
  printf,lun,timestring

  ; Write GetData-like references
  ;/VERSION 6
  ;/ENDIAN little
  ;/PROTECT none
  ;/ENCODING none
  ;/REFERENCE RA
  printf,lun,'/ENDIAN '+endian()
  

  ;Write entries
  for ee=0,dirfile.n_entries-1 do begin
      printf,lun,dirfile.gd_entry_t[ee].field+' '+$
        dirfile.gd_entry_t[ee].field_type+' '+$
        dirfile.gd_entry_t[ee].field_string
  endfor

  free_lun,lun

end
