FUNCTION healp2map,healp_vec,header,hin=hin,hout=hout,use_nside=use_nside,coo1=coo1,coo2=coo2, $
                   integration_function=integration_function,show=show,_extra=extra


;+
; NAME:
;    healp2map
; CATEGORY:
;    Healpix additions
; PURPOSE:
;    Projects any healpix vector onto any fits 2D map
; CALLING SEQUENCE:
;
;
; map=healp2map(healp_vec,header[,hin=][,use_nside=][,integration_function=][,/show])
; INPUT:
;    healp_vec = Healpix vector
;    header    = fits 2D header
; OUTPUT:
;    map       = 2D map corresponding to header
; OPTIONAL INPUT:
;    None
; INPUT KEYWORDS:
;    hin       =            Extension header for the healpix vector
;    use_nside =            The healpix vector is degraded to this nside before being projected on the 2D map.
;                           Default: nside of input vector
;    coo1,coo2 =            Coordinate arrays of header (degrees)
;    integration_function = name of the IDL function to be used for
;                           averaging neighboor Healpix values into
;                           a given pixel. This function must take
;                           data values and distance to the considered
;                           point as input and return a single value
;                           to be affected to the given pixel.
;                           Default: 'nearest_neighboor_integ_fun'
;    show                 = If set the map is shown while buiding.
; OUTPUT KEYWORDS:
;    hout       =           fits header of the output image
; SIDE EFFECTS:
;    None
; EXAMPLES:
; map=healp2map(healp_vec,header,use_nside=128,integration_function='my_function',/show
; RESTRICTIONS:
;    The system variable !healp_triangles_dir must be set to a
;    directory name containing the appropriate
;    connectivity files generated using do_connectivity_files.pro
;    2D fits header is assumed to be in same coordinates system as
;    healpix vector
;    It is assumed that the healpix is RING ordered
; PROCEDURES CALLED:
;    healp_downres, create_coo2, ang2pix
; REVISION HISTORY:
;    Created by Jean-Philippe Bernard 01/08/2001
;-

file_root='healp_connect_nested_' & con_ordering='NESTED'
;file_root='healp_connect_' & con_ordering='RING'

;common
;healp_connectivity_common,triangles,healp_indexes,reverse_healp_indexes,
;$
;
;connectivity_ptr,n_connectivity,edges,nside_connect

common healp_connectivity_common,connectivity_ptr,n_connectivity,nside_connect

IF n_params() EQ 0 THEN BEGIN
  print,'map=healp2map(healp_vec,header[,hin=][,use_nside=][,integration_function=][,/show])'
  map=0
  goto,finished
ENDIF

IF not keyword_set(integration_function) THEN BEGIN
  integ_func='nearest_neighboor_integ_fun'
ENDIF ELSE BEGIN
  integ_func=integration_function
ENDELSE

Npix=n_elements(healp_vec)
nside=long(sqrt(Npix/12))
IF keyword_set(hin) THEN BEGIN
  ordering=strtrim(sxpar(hin,'ORDERING'),2)
  coo_type=strtrim(sxpar(hin,'CTYPE'),2)
  IF coo_type EQ '0' THEN BEGIN
    coo_type='GLON'
  ENDIF
ENDIF ELSE BEGIN
  ordering='RING'       ;by default, it is assumed that input vector is RING
;  ordering='NESTED'
  coo_type='GLON'
ENDELSE

fcoo_type=strtrim(sxpar(header,'CTYPE1'),2)
fcoo_type=strmid(fcoo_type,0,4)
equinox=sxpar(header,'EQUINOX')

IF keyword_set(use_nside) THEN BEGIN
  used_nside=long(use_nside)
  d=healp_downres(healp_vec,hin=hin,nside_out=used_nside)
ENDIF ELSE BEGIN
  used_nside=long(nside)
  d=healp_vec
ENDELSE
;== If necessary, change ordering of the data
IF ordering NE con_ordering THEN BEGIN
  d=reorder(d,in=ordering,out=con_ordering)
ENDIF

;== create the healpix coordinates
healp_coord,used_nside,lo,la,ordering=con_ordering

Nx=sxpar(header,'NAXIS1')
Ny=sxpar(header,'NAXIS2')
map=fltarr(Nx,Ny)+!indef

;== compute fits coordinates
IF not keyword_set(coo1) OR not keyword_set(coo2) THEN BEGIN
  create_coo2,header,c1,c2,/silent
ENDIF ELSE BEGIN
  c1=coo1 & c2=coo2
ENDELSE
;== convert fits coordinates to healpix coordinate system
CASE fcoo_type OF
  'GLON':BEGIN
    feq=0
    CASE coo_type OF
      'GLON':ff=-1
      'RA':  ff=2
      'ELON':ff=6
    ENDCASE
  END
  'RA--':BEGIN
    feq=1
    CASE coo_type OF
      'GLON':ff=1
      'RA':  ff=-1
      'ELON':ff=3      
    ENDCASE
  END
  'ELON':BEGIN
    feq=0
    CASE coo_type OF
      'GLON':ff=5
      'RA':  ff=4
      'ELON':ff=-1      
    ENDCASE  
  END
ENDCASE
IF feq EQ 1 THEN BEGIN
  precess_array,c1,c2,equinox,astron_default_equinox()
ENDIF
IF ff NE -1 THEN BEGIN
  euler,c1,c2,cc1,cc2,ff
  c1=cc1 & c2=cc2 & cc1=0 & cc2=0
ENDIF
phi=c1/!radeg
theta=-c2/!radeg+!pi/2.
ang2pix, used_nside, theta, phi, ipix,ordering=con_ordering
ipix=reform(ipix,Nx,Ny)

;== restore the healpix connectivity arrays, if not already there
dir_save=!healp_triangles_dir
file=dir_save+file_root+strtrim(used_nside,2)+'.sav'

IF NOT defined(connectivity_ptr) THEN BEGIN
  restore,file,/verb
  nside_connect=used_nside
ENDIF ELSE BEGIN
  IF nside_connect NE used_nside THEN BEGIN
    restore,file,/verb
    nside_connect=used_nside
  ENDIF
ENDELSE

;== Build the map
FOR j=0L,Ny-1 DO BEGIN
  FOR i=0L,Nx-1 DO BEGIN
;
;conn=healp_indexes(*connectivity_ptr(reverse_healp_indexes(ipix(i,j))));pixels connected to ipix
;    conn=*connectivity_ptr(ipix(i,j))
;
;    str='B='+integ_func+'(d(conn),lo(conn),la(conn),coo1(i,j),coo2(i,j),_extra=extra)'
    str='B='+integ_func+'(d,lo,la,c1(i,j),c2(i,j),connectivity_ptr,ipix(i,j),_extra=extra)'
    toto=execute(str)
    map(i,j)=B
  ENDFOR
;  print,d(conn),lo(conn),la(conn),coo1(i-1,j),coo2(i-1,j)
  IF keyword_set(show) THEN tvscl,map>0
ENDFOR

;== add keywords to the header
hout=header
sxaddpar,hout,'INT_METHOD',integ_func
IF defined(extra) THEN BEGIN
  tags=tag_names(extra)
  Ntag=n_elements(tags)
  FOR i=0,Ntag-1 DO BEGIN
    sxaddpar,hout,tags(i),extra.(i)
  ENDFOR
ENDIF

heap_gc,/ptr

finished:
RETURN,map

END
