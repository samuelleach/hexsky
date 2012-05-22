FUNCTION parfile_to_cl2pf_format,parameterfile,modulename

  ;AUTHOR: S. Leach
  ;PURPOSE: Convert a name = value parameter file into cl2pf format.
  ;          eg  IDL> parfile_to_cl2pf_format,'example.par','cat'
  ;              Takes a parameter file example.par which contains:          
  ;              name = value
  ;              and prints out
  ;              cl2pf --name value


  ;Read the parameters
  parameters= read_parameterfile(parameterfile)

  
  ;Build the cl2pf string
  string='cl2pf '+modulename
  tags = tag_names(parameters)
  for ii = 0, n_elements(tags)-1 do begin
    if n_elements(parameters.(ii)) gt 1 then $
	val = fltarr2string(parameters.(ii)) else $
	val = strtrim(string(parameters.(ii),/print),2)
    
    ;Search for '__' in parameter name, and replace with parentheses.
    name=strlowcase(tags[ii])
    j = strpos(name,'__') 
    if j ne -1 then begin
        strreplace,name,'__','\('
        name = name+'\)'
    endif

    ;Search for '_ampersand_' in parameter name, and replace with '\&'.
    j = strpos(name,'_ampersand_') 
    if j ne -1 then begin
        strreplace,name,'_ampersand_','\&'
    endif

    ;Search for space in parameter values
    value = parameters.(ii)
    j     = strpos(value,' ') 
    if j ne -1 then begin
        value='"'+value+'"'
    endif
        
    string=string+' --'+name+' '+value;parameters.(ii)
  endfor

  return, string

  

end
