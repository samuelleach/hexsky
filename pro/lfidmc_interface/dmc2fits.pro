function dmc2fits,namemap,nameout=nameout, xhdr=xhdr, nofile=nofile, database=database
;+
; DMC2FITS is a function that read a DMC map (map.LFI_Map) and write a FITS
; INPUTS:
; 	namemap: <string> name of the input fits map
; OUTPUTS:
; 	map: <float> output map
; KEYWORDS:
; 	nameout: <string> user name and location for the output file.
;		If not set nameout=namein.
; 	xhdr: <string> the extended header of the file 
;       database: The name of the DataBase to be used (default: testl1)
;	nofile: Only reading, no FITS file is produced.
;-

if NOT keyword_set(database) then database='testl1'

; Initialize the manager
mng = lsio_mng_create("TOODI%file")

; Input object for the DB
inMap = lsio_handle_new()
lsio_handle_open, inMap, 'TOODI%'+database+'%%'+namemap+':0%', 'map.LFI_Map'
map_col = lsio_handle_columnnumber(inMap, 'I_Stokes')
map_len = lsio_handle_columnlength(inMap, map_col)

; Read the map
map=fltarr(map_len)
lsio_handle_readcolumn,inMap,map_col,map

coordsys='' & ordering='' & nside=0l & freq=''

; Read the keywords
lsio_handle_getkey, inMap, 'Coordsys',coordsys
lsio_handle_getkey, inMap, 'Ordering',ordering
lsio_handle_getkey, inMap, 'Nside',nside
;lsio_handle_getkey, inMap, 'horn',
;lsio_handle_getkey, inMap, 'radiometer',
;lsio_handle_getkey, inMap, 'detector',
lsio_handle_getkey, inMap, 'frequency',freq

lsio_handle_close,inMap

; Writing the FITS file
if not keyword_set(nofile) then begin
	if keyword_set(nameout) then begin
		filename=nameout
	endif else begin
		filename='./'+namemap+'.fits'
	endelse

	write_fits_map, filename, map, Coordsys=coordsys, Ordering=ordering;, Units='K_cmb'
	xhdr = HEADFITS(filename,/ext)
	SXADDPAR, xhdr, 'freq', freq, 'GHz'
	MODFITS, filename ,0 ,xhdr ,/ext
endif

return,map
END
