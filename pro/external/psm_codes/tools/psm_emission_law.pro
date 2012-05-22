; Copyright 2008 ----  CNRS

; This file is part of the Planck Sky Model.
;
; The Planck Sky Model is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; version 2 of the License.
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
;Function to compute any emission law among the following: CMB, Blackbody, Greybody (with power law emissivity), Power Law, Curved Power Law.
;The output units are W/m2/sr/Hz. Spectral indices are assumed to properly describe the emission law in the same units. 
;
; 
; @param emission_name{in}{required}{type=string} Can be either blackbody, or greybody, or powerlaw, or curvedpowerlaw.
; @param nu{in}{required}{type=float} frequency at which the function should be computed (in Hz). May be an array. 

; @keyword  nuref{in}{optionnal}{type=float} reference frequency (in Hz), at which the emission equals value_ref (or 1 by default). Required for emission_law = 'greybody' or 'powerlaw' or 'curvedpowerlaw'
; @keyword  valueref{in}{optional}{type=float} value of the emission law at nu=nuref (default is 1). 
; @keyword  temp{in}{required}{type=float} value of the temperature for a blackbody or a greybody, in Kelvin (no default value, but required only for emission_law = 'greybody' or 'blackbody'). 
; @keyword  specind{in}{required}{type=float} value of the spectral index used in the function (no default value, but required only  for emission_law = 'greybody' or 'powerlaw' or 'curvedpowerlaw'). 
; @keyword  curvamp{in}{required}{type=float} value of the amplitude of the spectral index curvature  (no default value, but required only  for emission_law = 'curvedpowerlaw'). 
; @keyword  curvnuref{in}{required}{type=float} value of the reference frequency for the spectral index curvature  (no defaut value, but required only  for emission_law = 'curvedpowerlaw'). 

; @author Jacques DELABROUILLE, delabrouille\@apc.univ-paris7.fr
; @history  First version Tue Aug 12, 2008
; @copyright CNRS, 2008
; 
;-
FUNCTION PSM_EMISSION_LAW, emission_name, nu, nuref=nuref, valueref=valueref, temp=temp, specind=specind, curvamp=curvamp, curvnuref=curvnuref

IF NOT KEYWORD_SET(valueref) THEN use_value_ref=1. ELSE use_value_ref=value_ref

CASE STRUPCASE(emission_name) OF 
'CMB': BEGIN   
   res = PLANCK_DBNU_DT(nu, temp=temp)
END
'BLACKBODY': BEGIN
   IF NOT KEYWORD_SET(temp) THEN MESSAGE, 'temperature value needed for computing blackbody emission'
   res = PLANCK_BNU(nu, temp=temp)
END
'GREYBODY': BEGIN
   IF NOT KEYWORD_SET(nuref) THEN MESSAGE, 'reference frequency value needed for computing greybody emission'
   IF NOT KEYWORD_SET(specind) THEN MESSAGE, 'emissivity spectral index value needed for computing greybody emission'
   res = use_value_ref * (nu/nuref)^specind * (PLANCK_BNU(nu, temp=temp)/PLANCK_BNU(nuref, temp=temp)) 
END
'POWERLAW': BEGIN
   IF NOT KEYWORD_SET(nuref) THEN MESSAGE, 'reference frequency value needed for computing power law emission'
   IF NOT KEYWORD_SET(specind) THEN MESSAGE, 'spectral index value needed for computing power law emission'
   res = use_value_ref * (nu/nuref)^specind
END
'CURVEDPOWERLAW': BEGIN
   IF NOT KEYWORD_SET(nuref) THEN MESSAGE, 'reference frequency value needed for computing curved power law emission'
   IF NOT KEYWORD_SET(specind) THEN MESSAGE, 'spectral index value needed for computing curved power law emission'
   IF NOT KEYWORD_SET(curvamp) THEN MESSAGE, 'amplitude of spectral index curvature term needed for computing curved power law emission'
   IF NOT KEYWORD_SET(curvnuref) THEN MESSAGE, 'reference frequency for spectral index curvature term needed for computing curved power law emission'
   res = use_value_ref * (nu/nuref)^(specind + curvamp*ALOG10(nu/curvnuref))
END
ENDCASE

RETURN, res

END
