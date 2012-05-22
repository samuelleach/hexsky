FUNCTION inter_segments,ib0,jb0,ib1,jb1,ip0,jp0,ip1,jp1,i_inter,j_inter

lint,[ib0,jb0],[ib1,jb1],[ip0,jp0],[ip1,jp1],res,flag=flag

fflag=0
IF flag EQ 1 THEN BEGIN
  i_inter=res(0)
  j_inter=res(1)
  IF i_inter GE min([ib0,ib1]) AND i_inter LE max([ib0,ib1]) AND $
     j_inter GE min([jb0,jb1]) AND j_inter LE max([jb0,jb1]) THEN BEGIN
     fflag=1
  ENDIF
ENDIF

RETURN,fflag

END
