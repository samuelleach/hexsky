function WRITEFIELD, dirfile, field, data


;AUTHOR: S. Leach
;PURPOSE: Test wrapper for writing dirfile RAW data- to be developed.
;         Similar in spirit to readfield.pro. Should be used to dump
;         large chunks of data to disk, otherwise may not be lightning
;         fast. On exit dirfile is a dirfile struct.

; EXAMPLE: data = dindgen(100)
;          error= writefield('test','RA',data)
  
;Check to see if data is 1d array


;Test to see if dirfile is a string or a struct.
  case Size(dirfile, /TNAME) of
    'STRUCT':       ;Assumed to be a dirfile struct.
    'STRING': begin ;Assumed to be a dirfile filename
      formatfilename = dirfile+'/format'
      if file_exists(formatfilename) then begin
	dirfile = dirfile_get_format(dirfile)
      endif else begin
	spawn,'mkdir -p '+dirfile
	name = dirfile
	dirfile = {dirfile}
	dirfile.name = name
      endelse
    end
  endcase

;Test to see if dirfile RAW field exists
  field_type='RAW'
  spf=1
  index = where(dirfile.gd_entry_t[*].field eq field)
  if index[0] eq -1 then begin
    ;Add entry to dirfile
    ee = dirfile.n_entries
    dirfile.n_entries                 = dirfile.n_entries+1
    dirfile.gd_entry_t[ee].field      = field
    dirfile.gd_entry_t[ee].field_type = field_type
    field_string = getdata_type_converter(value = data[0])
    
    ;RAW INFO
    dirfile.gd_entry_t[ee].field_string = field_string+' '+strtrim(spf,2)
    
    ;Append or write format line to format file
    if dirfile.n_entries gt 1 then begin
      formatfilename = dirfile.name+'/format'
      openw,lun,formatfilename,/get_lun,/append
      printf,lun,dirfile.gd_entry_t[ee].field+' '+$
	      dirfile.gd_entry_t[ee].field_type+' '+$
	      dirfile.gd_entry_t[ee].field_string
      free_lun,lun
    endif else begin
      dirfile_write_format,dirfile
    endelse
  endif

  ;Write data
  outfile = dirfile.name+'/'+field
  openw, lun, outfile, /get_lun, /append
  writeu, lun, data
  free_lun, lun


  err=0
  return,err
end
