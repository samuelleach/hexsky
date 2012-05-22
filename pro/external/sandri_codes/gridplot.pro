;******************************************************
; programma per il plot dei beam in formato grasp
; F.Villa, M.Sandri Istituto TESRE/CNR - Bologna,
; 21 Agosto 2001
; Modified by J.P. Leahy, JBO - Manchester
; 7 November 2006
;******************************************************

pro gridplot, beam, copolar = cop
;
; Output: 
;      beam is a structure containing the I,Q,U,V arrays (beam.i etc)
;
set_plot,'X'
device,retain=2,DECOMPOSED=0

LOADCT,3        ; RED TEMPERATURE TABLE

rad2am = 60.*!radeg
sig2fwhm = sqrt(8.*alog(2.))

TITLE1 = ' ' & TITLE2 = ' ' & TITLE3 = ' ' & TITLE4 = ' '
ENDTITLE = ' '

XS = 0.D & XS = 0.D & YE = 0.D & YE = 0.D

str='!5 '

KTYPE = 1L      ; --> DATA TYPE FORMAT
                ;     ALWAYS = 1 IN GRASP8
NSET = 1L       ; --> NUMBER OF BEAMS IN THE FILE
ICOMP = 1L      ; --> FIELD COMPONENT
NCOMP = 1L      ; --> NUMBER OF COMPONENTS
IGRID = 1L      ; --> TYPE OF FIELD GRID
IX = 1L         ; --> CENTER OF THE BEAM
IY = 1L         ;     (IX,IY)

c1 =0.D & c2 =0.D & c3=0.D & c4=0.D

FILEINPUT='FILEINPUT'

NX = 1L & NY = 1L & KLIMIT = 1L

FILEINPUT=DIALOG_PICKFILE(filter = '*.grd',PATH='../beams')

