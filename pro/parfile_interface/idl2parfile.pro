pro idl2parfile, PARFILE,PARAMETERS
                
;+
; NAME:
;	IDL2PARFILE
;
; PURPOSE:
;       Allows to make a name=value parameter file from within IDL.
;
; CALLING SEQUENCE:
; 	IDL2PARFILE, PARFILE, PARAMETERS
;                        
;
; INPUTS:
;      PARFILE     STRING           Name of parameter file.
;      PARAMETERS  STRING ARRAY     Array of [['name', 'value']] settings for module.
;
; OPTIONAL INPUTS:
;
; OPTIONAL INPUT KEYWORDS:
;
; NOTES
;
; SIDE EFFECTS
;
; EXAMPLES
; idl2parfile,'anafast_test.par',[['infile', 'map.fits'],['outfile','cl.fits'],['nlmax', '1535']]
;
; COMMONS USED : 
;
; PROCEDURES USED: 
;
; MODIFICATION HISTORY:
; 	October 2006, Samuel Leach, SISSA
;-

nflags=n_elements(parameters)/2

spawn,'echo '+strtrim(parameters[0,0],2)+' = '+strtrim(parameters[1,0],2)+' >'+parfile
FOR n=1,nflags-1 DO BEGIN
    spawn,'echo '+strtrim(parameters[0,n],2)+' = '+strtrim(parameters[1,n],2)+' >>'+parfile
ENDFOR


END
