;+
; NAME:
;     FPDB_READCOL
;
; PURPOSE:
;     Reads in to memory one column of the focal plane database.
;     
; CALLING SEQUENCE:
;     fpdb_readcol,fpdbfile,column,data
;
; INPUTS:
;     fpdbfile - char string - Specifies the FP database fits file name
;                              usually called focalplane_db.fits
;     column   - char string - Specifies the number or name of the column.
;
;                              1  = 'detector' 
;                              2  = 'phi_uv'     [deg]
;                              3  = 'theta_uv'   [deg]
;                              4  = 'psi_uv'     [deg]
;                              5  = 'psi_pol'    [deg]
;                              6  = 'nu_cen'     [Hz]
;                              7  = 'nu_min'     [Hz]
;                              8  = 'nu_max'     [Hz]
;                              9  = 'f_knee'     [Hz]
;                              10 = 'alpha'
;                              11 = 'f_min'      [Hz]
;                              12 = 'f_samp'     [Hz]
;                              13 = 'tau_bol'    [s]
;                              14 = 'tau_int'    [s]
;                              15 = 'nread'
;                              16 = 'beamfwhm'   [deg] 
;                              17 = 'ellipticity'
;                              18 = 'psi_ell'    [deg]
;                              19 = 'net_rj  '   [K(Antenna)]
;
; OUTPUTS:
;     data - array           - Contains the fpdb database column. 
; 
; OPTIONAL INPUT KEYWORDS:
;
; COMMON BLOCKS:
;     None.
;
; ROUTINES CALLED:
;
; EXAMPLE:
;     fpdb_readcol,'focalplane_db.fits','detector',data
;
;     
; COMMENTS:
;     
; MODIFICATION HISTORY:
;     initial version, November 2006, S. Leach, SISSA.
;
;-
;======================================================================
;
pro fpdb_readcol, fpdbfile,column,data,ext=ext
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

  if n_elements(ext) eq 0 then ext = 1
  
unit = 1
fxbopen,unit,fpdbfile,ext
fxbread,unit,data,column
fxbclose,unit

END

