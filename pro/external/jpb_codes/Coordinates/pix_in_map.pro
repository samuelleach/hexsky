FUNCTION pix_in_map,fits_header,pixx,pixy,within=within

;decides if given pixels are inside the map described by fits_header
;within a margin given by within (in degrees)

message,'Entering pixinmap',/info

naxis1=sxpar(fits_header,'NAXIS1')
naxis2=sxpar(fits_header,'NAXIS2')

Npix=(size(pixx))(1)
is_in_map=bytarr(Npix)

ind=where(pixx GE 0 AND pixx LE (Naxis1-1) AND pixy GE 0 AND pixy LE (Naxis2-1),count)
;stop
IF count NE 0 THEN BEGIN
  is_in_map(ind)=1
ENDIF

;goto,sortie

IF keyword_set(within) THEN BEGIN
  h2pix,fits_header,/silent
  ind=where(is_in_map NE 1,count)
  IF count NE 0 THEN BEGIN
;    pix2coo2,pixx(ind),pixy(ind),c1,c2,/silent
    FOR i=0L,count-1 DO BEGIN
      pix2coo2,pixx(ind(i)),pixy(ind(i)),c1,c2,/silent
      is=pixx(ind(i))>0<(naxis1-1) & js=pixy(ind(i))>0<(naxis2-1)   ;starting point
      pix2coo2,is,js,cc1,cc2,/silent
;      gcirc,0,c1(i)/!radeg,c2(i)/!radeg,cc1/!radeg,cc2/!radeg,dist
      gcirc,0,c1/!radeg,c2/!radeg,cc1/!radeg,cc2/!radeg,dist
      ia=is & ic=is & ja=js & jc=js & dc=dist & da=dist
      IF dist*!radeg GT within THEN BEGIN
        darr=[dc,da] & diffdarr=[-1.,-1.]
        WHILE min(diffdarr) LT 0. DO BEGIN
          next=next_edge_pix(naxis1,naxis2,ia,ja,/anticlockwise)
          iia=next(0) & jja=next(1)
          next=next_edge_pix(naxis1,naxis2,ic,jc)
          iic=next(0) & jjc=next(1)
          pix2coo2,iia,jja,ca1,ca2,/silent
          pix2coo2,iic,jjc,cc1,cc2,/silent
;          gcirc,0,c1(i)/!radeg,c2(i)/!radeg,ca1/!radeg,ca2/!radeg,dista
;          gcirc,0,c1(i)/!radeg,c2(i)/!radeg,cc1/!radeg,cc2/!radeg,distc
          gcirc,0,c1/!radeg,c2/!radeg,ca1/!radeg,ca2/!radeg,dista
          gcirc,0,c1/!radeg,c2/!radeg,cc1/!radeg,cc2/!radeg,distc
          diffdarr=[distc-dist,dista-dist]
          darr=[distc,dista]
          dist=min(darr)
        ENDWHILE
        IF dist*!radeg LE within THEN is_in_map(ind(i))=1
      ENDIF ELSE BEGIN
        is_in_map(ind(i))=1
      ENDELSE
    ENDFOR
  ENDIF
ENDIF


sortie:
message,'Leaving pixinmap',/info

RETURN,is_in_map

END