pro coordinate_change,file_in,map_out,coordinate_in,coordinate_out,ordering_out, $
		       preprocessed=preprocessed,polmap=polmap,splitfile=splitfile
;pro coordinate_change,file_in,file_out,coordinate_in,coordinate_out,ordering_out, $
;		       preprocessed=preprocessed,polmap=polmap,splitfile=splitfile
;+
; NAME:
;       COORDINATE_CHANGE
;
; PURPOSE:
;       Tool to transform HEALPix maps in Galactic/Ecliptic/Equatorial 
;       coordinates 
;
; CALLING SEQUENCE:
;       coordinate_change,file_in,file_out,coordinate_in,coordinate_out,ordering_out
;
; INPUTS:
;       file_in = name of the input FITS HEALPix map
;       file_out = name of the output FITS HEALPix map
;       coordinate_in = coordinates in the output, either 'E' or 'G' or 'Q'
;       coordinate_out = coordinates in the output, either 'E' or 'G' or 'Q' different from coordinate_in
;       ordering_out = ordering in the output, either 'ring' or 'nest'
;  
; EXAMPLE:
;       coordinate_change,'map_in.fits','map_out.fits','Q','G','ring'
;
; MODIFICATION HISTORY:
;    February 26, 2004, Carlo Baccigalupi, SISSA/ISAS
;    December 2007, Sam Leach, SISSA/ISAS.
;    Jan 2008, Fix bug for nested maps. Possible to split output
;    files. SL.
;-

if (n_params() lt 4) then begin
    PRINT, 'Wrong number of arguments in coordinate_change'
    print,'Syntax : '
    print, 'coordinate_change,file_in,file_out,coordinate_in,coordinate_out,ordering_out'
    return
endif

if (coordinate_out eq  coordinate_in) then begin
   print,'Input and output coordinates must be different'
   stop
endif 

if n_elements(preprocessed) eq 0 then preprocessed = 0
if n_elements(polmap) eq 0 then polmap = 0
if n_elements(splitfile) eq 0 then splitfile = 0
pixelfile=coordinate_in+'_to_'+coordinate_out+'_'+ordering_out+'.fits'

datadir='preproc_data/'
spawn,'mkdir -p '+datadir

if preprocessed eq 0 then begin
  print,'Reading map from ',file_in
  if polmap then begin
    read_tqu,file_in,map_in,hdr=header,xhdr=extended_header,nside=nside,ordering=ordering_in
    dimension=size(map_in,/dimensions)
    nmaps=dimension(1)
  endif else begin
    read_fits_map,file_in,map_in,header,extended_header,nside=nside,ordering=ordering_in
    nmaps=1
  endelse
  pixelfile=coordinate_in+'_to_'+coordinate_out+'_'+ordering_in+'_to_'+ordering_out+'.fits'
  npix=nside2npix(nside)
  map = 0; Reread later

  ; Coordinate vectors
  vec_coordinate_out=fltarr(npix,3L)
  ii=lindgen(nside2npix(nside))
  
  ; Output sky vectors
  ;  print,'Output sky vectors'
  if (strlowcase(ordering_out) eq 'ring') then begin
    pix2vec_ring,nside,ii,vec_coordinate_out
  endif else begin
    pix2vec_nest,nside,ii,vec_coordinate_out
  endelse
  
  ; Conversion 
;  print,'Conversion'
  vec_coordinate_in=rotate_coord(vec_coordinate_out,inco=coordinate_out,outco=coordinate_in)
  vec_coordinate_out=0.
  
  ; Mapping sky vectors from input
;  print,'Mapping'
  if (strlowcase(ordering_in) eq 'ring') then begin
    vec2pix_ring,nside,vec_coordinate_in,i_coordinate_in
  endif else begin
    vec2pix_nest,nside,vec_coordinate_in,i_coordinate_in
  endelse

  print,'Writing pixel transform to ',pixelfile
;  write_fits_map,datadir+pixelfile,i_coordinate_in,ordering='ring'
  
endif
  
print,'Reading map from ',file_in
if polmap then begin
  read_tqu,file_in,map_in,hdr=header,xhdr=extended_header,nside=nside,ordering=ordering_in
  dimension=size(map_in,/dimensions)
  nmaps=dimension(1)
endif else begin
  read_fits_map,file_in,map_in,header,extended_header,nside=nside,ordering=ordering_in
  nmaps=1
endelse
pixelfile=coordinate_in+'_to_'+coordinate_out+'_'+ordering_in+'_to_'+ordering_out+'.fits'
print,'Reading pixel transform from ',pixelfile
;read_fits_map,datadir+pixelfile,i_coordinate_in,ordering=ordering,nside=nside
map_out=map_in

ii=lindgen(nside2npix(nside))
print,'nmaps = ', nmaps
if (nmaps eq 1) then begin
  map_out(ii)=map_in(i_coordinate_in)
endif else begin
  for cc=0,nmaps-1 do begin
    map_out(ii,cc)=map_in(i_coordinate_in,cc)
  endfor
endelse

map_in=0.
vec_coordinate_in=0.

; Output
;print,'Output to ',file_out
if (nmaps eq 1) then begin
  if (strlowcase(ordering_out) eq 'ring') then begin
;      write_fits_map,file_out,map_out,coord=coordinate_out,/ring,header
   endif else begin
;      write_fits_map,file_out,map_out,coord=coordinate_out,/nest,header
   endelse
 endif else begin
   if (not splitfile) then begin
     if (strlowcase(ordering_out) eq 'ring') then begin
;       write_TQU,file_out,map_out,coord=coordinate_out,/ring,hdr=header,xhdr=extended_header
     endif else begin
;       write_TQU,file_out,map_out,coord=coordinate_out,/nest,hdr=header,xhdr=extended_header
     endelse
   endif else begin ;Split data into 2 TQU maps
     for jj=0,1 do begin
       file=repstr(file_out,'.fits','_'+strtrim(jj,2)+'.fits')
       print,'Writing data to '+file
;       write_tqu,file,map_out(*,jj*3:((jj+1)*3-1)),coord=coordinate_out,ordering=ordering_out
     endfor
   endelse
 endelse
end
