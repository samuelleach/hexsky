PRO h2pix,h,pixx,pixy,silent=silent,face=face

;+
; NAME:
;	h2pix
; PURPOSE:
;       creates pixel array from a header and initialize the projection common
; CATEGORY:
;       Coordinates conversions
; CALLING SEQUENCE: 
;	pix2coo,h,pixx,pixy,coo1,coo2
; INPUTS:
;       h= the header
; OPTIONAL INPUT PARAMETERS:
; OUTPUTS:
;	pixx= x pixel value (IDL format)
;	pixy= y pixel value (IDL format)
; OPTIONAL OUTPUT PARAMETERS:
; ACCEPTED KEY-WORDS:
;	proj	= set to force the proj type (otherwise from header)
; COMMON BLOCKS:
;	proj_common defined in @proj_common
;	contains: mat,rot,proj,coord,naxis1,naxis2,crpix1,crpix2,projtype
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
;	The pixels values are 0 at the proj center (crpix1,crpix2)
;	The pixel array contains float values.
;	If only h is provided, only the common values are updated
;	If h,pixx are given, pixx is float(Naxis1*Naxis2,2) and the
;	first plane contains x pix values, the second y pix values.
;	If all arguments are provided, pixx and pixy are (Naxis1,Naxis2).
; uses: sxpar; MODIFICATION HISTORY:
;	Written J.P. Bernard Mar 20 1995
;       Modif JPB 21/02/2002 to take LONPOLE first, then LONGPOLE. See Calabretta & Greisen A&A 2001
;       Modif JPB 28/05/2002 to add cubetype to the common (to differentiate CSC tee and right tee)
;       Modif JPB 9/12/02 to add strtrim when reading ctype from header
;-

@proj_common.com

;---------------------------------------------------------------
; parameter check
;---------------------------------------------------------------
IF N_PARAMS(0) LT 1 THEN BEGIN
  PRINT,'Calling Sequence: '
  PRINT,'h2pix,h[,pixx[,pixy]]'
  PRINT,'Accepted Key words: ,/silent'
  GOTO, closing
ENDIF

indef=!indef

DEG_RAD = 180./!dPI
;======== Read header params
crota1 = SXPAR (H, 'crota1')/deg_rad
crota2 = SXPAR (H, 'crota2')/deg_rad
ctype1 = strtrim(SXPAR (H, 'ctype1'),2)
ctype2 = strtrim(SXPAR (H, 'ctype2'),2)
NAXIS1 = SXPAR (H, 'NAXIS1')
NAXIS2 = SXPAR (H, 'NAXIS2')
CDELT1 = SXPAR (H, 'CDELT1')/deg_rad		;rad/pix
CDELT2 = SXPAR (H, 'CDELT2')/deg_rad		;rad/pix
CRPIX1 = SXPAR (H, 'CRPIX1') - 1		;IDL format
CRPIX2 = SXPAR (H, 'CRPIX2') - 1
CRVAL1 = SXPAR (H, 'CRVAL1')/deg_rad		;rad
CRVAL2 = SXPAR (H, 'CRVAL2')/deg_rad		;rad
projp1=SXPAR (H, 'PROJP1')
;Modif JPB to take LONPOLE first, then LONGPOLE !!
phip   = SXPAR (H, 'LONPOLE',count=count)/deg_rad
IF count EQ 0 THEN BEGIN
  phip   = SXPAR (H, 'LONGPOLE',count=count)/deg_rad
ENDIF
IF count EQ 0 THEN phip=180./deg_rad		;Standard default in rad
longpole=phip*!radeg				;in degree
equinox= SXPAR (H, 'EQUINOX',count=count)
IF count EQ 0 THEN BEGIN
  equinox=SXPAR (H, 'EPOCH',count=count)
  IF count EQ 0 THEN BEGIN
    equinox=1950.		;Standard default
  ENDIF
ENDIF
cubetype= strtrim(SXPAR (H, 'CUBETYPE',count=count))
IF count EQ 0 THEN BEGIN
  cubetype='unknown'
ENDIF

;===== Check the projection type
cor_proj_dec,ctype1,ccoord,pproj,projtype,status,silent=silent
proj=pproj
coord=ccoord
IF status NE 0 THEN BEGIN
  print,'coor---proj not recognized'
  goto,closing
ENDIF
IF projtype EQ 'COV' OR projtype EQ 'CYL' THEN BEGIN
  delta0=crval2 & alpha0=crval1
  deltap=ACOS(SIN(delta0)/COS(phiP))
  alphaP=alpha0-atan(sin(phip)/cos(delta0),-tan(deltaP)*tan(delta0))
ENDIF ELSE BEGIN
  deltap=crval2 & alphaP=crval1
  delta0=ASIN(cos(deltaP)*cos(phiP))
  alpha0=alphaP+ATAN(sin(phip)/cos(delta0),-tan(deltaP)*tan(delta0))
ENDELSE

IF not keyword_set(silent) THEN BEGIN
  print,'alpha0=',alpha0*deg_rad,' deg'
  print,'delta0=',delta0*deg_rad,' deg'
  print,'phip  =',phip*deg_rad,' deg'
  print,'alphap=',alphap*deg_rad,' deg'
  print,'deltap=',deltap*deg_rad,' deg'