FILEOUTPUT_PS = STRMID(FILEINPUT, 0,STRPOS(FILEINPUT,'.grd')) + '_grd.ps'
FILEOUTPUT_TXT = STRMID(FILEINPUT, 0,STRPOS(FILEINPUT,'.grd')) + '_grd.txt'
FILENAMEIN = STRMID(FILEINPUT,RSTRPOS(FILEINPUT,'\')+1)

OPENR,1,FILEINPUT

FOR line=0,100 DO BEGIN
  IF (strtrim(str,2) NE '++++') THEN BEGIN
    readf,1,str
    print,str
  ENDIF ELSE BEGIN
    goto, jump1
  ENDELSE
ENDFOR

jump1: readf,1,KTYPE

readf,1,NSET,ICOMP,NCOMP,IGRID
readf,1,IX,IY

readf,1,XS,YS,XE,YE


print,TITLE2
print,'------------------------------------------------------------------'

;   PRINT,'U min = ',XS,'   U max = ',XE
;   PRINT,'V min = ',YS,'   V max = ',YE

READF,1,NX,NY,KLIMIT

PRINT,'grid of ', NX,' x ', NY,' points'

PRINT, ICOMP

C1R = dblarr(NX,NY)
C1I = dblarr(NX,NY)
C2R = dblarr(NX,NY)
C2I = dblarr(NX,NY)

FOR I = 0, NX-1 DO BEGIN
  FOR J=0,NY-1 DO BEGIN
    READF,1,c1,c2,c3,c4
    C1R(J,I) = c1
    C1I(J,I) = c2
    C2R(J,I) = c3
    C2I(J,I) = c4
  ENDFOR
ENDFOR

CLOSE,/ALL

COMP1 = DCOMPLEX(C1R,C1I)
COMP2 = DCOMPLEX(C2R,C2I)

; -------------------------------------
; PREPARAZIONE DATI PER IL CONTOUR PLOT
; -------------------------------------

DX = (XE - XS)/(NX-1)
X = FINDGEN(NX)*DX + XS

DY = (YE - YS)/(NY-1)
Y = FINDGEN(NY)*DY + YS

COMP1MAX=10.*ALOG10(max(ABS(COMP1))^2)
COMP2MAX=10.*ALOG10(max(ABS(COMP2))^2)

IF (COMP1MAX GT COMP2MAX) THEN BEGIN
	XPD = COMP1MAX - COMP2MAX
ENDIF ELSE BEGIN
  XPD = COMP2MAX - COMP1MAX
ENDELSE

TITLE_1='!5MAX LEVEL = '+ STRING(COMP1MAX)+'!5 dBi'
TITLE_2='!5MAX LEVEL = ' + STRING(COMP2MAX)+'!5 dBi'

TITLE_1 = STRCOMPRESS(TITLE_1)
TITLE_2 = STRCOMPRESS(TITLE_2)

TITLE_PLOT = FILENAMEIN

DB_LEVELS=[-70,-60,-50,-40,-30,-20,-10,-6,-3]
LEVELS_ON=[1,1,1,1,1,1,1,1,1]

; DB_LEVELS=[-40,-30,-20,-10,-6,-3]
; LEVELS_ON=[0,0,0,0,0]

; GAUSSIAN FIT OF THE COPOLAR COMPONENT

IF (COMP1MAX gt COMP2MAX) THEN BEGIN   ; SETUP OF THE COPOLAR COMPONENT
	COPOLAR = ABS(COMP1)^2
	COPOLAR_TXT = 'COMP1'
        COP = COPOLAR
ENDIF ELSE BEGIN
	COPOLAR = ABS(COMP2)^2
	COPOLAR_TXT = 'COMP2'
        COP = COPOLAR
ENDELSE

PRINT,'COPOLAR COMPONENT IS ' + COPOLAR_TXT

GFIT = GAUSS2DFIT(COPOLAR, PARAM, X*RAD2AM, Y*RAD2AM, /TILT)	; GAUSSIAN FIT
; PARAMETERS EXTRACTION
	FWHMX = PARAM[2]*SIG2FWHM 	; FWHM IN X
	FWHMY = PARAM[3]*SIG2FWHM 	; FWHM IN Y
	FWHMAVE = (FWHMX+FWHMY)/2.
	TILT = PARAM[6]*!RADEG    	; TILTING FROM X AXIS

IF (FWHMX GT FWHMY) THEN BEGIN
    	ELL = FWHMX/FWHMY
ENDIF ELSE BEGIN
        ELL = FWHMY/FWHMX
ENDELSE

; ---------------------------
; CONTOUR PLOT E SURFACE PLOT
; ---------------------------

;window,0,title='FIRST COMPONENT CONTOUR',XSIZE=400,YSIZE=400
;contour,10.*ALOG10(ABS(COMP1)^2.)-COMP1MAX,X,Y,$
;        /fill,nlevels=255,$
;        title=TITLE_PLOT, subtitle=TITLE_1,xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle

;contour,10.*ALOG10(ABS(COMP1)^2.)-COMP1MAX,X,Y,/overplot,$
;        levels=DB_LEVELS,c_labels=DB_LEVELS

;window,1,title='SECOND COMPONENT CONTOUR',XSIZE=400,YSIZE=400
;       contour,10.*ALOG10(ABS(COMP2)^2.)-COMP2MAX,X,Y,$
;       /fill,nlevels=255,$
;       title=TITLE_PLOT, subtitle=TITLE_2,xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle
;       contour,10.*ALOG10(ABS(COMP2)^2.)-COMP2MAX,X,Y,/overplot,$
;       levels=DB_LEVELS, c_labels=DB_LEVELS

;window,2,title='FIRST COMPONENT SURFACE',XSIZE=400,YSIZE=400
;       shade_surf,10.*ALOG10(ABS(COMP1)^2.),X,Y,$
;       xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle

;window,3,title='SECOND COMPONENT SURFACE',XSIZE=400,YSIZE=400
;       shade_surf,10.*ALOG10(ABS(COMP2)^2.),X,Y,/save,$
;       xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle

; -----------------------------------
; CONVERSIONE NEI PARAMETRI DI STOKES
; -----------------------------------

; PARAMETRI DI STOKES;

P1 = C1R^2 + C1I^2
P2 = C2R^2 + C2I^2
SI = P1 + P2
SQ = P1 - P2
SU = 2.*(C1R*C2R + C1I*C2I) ;  2 Re(COMP1 . COMP2^*)
SV = 2.*(C1R*C2I - C1I*C2R) ; -2 Im(COMP1 . COMP2^*)

beam = create_struct('I', si, 'q', sq, 'u', su, 'v', sv, $
                     'du', dx, 'dv', dy)

;print,max(si),10*alog10(max(si))

;  CONTOUR PLOT DEI PARAMETRI DI STOKES

window,4,title='I PARAMETER CONTOUR PLOT',XSIZE=400,YSIZE=400
image_cont,SI
print,MAX(SI),MIN(SI)
window,5,title='Q PARAMETER CONTOUR PLOT',XSIZE=400,YSIZE=400
image_cont,SQ
print,MAX(SQ),MIN(SQ)
window,6,title='U PARAMETER CONTOUR PLOT',XSIZE=400,YSIZE=400
image_cont,SU
print,MAX(SU),MIN(SU)
window,7,title='V PARAMETER',XSIZE=400,YSIZE=400
image_cont,SV
;print,MAX(10.*ALOG10(ABS(SV)))
;window,8,title='DF',XSIZE=400,YSIZE=400
;image_cont,DELTAF
;contour,DELTAF,/fill,nlevels=255
;cbar,vertical=1,left=1,position=[0.1,0.1,0.12,0.95],vmax=MAX(DELTAF),vmin=MIN(DELTAF)
;print,MAX(DELTAF),MIN(DELTAF)

; -----------------------------------------
; CALCOLO DEL PARAMETRO DI DEPOLARIZZAZIONE
; -----------------------------------------

I_AVE = TOTAL(SI*DX*DY)
Q_AVE = TOTAL(SQ*DX*DY)
U_AVE = TOTAL(SU*DX*DY)
V_AVE = TOTAL(SV*DX*DY)

DEP = 1. - SQRT(Q_AVE^2. + U_AVE^2. + V_AVE^2.)/I_AVE
PQ = Q_AVE / I_AVE
PU = U_AVE / I_AVE
PV = V_AVE /I_AVE
PL = SQRT(Q_AVE^2.+U_AVE^2)/I_AVE

print,'Q percentage:',PQ*100.,'%'
print,'U percentage:',PU*100.,'%'
print,'Linear percentage: ', PL*100.,+'%'
print,'Circular percentage:', PV*100.,+'%'

PRINT,'DEPOLARIZATION= ',DEP*100., +'%'
PRINT,COMP2MAX
PRINT,COMP1MAX


; -----------------
; DATA OUTPUT
; -----------------

OPENW,2,FILEOUTPUT_TXT

PRINTF,2,'COMP1 MAX =>',COMP1MAX
PRINTF,2,'COMP2 MAX =>',COMP2MAX
PRINTF,2,'XPD => ',XPD
PRINTF,2,'% DEP => ',DEP*100.
PRINTF,2,'FWHM X => ',FWHMX
PRINTF,2,'FWHM Y => ',FWHMY
PRINTF,2,'FWHM AVE => ',FWHMAVE
PRINTF,2,'e => ',ELL
PRINTF,2,'TILT => ',TILT

CLOSE,2

GOTO, QUIT

; -----------------
; POSTSCRIPT OUTPUT
; -----------------

LOADCT,13 ; RAINBOW COLOR PALETTE

set_plot,'ps'

LEV=fltarr(255)

for i=0,254 do begin
  LEV[i]=-90.+90.*i/255.
endfor

device,/color,file=FILEOUTPUT_PS,XSIZE=15.,YSIZE=15.,XOFFSET=3.,YOFFSET=13.

contour,10.*ALOG10(ABS(COMP1)^2.)-COMP1MAX,X,Y,$
  /fill,levels=LEV,POSITION=[0.,0.,1.,1.],/ISOTROPIC,$
  title=TITLE_PLOT,xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle,$
  subtitle=TITLE_1

contour,10.*ALOG10(ABS(COMP1)^2.)-COMP1MAX,X,Y,/overplot,$
  levels=DB_LEVELS,c_labels=DB_LEVELS


;contour,10.*ALOG10(ABS(COMP1)^2.)-COMP1MAX,X,Y,$
;       levels=DB_LEVELS,c_labels=LEVELS_ON,/ISOTROPIC,POSITION=[0.,0.,1.,1.],$
;        title=TITLE_PLOT,xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle,$
;        subtitle=TITLE_1

contour,10.*ALOG10(ABS(COMP2)^2.)-COMP2MAX,X,Y,$
  /fill,levels=LEV,POSITION=[0.,0.,1.,1.],/ISOTROPIC,$
  title=TITLE_PLOT,xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle,$
  subtitle=TITLE_2

contour,10.*ALOG10(ABS(COMP2)^2.)-COMP2MAX,X,Y,/overplot,$
  levels=DB_LEVELS,c_labels=DB_LEVELS

;contour,10.*ALOG10(ABS(COMP2)^2.)-COMP2MAX,X,Y,$
;      levels=DB_LEVELS,c_labels=LEVELS_ON,/ISOTROPIC,POSITION=[0.,0.,1.,1.],$
;        title=TITLE_PLOT,xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle,$
;        subtitle=TITLE_2


CONTOUR,10.*ALOG10(COPOLAR/MAX(COPOLAR)),X,Y, $
  xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle,$
  LEVELS = [-30.,-20.,-10.,-3.],$
  POSITION = [0.,0.,1.,1.],/ISOTROPIC
CONTOUR,10.*ALOG10(GFIT/MAX(GFIT)),X,Y,/OVERPLOT,$
  LEVELS = [-30.,-20.,-10.,-3.],C_COLORS=[255,255,255,255],C_LINESTYLE=2

;xyouts,-0.02,-0.03,'COMP1 MAX =>'+string(COMP1MAX)+' dBi'
;xyouts,-0.02,-0.032,'COMP2 MAX =>'+string(COMP2MAX)+' dBi'
;xyouts,-0.02,-0.034,'XPD => '+string(XPD)+' dB'
;xyouts,-0.02,-0.036,'% DEPOL => '+STRING(DEP*100.)+'%'
;xyouts,-0.02,-0.038,'FWHM X => '+STRING(FWHMX)+' ARCMIN'
;xyouts,-0.02,-0.040,'FWHM Y => '+STRING(FWHMY)+' ARCMIN'
;xyouts,-0.02,-0.042,'FWHM AVE => '+STRING(FWHMAVE)+' ARCMIN'
;xyouts,-0.02,-0.044,'ELL => '+STRING(ELL)
;xyouts,0.008,-0.023,'TILT = '+ STRING(TILT,FORMAT='(F6.2)')+' DEGREE'

;loadct,3

;shade_surf,10.*ALOG10(ABS(COMP1)^2.),X,Y,$
;       xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle

;shade_surf,10.*ALOG10(ABS(COMP2)^2.),X,Y,/save,$
;       xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle

;shade_surf,ABS(COMP1)^2./MAX(ABS(COMP1)^2), X,Y,$
;       xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle

;shade_surf,ABS(COMP2)^2./MAX(ABS(COMP2)^2), X,Y,$
;       xrange=[XS,XE],yrange=[YS,YE],/xstyle,/ystyle


DEVICE,/CLOSE

SET_PLOT,'X'

QUIT:

print,'END'

END
