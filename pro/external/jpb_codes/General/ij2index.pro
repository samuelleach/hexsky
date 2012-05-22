FUNCTION ij2index,ij,sizes
;+
; NAME:
;       ij2index
; CALLING SEQUENCE:
;       index=ij2index(ij,sizes)
; PURPOSE:
;       returns the index in a 2D or 3D array of coo
; INPUTS:
;       ij    = pixel values for which the index is needed
;	   sizes = array dimensions
; OPTIONAL INPUT:
;	   None
; OUTPUTS:
;	   index
; PROCEDURE AND SUBROUTINE USED
; SIDE EFFECTS:
; MODIFICATION HISTORY:
;       written by Jean-Philippe Bernard 09-92
; EXAMPLE:
;       a=fltarr(12,15,17)
;       a(10,10,5)=1 & a(11,5,16)=1
;       ind=where(a NE 0,count)
;       ij=index2ij(ind,[12,15,17])
;       help,ij
;       print,ij
;       ind2=ij2index(ij,[12,15,17])
;       print,ind,ind2
;-
;on_error,2

IF n_params(0) NE 2 THEN BEGIN
  print,'Calling sequence: index=ij2index(coo,sizes)'
  goto,sortie
ENDIF

taille = n_elements(sizes)
index = round(ij(*,0))
prod = 1l

FOR i=0l,taille-2 DO BEGIN
  prod = prod*sizes(i)
  index = index + prod*round(ij(*,i+1))
ENDFOR

;IF n_params(0) EQ 3 THEN BEGIN
;  index=1l*(coo(*,2)*sx*sy+coo(*,1)*sx+coo(*,0))
;ENDIF ELSE BEGIN
;  index=1l*(coo(*,1)*sx+coo(*,0))
;ENDELSE

RETURN,index

sortie:

end
