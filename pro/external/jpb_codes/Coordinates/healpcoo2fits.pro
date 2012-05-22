PRO healpcoo2fits,lon,lat,healp_header,fits_header,llon,llat

equinox_fits=sxpar(fits_header,'EQUINOX',count=count)
IF count EQ 0 THEN equinox_fits=1950.
equinox_healp=sxpar(healp_header,'EQUINOX')
IF count EQ 0 THEN equinox_healp=1950.

llon=lon & llat=lat
csys_fits=strmid(sxpar(fits_header,'CTYPE1'),0,4)
csys_healp=strtrim(sxpar(healp_header,'COORDSYS'),2)

message,'csys fits ='+csys_fits,/info
message,'csys healp='+csys_healp,/info
message,'equinox fits='+strtrim(equinox_fits,2),/info
message,'equinox healp='+strtrim(equinox_healp,2),/info

ccode=0
CASE csys_fits OF
  'RA--': BEGIN
    CASE csys_healp OF
      'E': ccode=4
      'G': ccode=2
      'C': ccode=0
    ENDCASE
  END
  'GLON': BEGIN
    CASE csys_healp OF
      'E': ccode=5
      'C': ccode=1
      'G': ccode=0
    ENDCASE
  END
  'ELON':BEGIN
    CASE csys_healp OF
      'G': ccode=6
      'C': ccode=3
      'E': ccode=0
    ENDCASE
  END
ENDCASE
message,'ccode='+strtrim(ccode,2),/info

IF ccode NE 0 THEN BEGIN
  IF csys_healp EQ 'C' THEN BEGIN
    IF equinox_healp NE astron_default_equinox() THEN BEGIN
      precess_array,lon,lat,equinox_healp,astron_default_equinox()
    ENDIF
  ENDIF
  euler,lon,lat,llon,llat,ccode
  IF csys_fits EQ 'RA--' THEN BEGIN
    IF equinox_fits NE astron_default_equinox() THEN BEGIN
      precess,llon,llat,astron_default_equinox(),equinox_fits
    ENDIF
  ENDIF
ENDIF ELSE BEGIN
  IF csys_fits EQ 'RA--' THEN BEGIN
    IF equinox_fits NE equinox_healp THEN BEGIN
      precess,llon,llat,equinox_healp,equinox_fits
    ENDIF
  ENDIF
ENDELSE

END