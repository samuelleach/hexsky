pro hexskylib

  ;AUTHOR: S. Leach
  ;PURPOSE: Set up environment for using hexsky codes.

  ;USAGE: Place the following lines in you IDL startup file:
  ;  hexskyroot = getenv('HEXSKY')
  ;  DEFSYSV, '!path_sep', ':'
  ;  !path = !path+!path_sep+expand_path('+'+hexskyroot)
  ;  hexskylib

  ;Switch of compile messages
  !QUIET=1

  ;Defines the root directory of the hexsky/ source:
  DEFSYSV,'!HEXSKYROOT', getenv('HEXSKY')
  
  ;Defines the template parameter file for running the hexsky binary from IDL:
;  DEFSYSV,'!HEXSKY_TEMPLATE_PARFILE',!HEXSKYROOT+'/parfiles/na_jupiter8_pend.par'
  DEFSYSV,'!HEXSKY_TEMPLATE_PARFILE',!HEXSKYROOT+'/parfiles/example_ldb.par'

  ;Defines the default CMB template:
  DEFSYSV,'!CMB_TEMPLATE',!HEXSKYROOT+'/data/map_iqu_NOderivs_noB_smooth_8arcmin_2048.fits'

  ;Defines the default dust template and its reference frequency:
  DEFSYSV,'!DUST_TEMPLATE',!HEXSKYROOT+'/data/cbdustmodel_150.000ghz.fits'
  DEFSYSV,'!DUST_TEMPLATE_NUREF',150.

  ;Defines constants, including the Julian day RJD0
  define_constants

  ;Workaround for the fact that astrolib.pro (needed by Healpix)
  ;is platform dependent.
  ;ASTRO_DATA is the environment flag pointing to the directory where
  ;the astrolib JPLEPH.405 is found.
;  astro_data = getenv('ASTRO_DATA')
;  astrolib
;  setenv,'ASTRO_DATA='+astro_data

  astrolib
  setenv,'ASTRO_DATA='+!HEXSKYROOT+'/data'

  ; TEST for GDL
  if (is_gdl()) then begin
    DEFSYSV,'!DIR',!HEXSKYROOT+'/pro/external/ittvis_codes'
  endif
  
  ;Switch back on compile messages
  !QUIET=0

end
