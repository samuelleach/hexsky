function dirfile_get_format, dirfilename

  ;AUTHOR: S. Leach
  ;PURPOSE: To read an existing dirfile format file into a
  ;         dirfile struct (see dirfile__define.pro)

  dirfile_format      = {dirfile}
  dirfile_format.name = dirfilename
  formatfilename      = dirfilename+'/format'

  ;;Reads the file discarding empty lines and lines which begin with '#'
  line = ''
  openr, 1, formatfilename
  iline = 0

  field_number = -1
  while (not EOF(1)) do begin
    readf,1,line
    iline = iline + 1
    line = strtrim(line,2)
    if strlen(line) ge 1 then begin
      i = strpos(line,' ')
      if i eq -1 then begin
	close,1
	message,'Syntax error in dirfile format file at line '$
		 + strtrim(iline,2) + ' : ' + line
      endif
      case strmid(line, 0, 1) of
	'#':  ; Comments - ignore.
	'/': begin ; Dirfile info.
	  line = strmid(line,1)
	  i = strpos(line,' ')	  
	  case strmid(line, 0, i) of
	    'ENDIAN': begin
	      dirfile_format.endian=strmid(line, i+1)
	    end
	    else:
	  endcase
	end
	else: begin ; Dirfile fields.
	  field_number = field_number + 1
	  dirfile_format.gd_entry_t[field_number].field = strmid(line, 0, i)
	  line=strmid(line,i+1)
	  i = strpos(line,' ')	  
	  dirfile_format.gd_entry_t[field_number].field_type = strmid(line, 0, i)
	  line=strmid(line,i+1)
	  i = strpos(line,' ')	  
	  dirfile_format.gd_entry_t[field_number].field_string = strmid(line, 0)
	endelse
      endcase
    endif
  endwhile
  close, 1

  dirfile_format.n_entries=field_number+1
  
return,dirfile_format

end
