function read_parameterfile, file

  ;AUTHOR: S. Leach
  ;PURPOSE: Converts a name=value parameter file into a struct.

  ;USAGE:
  ;eg If a file test.par contains
  ;
  ; year = 2009
  ; hour = 16.
  ;
  ; then run
  ; IDL>  par = read_parameterfile('test.par')
  ; IDL>  print, par.hour
  ;   16.  
  ; IDL>  print, par.year
  ;   2009  

  ;;Reads the file discarding empty lines
  ;;and lines which begin with '#'
  line   = ""
  table  = ['','']
  openr, 1, file
  iline  = 0
  while (not EOF(1)) do begin
    readf,1,line
    iline = iline+1
    line  = strtrim(line,2)
    if strmid(line, 0, 1) ne '#' and strlen(line) ge 1 then begin
      i = strpos(line,'=')
      j = strpos(line,'#') 
      if i eq -1 then begin
        close,1
        message,'Syntax error in parameter file at line ' + strtrim(iline,2) + ' : ' + line
      endif
      ;Get the parameter name
      key = strmid(line, 0, i)
                          
      ;Check for parentheses, remove and replace with '__' 
      mm = strpos(key,'(')
      nn = strpos(key,')');eg file(1) -> file__1 
      if mm ne -1 then begin
          strreplace,key,'(','__'
          strreplace,key,')',''
      end

      ;Check for '&', replace with '_ampersand__' 
      mm = strpos(key,'&')
      if mm ne -1 then begin
         strreplace,key,'&','_ampersand_'
      end

      ;Get the parameter value
      if j eq -1 then begin
;          val=strmid(line, i+1) ; Buggy for gdl0.9rc3
          val = strmid(line, i+1,2000)
      endif else begin
          val = strmid(line, i+1,j-i-1); Removes comment that is appended eg:  name = value # My comment 
      endelse

      table = [[table],[key,val]]
    endif
  endwhile
  close, 1
  
  table = table[*,1:*]

  ;-------------------------------
  ;Make the table into a structure
  ;-------------------------------
  npar = size(table)
  if(npar[0] eq 1) then begin
     npar = 1
  endif else begin
     npar = npar[2]
  endelse

  parameter_struct = create_struct(strtrim(table[0,0],2),strtrim(table[1,0],2))

  for tt= 1,npar-1 do begin
      parameter_struct = create_struct(parameter_struct,strtrim(table[0,tt],2),strtrim(table[1,tt],2))
  endfor

;  ;Add parameterfile filename to struct 
;  parameter_struct= create_struct(parameter_struct,'parameterfile_filename',file)
  
  return,parameter_struct
  
end