ENDIF
;Define some usefull quantities
cop=COS(phip) & sip=SIN(phip)
siap=SIN(alphap) & coap=COS(alphap)
sidp=SIN(deltap) & codp=COS(deltap) & tadp=sidp/codp
;========= Matrix of the transformation
r11=-siap*sip-coap*cop*sidp
r12=coap*sip-siap*cop*sidp
r13=cop*codp
r21=siap*cop-coap*sip*sidp
r22=-coap*cop-siap*sip*sidp
r23=sip*codp
r31=coap*codp
r32=siap*codp
r33=sidp

mat_paper=[[r11,r21,r31],[r12,r22,r32],[r13,r23,r33]]
;print,'Paper ========================================='
;print,mat_paper
;=== Method used in projbld to define mat
euler=[crval1,-crval2,0.]
cos_z1=cos(euler(0))
sin_z1=sin(euler(0))
cos_y1=cos(euler(1))
sin_y1=sin(euler(1))
cos_z2=cos(euler(2))
sin_z2=sin(euler(2))
m_z1=[[cos_z1,sin_z1,0],[-sin_z1,cos_z1,0],[0,0,1]]
m_y1=[[cos_y1,0,-sin_y1],[0,1,0],[sin_y1,0,cos_y1]]
m_z2=[[cos_z2,sin_z2,0],[-sin_z2,cos_z2,0],[0,0,1]]
;mat_bld=TRANSPOSE(m_z1#m_y1#m_z2)
mat_bld=TRANSPOSE(m_z1#m_y1#m_z2)
;print,'proj_bld ========================================='
;print,mat_bld
;print,'=================================================='
;mat=TRANSPOSE(mat_paper)
;mat=mat_bld
mat=mat_paper
;remove very small values in mat caused by cos rounding
ind=where(ABS(mat) LT 1E-7,count)
IF count NE 0 THEN mat(ind)=0.
IF not keyword_set(silent) THEN print,mat
;========= Rotation matrix
cr2=cos(crota2) & sr2=sin(crota2)
rota=[[cdelt1*cr2,-cdelt2*sr2],[cdelt1*sr2,cdelt2*cr2]]		;rad/pix
ind=where(ABS(rota) LT 1E-7,count)
IF count NE 0 THEN rota(ind)=0.
IF not keyword_set(silent) THEN print,rota

;===== If necessary, make an array of pixels values (0 at proj center)
IF n_params(0) GT 1 THEN BEGIN
  pixx=fltarr(Naxis1,Naxis2) & pixy=pixx
  IF NOT keyword_set(face) THEN BEGIN
    FOR i=0,Naxis1-1 DO BEGIN
      pixx(i,*)=1.*i
    ENDFOR
    FOR i=0,Naxis2-1 DO BEGIN
      pixy(*,i)=1.*i
    ENDFOR
;    pixx=pixx-crpix1
;    pixy=pixy-crpix2
    face=0
  ENDIF ELSE BEGIN
    Nyy=SXPAR (H, 'NAXIS2') & Nxx=SXPAR (H, 'NAXIS1')
    face=intarr(Nxx,Nyy)
    IF 3*Nyy EQ 2*Nxx THEN BEGIN ;Sixpack
      cube_side=Nxx/3
      offx=[2,2,1,0,0,1]
      offy=[1,0,0,0,1,1]
    ENDIF ELSE IF 4*Nyy EQ 3*Nxx THEN BEGIN ;T assumed Right
      cube_side=Nxx/4
      offx=[3,3,2,1,0,3]
      offy=[2,1,1,1,1,0]
    ENDIF ELSE BEGIN
      print,'h2pix:input header does not match a cube'
      goto,closing
    ENDELSE
    reso=ROUND(ALOG(cube_side)/ALOG(2))+1         ;e.g. Npix/face=n=2^(reso-1)
    debx=offx*cube_side
    finx=debx+cube_side-1
    centx=1.*debx+1.*(finx-debx)/2.
    deby=offy*cube_side
    finy=deby+cube_side-1
    centy=1.*deby+1.*(finy-deby)/2.
    xar=fltarr(cube_side,cube_side)
    yar=fltarr(cube_side,cube_side)
    FOR i=0,cube_side-1 DO xar(i,*)=(i-cube_side/2+0.5)*90./cube_side
    FOR j=0,cube_side-1 DO yar(*,j)=(j-cube_side/2+0.5)*90./cube_side
    xar=-xar
    FOR f=0,5 DO BEGIN
      pixx(debx(f):finx(f),deby(f):finy(f))=xar
      pixy(debx(f):finx(f),deby(f):finy(f))=yar
      face(debx(f):finx(f),deby(f):finy(f))=f
    ENDFOR
  ENDELSE
ENDIF
;===== If necessary, linearize the array
IF n_params(0) EQ 2 THEN BEGIN
;  ind=indgen(Naxis1*Naxis2)
  ind=where(pixx NE indef,count)
  ij=fltarr(count,2)
  ij(*,0)=pixx(ind) & ij(*,1)=pixy(ind)
  pixx=ij
ENDIF
closing:
END
