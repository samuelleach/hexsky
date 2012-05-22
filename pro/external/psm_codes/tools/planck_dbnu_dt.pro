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
;Computes the derivative with respect to temperature of a blackbody emission. The output (dB_nu/dT) is in W/m2/sr/Hz/K
; 
; @param nu{in}{required}{type=double} (can be an array of float or double) input frequency in Hz
;
; @keyword  temp{in}{optional}{type=float}{default=2.725K} Temperature at which the derivative is computed 
; (by default, reads !cosmo_param.t_cmb, or if undefined uses 2.725 K)
; @restrictions Calculation is done in double precision
; @author Jacques DELABROUILLE, delabrouille\@apc.univ-paris7.fr
; @history  Created July 1999</p>
; @history  <p>Now uses !cosmo_param.t_cmb, header updated, some optimization, Jacques Delabrouille, October 2nd, 2008</p>
; @history <p>Bug corrected for test of existence of !cosmo_param, Jacques Delabrouille, December 5th, 2008</p>
; @copyright CNRS, 2008
; 
;-
FUNCTION planck_dBnu_dT, nu, temp=temp

c = 299792458d
h = 6.62607554d-34
k = 1.38065812d-23
IF KEYWORD_SET(temp) EQ 0 THEN BEGIN
   DEFSYSV, 'cosmo_param', exists = cosmo_is_defined
   IF cosmo_is_defined EQ 0 THEN temp = 2.725d0 ELSE temp = !cosmo_param.t_cmb
ENDIF

b_nu = planck_bnu(nu,temp=temp)

RETURN, (b_nu*c/nu/temp)^2 / 2d0 * EXP(h*nu/k/temp) / k
END
