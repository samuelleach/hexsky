pro hexsky_write_pointing,dirfile_in,file_out,approx_sample_freq_out_hz


  ;AUTHOR: S. Leach
  ;PURPOSE: Write pointing to an ascii file (exchange file for 
  ;         at Columbia)

  if (not dirfile_fieldexists(dirfile_in,'AZ_SUN')) then begin
     message,'Warning: AZ_SUN field does not exist in dirfile '+dirfile_in,/contintue
     message,'Please run hexsky_write_sunazel_fields.pro'
  endif
  

  fields  = ['RJD','AZ','EL','AZ_SUN','EL_SUN','LON','LAT']
  nfields = n_elements(fields) 
  print, 'Reading data from dirfile ',dirfile_in
  data    = readfields(dirfile_in,fields)

;  RJD_INIT      = floor(data[0,0])
;  data[0,*] = data[0,*] - RJD_INIT
;  RJD_INIT = 0d0


  nsamp = n_elements(data[0,*])
  fsamp = ((data[0,1]-data[0,0])*24.*3600.)^(-1)

  compression_factor = fsamp/approx_sample_freq_out_hz
  nsamp_compressed   = floor(nsamp/compression_factor)
  data_compressed    = make_array(nsamp_compressed,nfields,value=0d0)

  print,'Compressing samples by a factor '+strtrim(compression_factor,2)
  for ff = 0, nfields-1L do begin
     data_compressed[*,ff] = congrid(reform(data[ff,*]),nsamp_compressed)
  endfor

  print,'Writing data to '+file_out
  asc_write,file_out,data_compressed[*,0],$
    data_compressed[*,1]*!radeg,data_compressed[*,2]*!radeg,$
    data_compressed[*,3],data_compressed[*,4],$
    data_compressed[*,5],data_compressed[*,6],$
    header = '# RJD0 = '+strtrim(double(!constant.rjd0)) ;+double(RJD_INIT))


end
