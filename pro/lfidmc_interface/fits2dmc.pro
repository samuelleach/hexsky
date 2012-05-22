pro fits2dmc,namemap,nu,nameout,database=database
;+
; FITS2DMC is a procedure that creates a new DMC object (map.LFI_Map)
; from a normal FITS maps
; INPUTS:
; namemap: <string> name of the input fits map
; nu: <int/float> frequency of the input map
; nameout: <string> name of the new DMC object
;-
if NOT keyword_set(database) then database='testl1'

; Read input map and get keywords
read_fits_map,namemap,map,hdr,xhdr,nside=nside
units=sxpar(xhdr,'tunit1')
;beam=sxpar(xhdr,'beam')
ordering=sxpar(xhdr,'ORDERING')
if (ordering eq '0') then ordering='RING'
coordsys=sxpar(xhdr,'COORDSYS')
if (coordsys eq '0') then coordsys='G'

if (nu lt 100.) then begin 
freq='0'+strtrim(round(nu),2)
endif else begin
freq=strtrim(round(nu),2)
endelse

; Initialize the manager
mng = lsio_mng_create("TOODI%file")

; Output object for the map
outMap = lsio_handle_new()
lsio_handle_create, outMap, 'TOODI%'+database+'%%'+nameout+':-1%', 'map.LFI_Map'
map_col = lsio_handle_columnnumber(outMap, 'I_Stokes')

; Set keywords for the object
lsio_handle_setkey, outMap, 'Coordsys',coordsys
lsio_handle_setkey, outMap, 'Ordering',ordering
lsio_handle_setkey, outMap, 'Nside',nside
;lsio_handle_setkey, outMap, 'horn',
;lsio_handle_setkey, outMap, 'radiometer',
;lsio_handle_setkey, outMap, 'detector',
lsio_handle_setkey, outMap, 'frequency',freq

; Store the results
lsio_handle_appendcolumn, outMap, map_col, float(map[*,0]) 
lsio_handle_close,outMap
END
