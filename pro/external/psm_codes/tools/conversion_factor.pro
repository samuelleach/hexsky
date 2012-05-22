; Copyright 2007 CNRS, Observatoire de Paris

; This file is part of the Planck Sky Model.
;
; The Planck Sky Model is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free SoftwareFoundation; version 2 of the License.
;
; The Planck Sky Model is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY, without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with the Planck Sky Model. If not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

;+
; Returns the conversion factor between two units in a specified frequency band, or at a given frequency.
; WARNING: frequencies should be given in  *** Hz ***
;
;  @param from_unit {in}{required}{type=string} The unit of input data
;  among the list :
;  ['rad', 'deg', 'arcmin', 'arcsec'; 'Jy/sr','K_CMB','K_RJ','K/KCMB','y_sz','W/m2/sr/Hz'] optionally
;  prefixed by ['n','u','m','k','M','G'] for nano, micro, milli, kilo,
;  Mega, Giga.
;  @param to_unit  {in}{required}{type=string} The unit of input data
;  among the list :
;  ['rad', 'deg', 'arcmin', 'arcsec'; 'Jy/sr','K_CMB','K_RJ','K/KCMB','y_sz','W/m2/sr/Hz'] optionally
;  prefixed by ['n','u','m','k','M','G'] for nano, micro, milli, kilo,
;  Mega, Giga
;  @param band {in}{required}{type = float or string} frequency in <b>Hz</b> (if float) or structure decribing the band, (see GET_BAND_STRUCT)
;  @keyword double {in}{optional}{type = byte} Set for conversion factor in double precision, else simple precision (float is returned). 
;                  The calculation is internally always performed in double precision
;
;  @history <p>30/01/2007: First version, Marc Betoule </p>
;  @history <p>01/02/2007: bug fixed in call to Planck_Bnu, Jacques Delabrouille </p>
;  @history <p>22/02/2007: Add error handling, Marc Betoule </p>
;  @history <p>12/08/2008: Avoid computing when from_unit = to_unit, now allows arrays of freq, Jacques Delabrouille </p>
;  @history <p>02/12/2008: Now accept band information in string format of 'TYPE-VALUE-UNITS', e.g. 'DIRAC-30-GHz', Jacques Delabrouille </p>
;  @history <p>02/12/2008: Reorganisation with a subfunction for better handling band integration, Jacques Delabrouille </p>   
;  @history <p>04/12/2008: /double keyword added, Jacques Delabrouille </p>   
;  @history <p>22/01/2009: Convert prefix only when only the prefix is changed (band-independent), Jacques Delabrouille </p>
;-

;---------------------------------------------------------------------------------------------
FUNCTION MASS_CONVERSION, from_unit, to_unit

  inok = CHECKUNIT(from_unit, prefix_in, core_in, exponent_in, type_in)
  outok = CHECKUNIT(to_unit, prefix_out, core_out, exponent_out, type_out)

  IF from_unit EQ to_unit THEN RETURN, 1. ELSE BEGIN

     ;; nano, micro, milli, kilo, mega, giga
     ;;--------------------------------------
     supported_prefix=['n','u','m','k','M','G']
     pref_val=[1d-9, 1d-6, 1d-3, 1d3, 1d6, 1d9]
     
     ;; Argument parsing
     ;;------------------
     in = core_in
     pref_in = prefix_in
     out = core_out
     pref_out = prefix_out

     IF STRLEN(pref_in) EQ 0 THEN BEGIN
        pref_val_in = 1d 
     ENDIF ELSE BEGIN 
        ipi = WHERE(pref_in eq supported_prefix)
        if ipi EQ -1 then MESSAGE, pref_in + ' is not a recognised prefix, the list of recognised prefixes is : (' + string(supported_prefix,/print) +')'
        pref_val_in = pref_val[ipi]
        pref_val_in = pref_val_in[0]
     ENDELSE
     IF STRLEN(pref_out) EQ 0 THEN BEGIN
        pref_val_out = 1d 
     ENDIF ELSE BEGIN
        ipo = WHERE(pref_out EQ supported_prefix)
        if ipo eq -1 THEN MESSAGE, pref_in + ' is not a recognised prefix, the list of recognised prefixes is : (' + string(supported_prefix,/print) +')'
        pref_val_out = pref_val[ipo]
        pref_val_out = pref_val_out[0]
     ENDELSE

     ;; Factor computation for core unit
     ;;----------------------------------
     CASE core_in OF
        'gram': fac_in=1d0
        'Msun': BEGIN
           DEFSYSV, '!phyconst', exists=exists
           IF NOT exists THEN DEFINE_PHYSICAL_CONSTANTS
           fac_in=!phyconst.M_s*1d3
        END
        ELSE: MESSAGE, 'Unrecognised unit: '+core_in
     ENDCASE
     CASE core_out OF 
        'gram': fac_out=1d0
        'Msun': BEGIN
           DEFSYSV, '!phiconst', exists=exists
           IF NOT exists THEN DEFINE_PHYSICAL_CONSTANTS
           fac_out=1d-3/!phyconst.M_s
        END
     ENDCASE
     
     factor = [(fac_in * fac_out) * (pref_val_in/pref_val_out)]
     IF exponent_in NE 1 THEN factor = factor ^ exponent_in
     
     RETURN, factor[0]
  ENDELSE

