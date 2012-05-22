PRO READ_PPL_FILE, ringpointing, file=file, after_date=after_date, before_date=before_date

  IF NOT KEYWORD_SET(file) THEN file=FIX_SEPARATOR(!PSMROOT)+'data/Instrument/planck_realistic_v1/PPL/20090524_20101114_0010_L.PPL.txt'
  READCOL, file, ringnum, elon, elat, t0, t1, t2, duration, minduration, label, format='L,D,D,A,A,A,L,L,I', skipline=2
  
  date = PSM_STR_REPLACE(t0, 'T', ' ')
  date = PSM_STR_REPLACE(date, 'Z', '')
  
  
  
  IF KEYWORD_SET(after_date) EQ 0 THEN after_date = '2009-08-07 12:00:00' ; 7 august 2009
  IF KEYWORD_SET(before_date) EQ 0 THEN before_date = '2011-05-06 12:00:00' ; 6 may 2011
 
  nd = N_ELEMENTS(date)
  modified_jd = DBLARR(nd)
  FOR i=0L, nd-1 DO modified_jd[i] = DATE_CONV(date[i],'MODIFIED')
  after_jd = DATE_CONV(after_date,'MODIFIED')
  before_jd = DATE_CONV(before_date,'MODIFIED')
  wh = WHERE((modified_jd GT after_jd) AND (modified_jd+duration/24d/3600d LT before_jd), nwh)
  IF nwh GT 0 THEN BEGIN
     dtor = !DPI/180d0
     ring = {ringnum:0L, elon_rad:0d0, elat_rad:0d0, glon_rad:0d0, glat_rad:0d0, date:'', mjd:0d0, duration:0d0}
     ringpointing = REPLICATE(ring,nwh)
     ringpointing.ringnum = ringnum[wh]
     ringpointing.elon_rad = elon[wh]*dtor
     ringpointing.elat_rad = elat[wh]*dtor
     ringpointing.date = date[wh]
     ringpointing.mjd = modified_jd[wh]
     ringpointing.duration = duration[wh]
     EULER, ringpointing.elon_rad, ringpointing.elat_rad, glon, glat, 5, /radian
     ringpointing.glon_rad = glon
     ringpointing.glat_rad = glat
  ENDIF ELSE MESSAGE, 'No ring begins after '+after_date + ' and ends before '+before_date

END
