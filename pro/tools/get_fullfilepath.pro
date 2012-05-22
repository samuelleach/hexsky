FUNCTION GET_FULLFILEPATH,filename

;  AUTHOR: S. Leach
;  PURPOSE: Returns the full path of a file.

  dir = cwd()

  fullfilepath = dir+'/'+filename

  strreplace,fullfilepath,'/./','/'
  strreplace,fullfilepath,'//','/'
  
  return,fullfilepath

end