END

;---------------------------------------------------------------------------------------------
FUNCTION LENGTH_CONVERSION, from_unit, to_unit

  inok = CHECKUNIT(from_unit, prefix_in, core_in, exponent_in, type_in)
  outok = CHECKUNIT(to_unit, prefix_out, core_out, exponent_out, type_out)

  IF from_unit EQ to_unit THEN RETURN, 1. ELSE BEGIN

     ;; nano, micro, milli, kilo, mega, giga
     ;;--------------------------------------
     supported_prefix=['n','u','m','k','M','G']
     pref_val=[1d-9, 1d-6, 1d-3, 1d3, 1d6, 1d9]
     
     ;; Argument parsing
     ;;------------------
     in = core_in
     pref_in = prefix_in
     out = core_out
     pref_out = prefix_out

     IF STRLEN(pref_in) EQ 0 THEN BEGIN
        pref_val_in = 1d 
     ENDIF ELSE BEGIN 
        ipi = WHERE(pref_in eq supported_prefix)
        if ipi EQ -1 then MESSAGE, pref_in + ' is not a recognised prefix, the list of recognised prefixes is : (' + string(supported_prefix,/print) +')'
        pref_val_in = pref_val[ipi]
        pref_val_in = pref_val_in[0]
     ENDELSE
     IF STRLEN(pref_out) EQ 0 THEN BEGIN
        pref_val_out = 1d 
     ENDIF ELSE BEGIN
        ipo = WHERE(pref_out EQ supported_prefix)
        if ipo eq -1 THEN MESSAGE, pref_in + ' is not a recognised prefix, the list of recognised prefixes is : (' + string(supported_prefix,/print) +')'
        pref_val_out = pref_val[ipo]
        pref_val_out = pref_val_out[0]
     ENDELSE

     ;; Factor computation for core unit
     ;;----------------------------------
     CASE core_in OF
        'meter': fac_in=1d0
        'parsec': fac_in=3.0856775807d+16
        ELSE: MESSAGE, 'Unrecognised unit: '+core_in
     ENDCASE
     CASE core_out OF 
        'meter': fac_out=1d0
        'parsec': fac_out=1d0/3.0856775807d+16
     ENDCASE
     
     factor = [(fac_in * fac_out) * (pref_val_in/pref_val_out)]
     IF exponent_in NE 1 THEN factor = factor ^ exponent_in
     
     RETURN, factor[0]
  ENDELSE

END

;---------------------------------------------------------------------------------------------

