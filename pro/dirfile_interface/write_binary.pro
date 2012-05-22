pro write_binary,outfile,data

  ;AUTHOR: S. Leach
  ;PURPOSE: Intended to be a 'companion' to read_binary for writing binary data.

  openw,    lun, outfile, /get_lun, /append
  writeu,   lun, data
  free_lun, lun
  

end