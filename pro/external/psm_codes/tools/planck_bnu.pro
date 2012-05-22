; Copyright 2008 ---- CNRS

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
;Computes the blackbody emission. The output (B_nu) is in W/m2/sr/Hz
; 
; @param nu{in}{required}{type=float} (can be an array of float or double) input frequency in Hz
;
; @keyword  temp{in}{optional}{type=float}{default=2.725K} Temperature at which the blackbody emission law is computed 
; (by default, reads !cosmo_param.t_cmb, or if undefined uses 2.725 K)
; @restrictions Calculation is done in double precision
; @author Jacques DELABROUILLE, delabrouille\@apc.univ-paris7.fr
; @history  Created July 1999</p>
; @history  Now uses !cosmo_param.t_cmb, header updated, Jacques Delabrouille, October 2nd, 2008
; @history <p>Bug corrected for test of existence of !cosmo_param, Jacques Delabrouille, December 5th, 2008</p>
; @copyright CNRS, 2008
; 
;-
FUNCTION PLANCK_BNU, nu, temp=temp, megajysr=megajysr, help=help

  IF KEYWORD_SET(help) NE 0 THEN BEGIN
     PRINT, PSM_STRING_TO_LENGTH('-',LINE_LENGTH(),character='-')
     PRINT, 'PLANCK_BNU: function returning the Planck blackbody spectrum B_nu(T)'
     PSM_INFO_MESSAGE, 'SYNTAX: result = PLANCK_BNU(nu, temp=, /megajysr)'
     PSM_INFO_MESSAGE, "nu is the input frequency in Hz (may be an array)"
     PSM_INFO_MESSAGE, "temp is the temperature in K [default = 2.725K (CMB temperature)]"
     PSM_INFO_MESSAGE, "Set /megajysr for an output in MJy/sr [default W/m2/sr/Hz]"
     PRINT, PSM_STRING_TO_LENGTH('-',LINE_LENGTH(),character='-')
     RETURN, 0
  ENDIF

  c = 299792458d
  h = 6.62607554d-34
  htimes10e20 = 6.62607554d-14
  k = 1.38065812d-23
  hoverk = h/k
  IF KEYWORD_SET(temp) EQ 0 THEN temp = CMB_TEMPERATURE()
  IF KEYWORD_SET(megajysr) NE 0 THEN RETURN, 2*(htimes10e20*nu)*(nu/c)^2 / (EXP(hoverk*nu/temp) - 1d) $
  ELSE RETURN, 2*(h*nu)*(nu/c)^2 / (EXP(hoverk*nu/temp) - 1d)
  
END