FUNCTION ANGLE_CONVERSION, from_unit, to_unit

  inok = CHECKUNIT(from_unit, prefix_in, core_in, exponent_in, type_in)
  outok = CHECKUNIT(to_unit, prefix_out, core_out, exponent_out, type_out)

  IF from_unit EQ to_unit THEN RETURN, 1. ELSE BEGIN

     ;; nano, micro, milli, kilo, mega, giga
     ;;--------------------------------------
     supported_prefix=['n','u','m','k','M','G']
     pref_val=[1d-9, 1d-6, 1d-3, 1d3, 1d6, 1d9]
     
     ;; Argument parsing
     ;;------------------
     in = core_in
     pref_in = prefix_in
     out = core_out
     pref_out = prefix_out

     IF STRLEN(pref_in) EQ 0 THEN BEGIN
        pref_val_in = 1d 
     ENDIF ELSE BEGIN 
        ipi = WHERE(pref_in eq supported_prefix)
        if ipi EQ -1 then MESSAGE, pref_in + ' is not a recognised prefix, the list of recognised prefixes is : (' + string(supported_prefix,/print) +')'
        pref_val_in = pref_val[ipi]
        pref_val_in = pref_val_in[0]
     ENDELSE
     IF STRLEN(pref_out) EQ 0 THEN BEGIN
        pref_val_out = 1d 
     ENDIF ELSE BEGIN
        ipo = WHERE(pref_out EQ supported_prefix)
        if ipo eq -1 THEN MESSAGE, pref_in + ' is not a recognised prefix, the list of recognised prefixes is : (' + string(supported_prefix,/print) +')'
        pref_val_out = pref_val[ipo]
        pref_val_out = pref_val_out[0]
     ENDELSE

     ;; Factor computation for core unit
     ;;----------------------------------
     CASE core_in OF
        'rad': fac_in=180D0/!dpi
        'deg': fac_in=1D0
        'arcmin': fac_in=1D0/60D0
        'arcsec': fac_in=1D0/3600D0
        ELSE: MESSAGE, 'Unrecognised unit: '+core_in
     ENDCASE
     CASE core_out OF 
        'rad': fac_out=!dpi/180D0
        'deg': fac_out=1D0
        'arcmin': fac_out=60D0
        'arcsec': fac_out=3600D0
     ENDCASE
     
     factor = [(fac_in * fac_out) * (pref_val_in/pref_val_out)]
     IF exponent_in NE 1 THEN factor = factor ^ exponent_in
     
     RETURN, factor[0]
  ENDELSE

END

;---------------------------------------------------------------------------------------------

