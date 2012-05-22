FUNCTION healp_downres,d,hin=hin,hout=hout,nside_out=nside_out

;+
; NAME:
;    healp_downres
; CATEGORY:
;    Healpix additions
; PURPOSE:
;    Reduces the resolution (nside) of a given healpix vector
; CALLING SEQUENCE:
;    vec=healp2map(healp_vec[,hin=][,hout=][,nside_out=])
; INPUT:
;    healp_vec = Healpix vector
; OUTPUT:
;    vec       = Healpix vector at reduced resolution
; OPTIONAL INPUT:
;    None
; INPUT KEYWORDS:
;    hin       = Healpix fits header
;    hout      = Healpix header corresponding to vec
;    nside_out = Requested resolution of vec (must be a power of 2).
;                Default is the nside juste below that of healp_vec
; OUTPUT KEYWORDS:
;    None
; SIDE EFFECTS:
;    None
; EXAMPLES:
;    vec=healp_downres(healp_vec,hin=h,hout=hout,nside_out=64)
; RESTRICTIONS:
;    hout cannot be set if hin is not set
;    ordering of the input healpix is assumed to be RING, unless otherwise stated in the header
;    No action is taken if nside_out is LE than nside of the input vector 
; PROCEDURES CALLED:
;    healp_downres, create_coo2, ang2pix
; REVISION HISTORY:
;    Created by Jean-Philippe Bernard 01/08/2001
;-

;stop

;hout cannot be set if hin is not set

IF n_params() EQ 0 THEN BEGIN
  print,'vec=healpdownres(healp_vec[,hin=][,hout=][,nside_out=])'
  dout=0 & hout=0
  goto,finished
ENDIF

Npix=n_elements(d)
nside=sqrt((1.*Npix)/12.)
IF keyword_set(nside_out) THEN BEGIN
  nsideout=nside_out
  ntimes=fix((alog(nside)-alog(nsideout))/alog(2.))
ENDIF ELSE BEGIN
  ntimes=1
  nsideout=long(2^(alog(nside)/alog(2.)-ntimes))    ;default is to decrease by one power of 2
ENDELSE
message,'Will degrade resolution '+strtrim(ntimes,2)+' times',/info

IF keyword_set(hin) THEN BEGIN
  h=hin
  ordering=strupcase(strtrim(sxpar(h,'ORDERING'),2))
ENDIF ELSE BEGIN
  ordering='RING'
ENDELSE

;Do nothing case
IF ntimes LE 0 THEN BEGIN
  message,'No action taken ... ',/info
  dout=d
  IF keyword_set(hin) THEN hout=hin
  goto,finished
ENDIF

CASE ordering OF
  'RING': sch='RING'
  'NESTED': sch='NESTED'
  '0':BEGIN
    message,'No ordering Keyword in header: ',/info
    message,'Assuming RING: ',/info
    sch='RING'
  END
  ELSE: BEGIN
      message,'Unknown pixelisation ordering: '+ordering,/info
      message,'Must be either RING or NESTED'
  END
ENDCASE
dd=d
IF sch EQ 'RING' THEN BEGIN
  message,'Reordering array to NESTED',/info
  dd=reorder(d,in='RING',out='NESTED')
ENDIF

Npix_new=Npix
FOR k=0,ntimes-1 DO BEGIN
  Npix_new=Npix_new/4
  dout=fltarr(Npix_new)+!indef
  FOR i=0L,Npix_new-1 DO BEGIN
    from=i*4 & to=from+3
    dz=dd(from:to)
    ind=where(dz NE !indef,count)
    IF count NE 0 THEN BEGIN
      dout(i)=avg(dz(ind))
    ENDIF
  ENDFOR
  dd=dout
ENDFOR

IF sch EQ 'RING' THEN BEGIN
  message,'Reordering output to RING',/info
  dout=reorder(dout,in='NESTED',out='RING')
ENDIF

sxaddpar,h,'NSIDE',nsideout
hout=h

finished:

RETURN,dout

END