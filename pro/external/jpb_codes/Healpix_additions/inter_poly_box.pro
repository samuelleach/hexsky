FUNCTION inter_poly_box,i_polygon,j_polygon,i_box,j_box,inside_vec

;compute the surface intersection between a polygon and a box
;(a rectangle along coordinate axis)

Npoly=4
Nbox=4

;plot,i_polygon,j_polygon,psym=-4,/ysty
;oplot,i_box,j_box,psym=-4,color=100

ind=where(inside_vec EQ 1,count,complement=indd)
;print,'count=',count
;stop
CASE count of
  4:BEGIN   ;4 box corners inside polygone
    RETURN,1.0
;   poly_area(i_polygon,j_polygon)
  END
  3:BEGIN
    ii=1
    ib0=i_box(indd(0)) & jb0=j_box(indd(0))
    ifrom1=ib0 & jfrom1=jb0
    ifrom2=ib0 & jfrom2=jb0
    next=(indd(0)+1) MOD Nbox
    prev=(indd(0)+Nbox-1) MOD Nbox
    ito1=i_box(next) & jto1=j_box(next)
    ito2=i_box(prev) & jto2=j_box(prev)
    ipol=replicate(ib0,4) & jpol=replicate(jb0,4)
  END
  1:BEGIN
    ii=1
    ib0=i_box(ind(0)) & jb0=j_box(ind(0))
    ifrom1=ib0 & jfrom1=jb0
    ifrom2=ib0 & jfrom2=jb0
    next=(ind(0)+1) MOD Nbox
    prev=(ind(0)+Nbox-1) MOD Nbox
    ito1=i_box(next) & jto1=j_box(next)
    ito2=i_box(prev) & jto2=j_box(prev)
    ipol=replicate(ib0,4) & jpol=replicate(jb0,4)
  END
  2:BEGIN
    ii=1
    ipol=replicate(0.,5) & jpol=replicate(0.,5)
    ipol(0)=i_box(ind(0)) & jpol(0)=j_box(ind(0))
    ifrom1=i_box(ind(0)) & jfrom1=j_box(ind(0))
    ifrom2=i_box(ind(1)) & jfrom2=j_box(ind(1))
    next=(ind(0)+1) MOD Nbox
    prev=(ind(0)+Nbox-1) MOD Nbox
    IF next EQ ind(1) THEN BEGIN
      ito1=i_box(prev) & jto1=j_box(prev)
    ENDIF ELSE BEGIN
      ito1=i_box(next) & jto1=j_box(next)
    ENDELSE
    next=(ind(1)+1) MOD Nbox
    prev=(ind(1)+Nbox-1) MOD Nbox
    IF next EQ ind(0) THEN BEGIN
      ito2=i_box(prev) & jto2=j_box(prev)
    ENDIF ELSE BEGIN
      ito2=i_box(next) & jto2=j_box(next)
    ENDELSE
  END
  ELSE:BEGIN
    RETURN,0.
  END
ENDCASE    
ninter=0
curp=0
WHILE ninter NE 1 DO BEGIN  ;search for the first intersection
  curpp=(curp+1) MOD Npoly
  ip0=i_polygon(curp) & jp0=j_polygon(curp)
  ip1=i_polygon(curpp) & jp1=j_polygon(curpp)
  ninter=ninter+inter_segments(ifrom1,jfrom1,ito1,jto1,ip0,jp0,ip1,jp1,i_inter,j_inter)
  curp=curpp
ENDWHILE
ipol(ii)=i_inter & jpol(ii)=j_inter & ii=ii+1
;   start at previous value of curp, since this is the most likely guess
curp=(curpp+Npoly-1) MOD Npoly
kk=0
WHILE ninter NE 2 DO BEGIN  ;search for the second intersection
  curpp=(curp+1) MOD Npoly
  ip0=i_polygon(curp) & jp0=j_polygon(curp)
  ip1=i_polygon(curpp) & jp1=j_polygon(curpp)
  ninter=ninter+inter_segments(ifrom2,jfrom2,ito2,jto2,ip0,jp0,ip1,jp1,i_inter,j_inter)
  curp=curpp
  kk=kk+1
ENDWHILE
IF count EQ 2 THEN BEGIN
  IF kk NE 1 THEN BEGIN
    ipol(ii)=ip0
    jpol(ii)=jp0
    ii=ii+1
  ENDIF
  ipol(ii)=i_inter & jpol(ii)=j_inter & ii=ii+1
  IF count EQ 2 THEN BEGIN
    ipol(ii)=i_box(ind(1))
    jpol(ii)=j_box(ind(1))
    ii=ii+1
  ENDIF
ENDIF ELSE BEGIN
  IF kk NE 1 THEN BEGIN
    ipol(ii)=ip1
    jpol(ii)=jp1
    ii=ii+1
  ENDIF
  ipol(ii)=i_inter & jpol(ii)=j_inter & ii=ii+1
ENDELSE
;oplot,[ipol(0:ii-1),ipol(0)],[jpol(0:ii-1),jpol(0)],color=150
;IF count EQ 2 THEN stop
surf=poly_area(ipol(0:ii-1),jpol(0:ii-1))
IF count EQ 3 THEN BEGIN
  surf=1.-surf
ENDIF

RETURN,surf

END
