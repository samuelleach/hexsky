function int2filestring, int,nchar

  outstring=strtrim(int,2)

  if int eq 0 then begin
    nzero = nchar -1
  endif else begin
    nzero=nchar-floor(alog10(float(int)))-1 
  endelse

  for ii=1,nzero do begin
    outstring='0'+outstring
  end
  
  return,outstring
  
end



FUNCTION ebex_scan

dt=0.0026214                       ; Time between samples
  ra0= 222.67                          
  dec0= 74.16 

bindir= '/scratch_local/catherine/EBEX_SCANS/'

nfiles=15L
ebex_ra  = fltarr(nfiles*65536)
ebex_dec = fltarr(nfiles*65536)
beta = fltarr(nfiles*65536)
az  = fltarr(nfiles*65536)
el  = fltarr(nfiles*65536)
lst = fltarr(nfiles*65536)

  for ii=0L,nfiles-1 do begin
    fs= int2filestring(ii,4)
  
    pointing= read_binary(bindir+'radecbeta_'+fs+'.bin',data_type=5)
    nsample=n_elements(pointing)/3L
    
    index=lindgen(nsample)*3L

    ebex_ra[ii*65536:65535+65536*ii] = pointing(index)  *!RADEG
    ebex_dec[ii*65536:65535+65536*ii] = pointing(index+1)*!RADEG
    beta[ii*65536:65535+65536*ii] = pointing(index+2)*!RADEG
  
    az[ii*65536:65535+65536*ii]= $
               read_binary(bindir+'az_fpc_'+fs+'.bin',data_type=4)*!RADEG
    el[ii*65536:65535+65536*ii]= $
               read_binary(bindir+'el_fpc_'+fs+'.bin',data_type=4)*!RADEG
    lst[ii*65536:65535+65536*ii]= $
               read_binary(bindir+'lst_'+fs+'.bin',data_type=4)*!RADEG

  endfor
 

;scan occurs with parameters:
;YEAR: 2009 MONTH: 5 (may) DAY: 1
;at FORT SUMMER
;LAT: 34.472 [deg] LONG(start): -104.246 [deg]
;

scan = {ra:ebex_ra, dec:ebex_dec, beta:beta, alt:el, az:az, lst:lst}

return, scan

END
