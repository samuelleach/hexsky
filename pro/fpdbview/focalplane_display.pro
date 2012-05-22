;+
; NAME:
;     FOCALPLANE_DISPLAY
;
; PURPOSE:
;     Displays the Planck focalplane.
;     
; CALLING SEQUENCE:
;     focalplane_display,fpdbfile
;
; INPUTS:
;     fpdbfile - char string - Specifies the FP database fits file name
;                              usually called focalplane_db.fits
;
; OUTPUTS:
;
; OPTIONAL INPUT KEYWORDS:
;
; COMMON BLOCKS:
;     None.
;
; ROUTINES CALLED:
;
;     fpdb_readcol, ellipse, plot_line, aspect, makex, rotate_xy
;
; EXAMPLE:
;     focalplane_display,'focalplane_db.fits'
;
;     
; COMMENTS:
;     
;     This routine is intended to be consistent with the conventions
;     stated in the Planck Parameter Definition Document (v0.7.4 P.18).
;
;
; MODIFICATION HISTORY:
;     initial version, November 2006, S. Leach, SISSA.
;
;-
;======================================================================
;
pro focalplane_display, fpdbfile,$
  psfile=psfile
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

; Set default values of optional parameters.
if(undefined(psfile)) then begin
  psfile = repstr(fpdbfile,'.fits','.ps')
  psout=1
endif

fpdb_readcol,fpdbfile,'detector',detector
fpdb_readcol,fpdbfile,'phi_uv',phi_uv
fpdb_readcol,fpdbfile,'theta_uv',theta_uv
fpdb_readcol,fpdbfile,'psi_uv',psi_uv
fpdb_readcol,fpdbfile,'psi_ell',psi_ell
fpdb_readcol,fpdbfile,'psi_pol',psi_pol
fpdb_readcol,fpdbfile,'beamfwhm',beamfwhm
fpdb_readcol,fpdbfile,'ellipticity',ellipticity


DEG2RAD=2.*!DPI/360.
RAD2DEG=1./DEG2RAD

;Detector indices
HFI=indgen(52)
LFI=indgen(22)+52

theta_uv=theta_uv*DEG2RAD
phi_uv=phi_uv*DEG2RAD

x_los=sin(theta_uv)*cos(phi_uv)*RAD2DEG
y_los=-sin(theta_uv)*sin(phi_uv)*RAD2DEG

fwhm_max=beamfwhm*sqrt(ellipticity)
fwhm_min=beamfwhm/sqrt(ellipticity)

; Prepare device
if(psout) then begin 
    set_plot,'PS' & device,filename=psfile & device,/portrait
    device,/color 
endif
common colors, r,g,b, r_curr, g_curr, b_curr
loadct,0,/silent
r(0) = 0   & g(0) = 0   & b(0) = 0
r(1) = 255 & g(1) = 0   & b(1) = 0
r(2) = 0   & g(2) = 255 & b(2) = 0
r(3) = 0   & g(3) = 0   & b(3) = 255
TVLCT,r,g,b

position = ASPECT(1.)
plot,y_los,x_los,psym=3,xtitle='cross-Elevation (degrees)',ytitle='Elevation (degrees)',$
     position=position

ellipse,fwhm_max[LFI]/2,fwhm_min[LFI]/2,90-psi_ell[LFI],0,360, y_los[LFI],x_los[LFI],color=1
ellipse,fwhm_max[HFI]/2,fwhm_min[HFI]/2,90-psi_ell[HFI],0,360, y_los[HFI],x_los[HFI],color=3
plot_line,fwhm_max*0+0.4,+psi_pol+psi_uv, y_los,x_los


;Close ps device
if(psout) then begin
    device,/close
    print,'Output to ',psfile
    set_plot,'X'
endif

END