FUNCTION CONVERSION_FACTOR_FROM_FREQ, from_unit, to_unit, freq_Hz
  
  inok = CHECKUNIT(from_unit, prefix_in, core_in, exponent_in, type_in)
  outok = CHECKUNIT(to_unit, prefix_out, core_out, exponent_out, type_out)

  IF DEFINED(freq_Hz) THEN BEGIN
     COMMON psm, param 
     IF DEFINED(param) THEN BEGIN
        IF param.run.carefulness GE 1 THEN BEGIN
           IF MIN(freq_Hz) LT 1e8 THEN MESSAGE, 'Input frequency to conversion_factor seems to be in GHz...'
        ENDIF
     ENDIF
     freq = freq_Hz/1e9
  ENDIF

  IF from_unit EQ to_unit THEN BEGIN
     IF ISARRAY(freq_Hz) THEN RETURN, REPLICATE(1., N_ELEMENTS(freq_Hz)) ELSE RETURN, 1. 
  ENDIF ELSE BEGIN

     supported_units=['Jy/sr','K_CMB','K_RJ','K/KCMB','y_sz','W/m2/sr/Hz','taubetat2']

     ;; nano, micro, milli, kilo, mega, giga
     ;;--------------------------------------
     supported_prefix=['n','u','m','k','M','G']
     pref_val=[1d-9, 1d-6, 1d-3, 1d3, 1d6, 1d9]
     
     ;; Argument parsing
     ;;------------------
     in = core_in
     pref_in = prefix_in
     out = core_out
     pref_out = prefix_out
  
     IF STRLEN(pref_in) EQ 0 THEN BEGIN
        pref_val_in = 1d 
     ENDIF ELSE BEGIN 
        ipi = WHERE(pref_in eq supported_prefix)
        if ipi EQ -1 then MESSAGE, pref_in + ' is not a recognised prefix, the list of recognised prefixes is : (' + string(supported_prefix,/print) +')'
        pref_val_in = pref_val[ipi]
        pref_val_in = pref_val_in[0]
     ENDELSE
     IF STRLEN(pref_out) EQ 0 THEN BEGIN
        pref_val_out = 1d 
     ENDIF ELSE BEGIN
        ipo = WHERE(pref_out EQ supported_prefix)
        if ipo eq -1 THEN MESSAGE, pref_in + ' is not a recognised prefix, the list of recognised prefixes is : (' + string(supported_prefix,/print) +')'
        pref_val_out = pref_val[ipo]
        pref_val_out = pref_val_out[0]
     ENDELSE
     
  
     ;; Factor computation for core unit
     ;;----------------------------------
     DEFSYSV, '!phyconst', exist=exist
     IF not exist THEN BEGIN
        IF PSM_CAREFULNESS() GE 1 THEN PSM_INFO_MESSAGE, 'Warning, physical constants not defined -- using default values in CONVERSION_FACTOR'
        h = 6.6260693d-34
        k = 1.3806505d-23
        c = 299792458d
     ENDIF ELSE BEGIN
        h = !phyconst.h
        k = !phyconst.k
        c = !phyconst.c
     ENDELSE
     T = CMB_TEMPERATURE()

     IF core_in EQ core_out THEN BEGIN
        fac_in=1
        fac_out=1
     ENDIF ELSE BEGIN

        skipconversion = 0B

        IF (core_in EQ 'K_CMB') AND (core_out EQ 'K/KCMB') THEN BEGIN
           skipconversion = 1B
           fac_in = 1
           fac_out = 1./T
        ENDIF
        
        IF (core_in EQ 'K/KCMB') AND (core_out EQ 'K_CMB') THEN BEGIN
           skipconversion = 1B
           fac_in = 1
           fac_out = T
        ENDIF
        
        IF NOT skipconversion THEN BEGIN
           nu = freq * 1d9
           x = h*nu/k/T
           ex = exp(x)
           CASE in OF
              'Jy/sr' : fac_in = 1d-26
              'K_CMB' : fac_in = planck_dBnu_dT(nu,temp=T)
              'K_RJ' : fac_in = 2d*nu^2*k/c^2
              'K/KCMB' : fac_in = T * planck_dBnu_dT(nu,temp=T)
              'y_sz' : fac_in = x * ex / (ex-1d) * (x*(ex+1d)/(ex-1d) - 4d) * planck_bnu(nu,temp=T)
              'W/m2/sr/Hz': fac_in = REPLICATE(1d, N_ELEMENTS(nu))
              'taubetat2': fac_in = 0.1d * ex * (ex + 1d) / (2d * (ex - 1d)^2) * x^2 * planck_bnu(nu,temp=T)
              ELSE : MESSAGE, from_unit + ' is not a recognised unit, the list of recognised units is :'+string(10b)+$
                              ' (' + string(supported_units,/print) + ')' +string(10b)+$
                              'with optionally a prefix in : (' + string(supported_prefix,/print) +')'
           ENDCASE
           CASE out OF
              'Jy/sr' : fac_out = 1d26
              'K_CMB' : fac_out = 1d / planck_dBnu_dT(nu,temp=T)
              'K_RJ' : fac_out = 1d/(2d*nu^2*k/c^2)
              'K/KCMB' : fac_out = 1d/(planck_dBnu_dT(nu,temp=T) * T)
              'y_sz' : fac_out = 1d / (x * ex / (ex-1d) * (x*(ex+1d)/(ex-1d) - 4d) * planck_bnu(nu,temp=T))
              'W/m2/sr/Hz': fac_out = REPLICATE(1d, N_ELEMENTS(nu))
              'taubetat2': fac_out = 1d/(0.1d * ex * (ex + 1d) / (2d * (ex - 1d)^2) * x^2 * planck_bnu(nu,temp=T))
              ELSE : MESSAGE, to_unit + ' is not a recognised unit, the list of recognised units is :'+string(10b)+$
                              ' (' + string(supported_units,/print) + ')' +string(10b)+$
                              'with optionally a prefix in : (' + string(supported_prefix,/print) +')'
           ENDCASE
        ENDIF
     ENDELSE

     factor = [(fac_in * fac_out) * (pref_val_in/pref_val_out)]
     IF exponent_in NE 1 THEN factor = factor ^ exponent_in
     IF N_PARAMS() EQ 2 THEN RETURN, factor[0] ELSE $
     IF (N_ELEMENTS(factor) EQ 1) THEN RETURN, factor[0] ELSE RETURN, factor
     
  ENDELSE

