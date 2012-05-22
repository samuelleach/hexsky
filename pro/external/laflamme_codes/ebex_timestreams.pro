PRO ebex_timestreams, nsamps=nsamps, lat=lat

if keyword_set(nsamps) eq 1 then nsamps=nsamps else nsamps = 50000.
if keyword_set(lat) eq 1 then lat=lat else lat = 34.472

;NUM is the number of samples you want in each timestream. The greater
;num is the more memory is used. Smaller num means more time.

timer = systime(/seconds)

scan = ebex_scan()
scope = ebex_bolos(lat)
n_bolos = n_elements(scope.alt[0,*])

total = n_elements(scan.ra)
n_streams = floor(total/float(nsamps))
num = strtrim(n_streams,2)
if file_test('/scratch_local/catherine/EBEX_SCANS/stream_'+num+'.dat') eq 0 then begin
print, 'Beginning to create streams'
delvarx, num

for i = 0, n_streams-1 do begin

num = strtrim(i,2)

pointing = ebex_pointing(scan.az[0+((nsamps+1)*i):nsamps*(i+1)],$
                          scan.alt[0+((nsamps+1)*i):nsamps*(i+1)], $
                          scan.lst[0+((nsamps+1)*i):nsamps*(i+1)],$
                         scan.beta[0+((nsamps+1)*i):nsamps*(i+1)], scope)

restore, '/scratch_local/catherine/SYNFAST/synfast_data.dat'

stream= make_synfast_timestream(pointing, data)

delvarx, data

save, stream, filename = $
     '/scratch_local/catherine/EBEX_SCANS/STREAM/stream_'+num+'.dat'

delvarx, stream, pointing
print, 'Finished: ',strtrim(i+1,2),' of ',strtrim(n_streams,2),' streams'

endfor

num = strtrim(n_streams,2)
pointing = ebex_pointing(scan.az[nsamps*n_streams+1:total-1],$
                           scan.alt[nsamps*n_streams+1:total-1], $
                           scan.lst[nsamps*n_streams+1:total-1], 
                           scan.beta[nsamps*n_streams+1:total-1], scope)

restore, '/scratch_local/catherine/SYNFAST/synfast_data.dat'

stream = make_synfast_timestream(pointing, data)

delvarx, data

save, stream, filename = $
        '/scratch_local/catherine/EBEX_SCANS/STREAM/stream_'+num+'.dat'


delvarx, pointing
delvarx, stream

endif

;for j = 0, n_bolos do begin

;stream_bolo[2700001:total-1] = stream[j,*]

;endfor

for j=0, n_bolos-1 do begin
stream_bolo = fltarr(total)

   for i = 0, n_streams-1 do begin
   index = strtrim(i,2)
   restore, '/scratch_local/catherine/EBEX_SCANS/stream_'+index+'.dat'

   stream_bolo[0+((nsamps+1)*i):nsamps*(i+1)]= stream.polarisation[j,*]

   delvarx, stream
   endfor

num = strtrim(n_streams,2)
restore, '/scratch_local/catherine/EBEX_SCANS/stream_'+num+'.dat'
stream_bolo[nsamps*n_streams+1:total-1] = stream.polarisation[j,*]

save, stream_bolo, filename = '/scratch_local/catherine/EBEX_SCANS/BOLO_STREAM/stream_bolo_'+strtrim(j,2)+'.dat'

delvarx, stream_bolo
print, 'Stream_bolo ',strtrim((j+1),2),' of ',strtrim(n_bolos,2),' completed and saved'
endfor
delvarx,num

;Now to save timestreams as binary files:'
print, 'Now saving bolo streams as binary files'

for j = 0 , n_bolos do begin
num = strtrim(j,2)

restore, '/scratch_local/catherine/EBEX_SCANS/BOLO_STREAM/stream_bolo_'+num+'.dat'
  if j eq 0 then begin
  print, 'Each binary file is made from a stream with the following format'
  help, stream_bolo
  endif

openw, lun, '/scratch_local/catherine/EBEX_SCANS/BINARY/bolo_'+num+'.dat'
writeu, lun, stream_bolo
free_lun, lun

delvarx, stream_bolo

endfor

print, 'End Time:',systime(/seconds)-timer

return
END
