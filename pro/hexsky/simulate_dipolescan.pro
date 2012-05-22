pro simulate_dipolescan,pointing_dirfile,mission,focalplane,$
                        output_dir=output_dir,$
                        first_sample=first_sample,nsample=nsample,$
                        plotrootname=plotrootname,$
			 skipdetectors=skipdetectors
; AUTHOR: S. Leach (SISSA)
; PROVENANCE:
; http://cosmology.berkeley.edu/group/cmbanalysis/forecast/idl/dipole.pro
;         by A. Balbi.
; PURPOSE: To simulate CMB dipole signal for a given timeline.

if(n_elements(output_dir) eq 0) then begin
    output_dir ='./output'
    detector_dirfile  = pointing_dirfile
endif else begin
    detector_dirfile  = output_dir+'/dirfile'
endelse

if(n_elements(first_sample) eq 0) then first_sample = 0
if(n_elements(nsample)      eq 0) then nsample      = -1
if(n_elements(plotrootname) eq 0) then plotrootname = ''
if(n_elements(skipdetectors) eq 0) then skipdetectors = 1

;--------------------------
;Read in boresight pointing
;--------------------------
ra_bs   = readfields(pointing_dirfile,'RA'  ,fframe=first_sample,nframe=nsample)
dec_bs  = readfields(pointing_dirfile,'DEC' ,fframe=first_sample,nframe=nsample)
beta_bs = readfields(pointing_dirfile,'BETA',fframe=first_sample,nframe=nsample)
ra0         = ra_bs[0]         & dec0        = dec_bs[0]
cosra_bs    = cos(ra_bs)       & sinra_bs    = sin(ra_bs)
cosdec_bs   = cos(dec_bs)      & sindec_bs   = sin(dec_bs)
costheta_bs = cos(beta_bs+!pi) & sintheta_bs =sin(beta_bs+!pi)
delvarx,ra_bs & delvarx,dec_bs & delvarx,beta_bs
nsn     = n_elements(costheta_bs)


error   = readfield(pointing_dirfile,'RJD',nsr,dtrt,rjd,$
                    fframe=first_sample,nframe=nsample)

DAYCNV, !constant.rjd0+ RJD[0], YR, MN, DAY, HR


;----------------------------
;Location of output ps files:
;----------------------------
psdir=output_dir+'/ps'
spawn,'mkdir -p '+psdir

loadct, 38
!p.background = 255
!p.color      = 0

; CMB dipole vector
ra_d     = 167.99*!dtor             ; RA (J2000) of dipole direction (radians)
dec_d    = -7.22*!dtor              ; dec (J2000) of dipole direction (radians)
T_dipole = 3.358e-3 *1e3            ; dipole intensity (mK) 
x_d      = sin(ra_d)*cos(dec_d)
y_d      = cos(ra_d)*cos(dec_d)
z_d      = sin(dec_d)
thermo2ant = conversion_factor('uK_CMB','uK_RJ',150.*1e9)

det_index = where(focalplane.power eq 1)
ndet      = n_elements(det_index)
make_ct, ndet, ct

nside_gna = 512
map_hits   = make_array( nside2npix( nside_gna),value=0.)
map_dipole = make_array( nside2npix( nside_gna),value=0.)


;Loop over detectors
last_freq_ghz=0.
for idet=0L, ndet-1L, skipdetectors do begin    
    index = det_index(idet)

    det_id   = strtrim(floor(focalplane[index].index),2)
    wafer_id = strtrim(floor(focalplane[index].wafer),2)
    row_id   = strtrim(floor(focalplane[index].row),2)
    col_id   = strtrim(floor(focalplane[index].col),2)

    det_string  = '{Wafer, row, col} = {'+wafer_id+', '+row_id+', '+col_id+'}'
    file_string = 'w'+wafer_id+'_r'+row_id+'_c'+col_id

;    print,' Simulating detector '+det_id+$
;      ' ('+strtrim(idet+1,2)+' ex ',strtrim(ndet,2)+')'  
    counter,idet+1,ndet,' Simulating detector '
   
    ;Get detector information
    xoff     = focalplane[index].az
    yoff     = focalplane[index].el
    freq_ghz = float(focalplane[index].channel)
    
;    print,'Rotating boresight pointing'
    rotboresight3,cosra_bs,cosdec_bs, sinra_bs,sindec_bs,$
                  costheta_bs,sintheta_bs,xoff,yoff,ra_rad,dec_rad,sindec_rad

    ;;Line of sight vector
;    print,'Constructing pointing line of sight vectors'
    v          = dblarr( nsn, 3)
    cosdec_rad = cos(dec_rad)
    v[*,0]     = cos(ra_rad)*cosdec_rad
    v[*,1]     = sin(ra_rad)*cosdec_rad
    v[*,2]     = sindec_rad

    ;    ;;Dipole
    dipole_signal = 0.5*thermo2ant*T_dipole*( x_d*v[*,0]+y_d*v[*,1]+z_d*v[*,2])
    
;    print,'Getting healpix coordinates at low res'
    ang2pix_ring2, nside_gna, sindec_rad, ra_rad, ipring,/costheta

;    map_dipole[ipring] = map_dipole[ipring] + dipole_signal
;    map_hits[ipring]   = map_hits[ipring] + 1.
    for pp = 0L,  n_elements(ipring)-1L do begin
        map_dipole[ipring[pp]] = map_dipole[ipring[pp]] + dipole_signal[pp]
        map_hits[ipring[pp]]   = map_hits[ipring[pp]] + 1.
    endfor


endfor

index = where(map_dipole eq 0.,complement = index2)
map_dipole(index2) = map_dipole(index2)/map_hits(index2)

deltaT = minmax(map_dipole(index2)) 
deltaT = deltaT[1]-deltaT[0]

hour  = floor(hr)
min   = floor((hr-hour)*60)
min   = int2filestring(min,2)
title = number_formatter(hour,dec=0)+':'+min+' UTC '+$
  ', '+number_formatter(day)+' '+themonths(mn)+' '+number_formatter(YR)

units    = 'mK'
subtitle = textoidl('\DeltaT = ')+number_formatter(deltaT,dec=2)+ ' mK'

psfile = psdir+'/'+plotrootname+'_dipolescan.ps'
map_dipole(index) = !healpix.bad_value
mollview, map_dipole, grat=20,window=0,/silent,$
  title='Dipole map: '+title,outline=outline_galacticplane(),coord=['C','C'],$
  units=units+'!DRJ!N 150 GHz',subtitle=subtitle,ps=psfile

psfile          = psdir+'/'+plotrootname+'_dipolescan_integrationtime.ps'
map_hits        = map_hits*mission.tsamp_sec
map_hits(index) = !healpix.bad_value
pixsize         = nside_to_pixsize(nside_gna)
units           = 's ('+number_formatter(pixsize,dec=1)+"' pixels)"
mollview, map_hits, grat=20,window=0,/silent,$
  title='Dipole map: '+title,outline=outline_galacticplane(),coord=['C','C'],$
  units=units,ps=psfile,subtitle='Integration time'



end