END

;---------------------------------------------------------------------------------------------
; MAIN FUNCTION
;---------------------------------------------------------------------------------------------

FUNCTION CONVERSION_FACTOR, from_unit, to_unit, band, double=double, help=help

  IF KEYWORD_SET(help) NE 0 THEN BEGIN
     PRINT, PSM_STRING_TO_LENGTH('-',LINE_LENGTH(),character='-')
     PRINT, 'CONVERSION_FACTOR: function which gives the conversion between an input unit and an output unit'
     PSM_INFO_MESSAGE, 'SYNTAX: result = CONVERSION_FACTOR(from_unit, to_unit, band, double=)'
     PSM_INFO_MESSAGE, "'from_unit' is the input unit"
     PSM_INFO_MESSAGE, "'to_unit' is the output unit"
     PSM_INFO_MESSAGE, "'band' optionnally specifies the frequency band in which the conversion is to be made."
     PSM_INFO_MESSAGE, "allowed angle units: ['rad', 'deg', 'arcmin', 'arcsec']"
     PSM_INFO_MESSAGE, "allowed flux units: ['Jy/sr','K_CMB','K_RJ','K/KCMB','y_sz','W/m2/sr/Hz']"
     PSM_INFO_MESSAGE, "allowed prefixes : ['n','u','m','k','M','G']"
     PSM_INFO_MESSAGE, "exponents are taken into account with the conventional format, e.g. '(deg)**2'"
     PSM_INFO_MESSAGE, "'band' is used for frequency-dependent conversion, e.g. mK_RJ --> MJy/sr"
     PSM_INFO_MESSAGE, "set /double for double precision output"
     PRINT, PSM_STRING_TO_LENGTH('-',LINE_LENGTH(),character='-')
     RETURN, 0
  ENDIF


  inok = CHECKUNIT(from_unit, prefix_in, core_in, exponent_in, type_in)
  outok = CHECKUNIT(to_unit, prefix_out, core_out, exponent_out, type_out)
  IF NOT inok THEN MESSAGE, 'Input units not recognised'
  IF NOT outok THEN MESSAGE, 'Output units not recognised'

  IF type_in NE type_out THEN MESSAGE, 'Cannot convert '+type_in+' into '+type_out
  IF exponent_in NE exponent_out THEN MESSAGE, 'Cannot convert '+from_unit+' into '+to_unit



  ;; Process differently different types of units
  ;;----------------------------------------------
  CASE type_in OF 

     ;; Flux conversion
     ;;-----------------
     'flux':BEGIN

        ;; Create output factor (may be an array)
        IF DEFINED(band) THEN nbands = N_ELEMENTS(band) ELSE nbands=1
        IF KEYWORD_SET(double) NE 0 THEN output_factor = DBLARR(nbands) ELSE output_factor = FLTARR(nbands) 
        
        ;; If band is a number or array of numbers, then assumed to be DIRAC everywhere, otherwise read the type of band
        IF DEFINED(band) THEN s = SIZE(band, /type) ELSE s = 0
        IF s LE 5 THEN BEGIN
           IF DEFINED(band) THEN nu_c = band ELSE nu_c = FLOAT('Inf')
           bandtype = REPLICATE('DIRAC',N_ELEMENTS(nu_c)) 
        ENDIF
        IF s EQ 8 THEN BEGIN
           nbands = N_ELEMENTS(band)
           IF nbands NE 1 THEN MESSAGE, 'Case not implemented'
           IF band.shape EQ 'DIRAC' THEN nu_c = band.nu_c
           bandtype = STRARR(nbands)
           FOR i=0, nbands-1 DO BEGIN
              bandtype[i] = STRSPLIT(band[i].shape, '-', /extract)
           ENDFOR
        ENDIF
        
        ;; Compute conversion factor for each band
        ;;-----------------------------------------
        FOR i=0, nbands-1 DO BEGIN
           CASE bandtype[i] OF 
              'DIRAC': BEGIN
                 IF nu_c[i] LE 1e8 THEN MESSAGE, 'Now conversion_factor accepts input in Hz, not GHz. Sorry, but please fix your code !'
                 output_factor[i] = CONVERSION_FACTOR_FROM_FREQ(from_unit, to_unit, nu_c[i])
              END
              'TOPHAT': BEGIN         
                 ;; generate an array of frequencies
                 freq = ((DINDGEN(1000)+0.5)/1000d)*(band[i].nu_max-band[i].nu_min) + band[i].nu_min
                 ;; compute the emission law of the input units
                 numerator = CONVERSION_FACTOR_FROM_FREQ(from_unit, 'MJy/sr', freq)
                 ;; compute the emission law of the output units
                 denominator = CONVERSION_FACTOR_FROM_FREQ(to_unit, 'MJy/sr', freq)
                 ;; simple integral (no normalisation of the band because it cancels out)
                 output_factor[i] = TOTAL(numerator)/TOTAL(denominator)
              END
              'TABLE': BEGIN
                 ;; compute the emission law of the input units at all band frequencies
                 numerator = band.value * CONVERSION_FACTOR_FROM_FREQ(from_unit, 'MJy/sr', band.nu)
                 ;; compute the emission law of the output units
                 denominator = band.value * CONVERSION_FACTOR_FROM_FREQ(to_unit, 'MJy/sr', band.nu)
                 ;; integrate as in bandintegrated_emlaw (no normalisation of the band because it cancels out)
                 output_factor[i] = INT_TABULATED(band.nu, numerator) / INT_TABULATED(band.nu, denominator)
              END
              'INSTR': BEGIN
                 ;; load band data if necessary
                 IF NOT PTR_VALID(band.data) THEN FILL_BAND_DATA, band
                 output_factor[i] = CONVERSION_FACTOR(from_unit, to_unit, *band.data, double=double)
              END
              ELSE: BEGIN
                 MESSAGE, 'Band shape not implemented yet in conversion_factor', /info
                 output_factor[i] = 'NaN'
              END
           ENDCASE
        ENDFOR
        
        IF N_ELEMENTS(output_factor) GT 1 THEN BEGIN
           IF KEYWORD_SET(double) NE 0 THEN RETURN, DOUBLE(output_factor) ELSE RETURN, FLOAT(output_factor)
        ENDIF ELSE BEGIN
           IF KEYWORD_SET(double) NE 0 THEN RETURN, DOUBLE(output_factor[0]) ELSE RETURN, FLOAT(output_factor[0])
        ENDELSE
        
     END

     ;; Angle conversion
     ;;------------------
     'angle': BEGIN
        result = ANGLE_CONVERSION(from_unit, to_unit)
        IF KEYWORD_SET(double) NE 0 THEN RETURN, DOUBLE(result) ELSE RETURN, FLOAT(result)
     END

     ;; Length conversion
     ;;------------------
     'length': BEGIN
        result = LENGTH_CONVERSION(from_unit, to_unit)
        IF KEYWORD_SET(double) NE 0 THEN RETURN, DOUBLE(result) ELSE RETURN, FLOAT(result)
     END

     ;; Length conversion
     ;;------------------
     'mass': BEGIN
        result = MASS_CONVERSION(from_unit, to_unit)
        IF KEYWORD_SET(double) NE 0 THEN RETURN, DOUBLE(result) ELSE RETURN, FLOAT(result)
     END

  ENDCASE

END
