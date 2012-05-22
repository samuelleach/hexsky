pro simulate_planetscan,pointing_dirfile,mission,focalplane,$
                        output_dir=output_dir,planet=planet,$
                        first_sample=first_sample,nsample=nsample,$
                        plotrootname=plotrootname,$
                        skipdetectors=skipdetectors,$
                        minimap_size_arcmin=minimap_size_arcmin,$
                        load_ct=load_ct

; Initial author: N. Ponthieu (IAS).
; Development by S. Leach (SISSA)

; PURPOSE: To simulate beam maps for each detector. If planet contains
;          several planets then the planet which is nearest to the
;          initial RA and DEC of the pointing will be simulated.


if(n_elements(output_dir) eq 0) then begin
    output_dir ='./output'
    detector_dirfile  = pointing_dirfile
endif else begin
    detector_dirfile  = output_dir+'/dirfile'
endelse

if(n_elements(planet) eq 0)       then planet='SATURN'
if(n_elements(first_sample) eq 0) then first_sample = 0
if(n_elements(nsample)      eq 0) then nsample      = -1
if(n_elements(plotrootname) eq 0) then plotrootname = ''
if(n_elements(skipdetectors) eq 0) then skipdetectors = 1
if(n_elements(load_ct) eq 0) then load_ct = 1

fp                  = focalplane
fp.integration_time = 0.

;--------------------------
;Read in boresight pointing
;--------------------------
ra_bs   = readfields(pointing_dirfile,'RA'  ,fframe=first_sample,nframe=nsample,/quiet) ; Buggy in gdl0.9rc3
dec_bs  = readfields(pointing_dirfile,'DEC' ,fframe=first_sample,nframe=nsample,/quiet) ; Buggy in gdl0.9rc3
beta_bs = readfields(pointing_dirfile,'BETA',fframe=first_sample,nframe=nsample,/quiet) ; Buggy in gdl0.9rc3
ra0         = ra_bs[0]         & dec0        = dec_bs[0]
cosra_bs    = cos(ra_bs)       & sinra_bs    = sin(ra_bs)
cosdec_bs   = cos(dec_bs)      & sindec_bs   = sin(dec_bs)
costheta_bs = cos(beta_bs+!pi) & sintheta_bs =sin(beta_bs+!pi)
delvarx,ra_bs & delvarx,dec_bs & delvarx,beta_bs

;------------------------
; Read in EBEX reduced JD
;------------------------
error   = readfield(pointing_dirfile,'RJD',nsr,dtrt,rjd,fframe=first_sample,nframe=nsample) ; Buggy in gdl0.9rc3
nsn                 = n_elements(rjd)
compression_factor = 10.
nsn_compressed     = floor(nsn/compression_factor)
print,'Compressing Julian day samples by a factor '+strtrim(compression_factor,2)
rjd_compressed = congrid(rjd,nsn_compressed)


if (n_elements(planet) gt 1) then begin
;----------------------------------
;Work out what planet is the target
;----------------------------------
    target_index = 0
    mindistance  = 1000.
    planet_index = 0.
    for pp = 0, n_elements(planet) -1 do begin
        if where(strmatch(get_planetlist(),planet[pp]) eq 1) ne -1 then begin
            planet_coords, !constant.rjd0 + rjd[0], ra_target,dec_target,$
              planet=planet[pp],/jd,/jpl
        endif else begin
            target_coords,ra_target,dec_target,planet[pp]
        endelse

        gcirc,0,ra_target*!dtor,dec_target*!dtor,ra0,dec0,dis
        dis = dis/!dtor
        print,'Distance [deg] between scan and '+planet[pp]+' = ',dis
        if dis lt mindistance then begin
            planet_index = pp
            mindistance  = dis
        endif            
    endfor
    print,planet[planet_index]+' is nearest. SIMULATING ONLY THIS TARGET.'
    target = planet[planet_index]
endif

;----------------------------
;Location of output ps files:
;----------------------------
psdir=output_dir+'/ps'
spawn,'mkdir -p '+psdir

;; Get CMB sky
;file=!CMB_TEMPLATE
;print,'Reading '+file
;read_fits_map,file,map_iqu,nside=nside,/silent

;; Get dust sky at 150GHz in thermodynamic units.
;file=!DUST_TEMPLATE
;print,'Reading '+file
;read_fits_map,file,dust_iqu,nside=nside,/silent


;-----------------------
; Get planet coordinates
;-----------------------
print,'Getting '+target+' sky coordinates.'
if where(strmatch(get_planetlist(),target) eq 1) ne -1 then begin
    planet_coords, !constant.rjd0 + rjd_compressed, ra_target_deg_compressed,$
      dec_target_deg_compressed, planet=target,/jd,/jpl
endif else begin
    target_coords,ra,dec,target
    ra_target_deg_compressed  = ra  * make_array(nsn_compressed,value=1.)
    dec_target_deg_compressed = dec * make_array(nsn_compressed,value=1.)
endelse

print,'Resampling '+target+' sky coordinates.'
ra_target_deg  = congrid(ra_target_deg_compressed,nsn)
dec_target_deg = congrid(dec_target_deg_compressed,nsn)

target_ra_start_deg = ra_target_deg[0]     & target_dec_start_deg = dec_target_deg[0]
target_ra_end_deg   = ra_target_deg[nsn-1] & target_dec_end_deg = dec_target_deg[nsn-1]
;print,(target_ra_end_deg-target_ra_start_deg)*60.,(target_dec_end_deg-target_dec_start_deg)*60.
; e.g. In one hour, delta_ra_arcmin ~ 0.34332023, delta_dec_arcmin ~ 0.10375782

; Planet vector
;print,'Calculating '+planet+' line of sight vector.'
vp      = dblarr( nsn, 3)
vp[*,0] = cos(ra_target_deg*!dtor)*cos(dec_target_deg*!dtor)
vp[*,1] = sin(ra_target_deg*!dtor)*cos(dec_target_deg*!dtor)
vp[*,2] = sin(dec_target_deg*!dtor)

; CMB dipole vector
ra_d     = 167.99*!dtor             ; RA (J2000) of dipole direction (radians)
dec_d    = -7.22*!dtor              ; dec (J2000) of dipole direction (radians)
T_dipole = 3.358e-3 *1e6            ; dipole intensity (uK) 
x_d      = sin(ra_d)*cos(dec_d)
y_d      = cos(ra_d)*cos(dec_d)
z_d      = sin(dec_d)

;; Time and omega HWP.
;time  = dindgen( nsn)*mission.tsamp_sec
;omega = 2.0d0*!dpi*mission.fhwp_hz*time

; Prepare closer look at the planet and scan
fwhm_arcmin   = 8. ; Should use data from mission file
sigma         = fwhm_arcmin*!constant.fwhm2sigma*!constant.arcmin2rad

;; Beam and CMB maps
;res_deg  = 0.8/60. ;deg
;size_map = 4.00*fwhm_arcmin/60. ;deg
res_deg  = 0.4/60. ;deg

if n_elements(minimap_size_arcmin) eq 0 then begin
    size_map = 1.00*fwhm_arcmin/60.    ; deg
endif else begin
    size_map = minimap_size_arcmin/60. ; deg
endelse

ra_min   = target_ra_start_deg*!dtor  - size_map/2.*!dtor
ra_max   = target_ra_start_deg*!dtor  + size_map/2.*!dtor
dec_min  = target_dec_start_deg*!dtor - size_map/2.*!dtor
dec_max  = target_dec_start_deg*!dtor + size_map/2.*!dtor
nx       = round( size_map/float(res_deg))
ny       = round( size_map/float(res_deg))

det_index = where(focalplane.power eq 1)
ndet      = n_elements(det_index)
;;make_ct, ndet, ct

;nside_gna = 1024
;gna  = make_array( nside2npix( nside_gna),value=!healpix.bad_value)
;mapt = make_array( nside2npix( nside_gna),value=!healpix.bad_value)


;Loop over detectors
dist_to_planet = dblarr( nsn)
last_freq_ghz  = 0.
totaltime_alldetectors = 0.
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
   
;    wind, 1, 1, /free
;    plot, target_ra_start_deg+[-1, 1]*size_map_scan, target_dec_start_deg+[-1,1]*size_map_scan, $
;      /nodata, /iso, xtitle='Ra (deg)', ytitle='Dec (deg)', title=det_id
;    oplot, [target_ra_start_deg], [target_dec_start_deg], psym=1, col=230, thick=2
    
    ;Clear maps
    beam_map   = fltarr( nx, ny)
    cmb_map    = fltarr( nx, ny)
    dust_map   = fltarr( nx, ny)
    dipole_map = fltarr( nx, ny)
;    noise_map  = fltarr( nx, ny)
    total_map  = fltarr( nx, ny)
    n_hits     = fltarr( nx, ny)

    ;Get detector information
    xoff     = focalplane[index].az
    yoff     = focalplane[index].el
    freq_ghz = float(focalplane[index].channel)
    
;    print,'Rotating boresight pointing'
    rotboresight3,cosra_bs,cosdec_bs, sinra_bs,sindec_bs,$
      costheta_bs,sintheta_bs,xoff,yoff,ra_rad,dec_rad,sindec_rad
;    beta_rad=beta_bs  ; Need to fix this

    ;;Line of sight vector
;    print,'Constructing pointing line of sight vectors'
    v          = dblarr( nsn, 3)
    cosdec_rad = cos(dec_rad)
    v[*,0]     = cos(ra_rad)*cosdec_rad
    v[*,1]     = sin(ra_rad)*cosdec_rad
    v[*,2]     = sindec_rad
;    v[*,2] = sin(dec_rad)

    ;;Angular distance between observation point and planet
;    print,'Getting angular distance to '+planet
    angdist_prenorm2, v, vp, dist_to_planet
    
    ;;Planet flux (no polarization for the moment)
;    print,'Getting '+planet+' signal'
    if last_freq_ghz ne freq_ghz then begin
        planet_temp_kelvin = get_planet_temperature(!constant.rjd0+rjd,$
						    target,fwhm_arcmin,freq_ghz)
        last_freq_ghz = freq_ghz
    endif
    bolo_signal_planet = exp( -dist_to_planet^2/(2.*sigma^2))*$
      planet_temp_kelvin*1e6
;    bolo_signal_planet = exp( -dist_to_planet^2/(2.*sigma^2)) ; Removed planet_temp_kelvin*1e6 for GDL compatibility

;    print,'Performing bolometer time constant convolution'
;    bolo_signal_planet = get_bolo_signal(bolo_signal_planet,$
;                                         mission.tsamp_sec,$
;                                         mission.taubolo_sec)
    
    ;;CMB (no T prefiltering at this stage)
;    print,'Getting healpix coordinates at high res'
;    ang2pix_ring2, nside, sindec_rad, ra_rad, ipring,/costheta

;    thermo2ant = conversion_factor('uK_CMB','uK_RJ',freq_ghz)
;    bolo_signal_cmb = 0.5*thermo2ant*(map_iqu[ipring,0] + $
;                                      cos(4.0d0*omega)*map_iqu[ipring,1] + $
;                                      sin(4.0d0*omega)*map_iqu[ipring,2])
    ;;Dust
;    scaling=psm_emission_law('GREYBODY',freq_ghz,$
;                             nuref=!DUST_TEMPLATE_NUREF,temp=18.,specind=1.65)
;    bolo_signal_dust = 0.5*scaling*(dust_iqu[ipring,0] + $
;                                    cos(4.0d0*omega)*dust_iqu[ipring,1] + $
;                                    sin(4.0d0*omega)*dust_iqu[ipring,2])
    
;    ;;Dipole
;    dipole_signal = 0.5*thermo2ant* T_dipole *$
;      ( x_d*v[*,0] + y_d*v[*,1] + z_d*v[*,2])
    
    ;Noise
;    print,'Getting 1/f noise realisation'
;    noise = oof_noise(nsn, mission.tsamp_sec,mission.net_1,$
;                      mission.fknee_hz,mission.alpha)*thermo2ant
    
;    print,'Getting healpix coordinates at low res'
;;    ang2pix_ring, nside_gna, !pi/2.-dec_rad, ra_rad, ipring
;    ang2pix_ring2, nside_gna, sindec_rad, ra_rad, ipring,/costheta
;    gna[ipring] = dipole_signal + bolo_signal_cmb + bolo_signal_dust
;    mapt[ipring]= time
    
    ;;Project into map
;    print,'Projecting into map'   
    xx    = long( cosdec_rad*(ra_rad-ra_min)*!radeg/res_deg)
    yy    = long( (dec_rad-dec_min)*!radeg/res_deg)
    pixel = where ( (xx ge 0) and (xx lt nx) and (yy ge 0) and (yy lt ny))
    if pixel[0] ne -1 then begin
        for isn=0L, n_elements(pixel)-1L do begin    
            ii = pixel[isn]
            beam_map[xx[ii],yy[ii]]   = beam_map[xx[ii],yy[ii]] + bolo_signal_planet[ii]
;            beam_map[xx[ii],yy[ii]]   = beam_map[xx[ii],yy[ii]] + bolo_signal_planet[ii]*planet_temp_kelvin*1d6
;	cmb_map[xx[ii],yy[ii]]    = cmb_map[xx[ii],yy[ii]] + bolo_signal_cmb[ii]
;	dust_map[xx[ii],yy[ii]]   = dust_map[xx[ii],yy[ii]] + bolo_signal_dust[ii]
;	dipole_map[xx[ii],yy[ii]] = dipole_map[xx[ii],yy[ii]] + dipole_signal[ii]
;	noise_map[xx[ii],yy[ii]]  = noise_map[xx[ii],yy[ii]] + noise[ii]
            n_hits[xx[ii],yy[ii]]     = n_hits[xx[ii],yy[ii]] + 1.
        endfor
    endif

;    print,'Saving to IDL save file'
;    save, bolo_signal_planet, bolo_signal_cmb, bolo_signal_dust, ra_rad*!radeg,$
;        dec_rad*!radeg, time,$
;      file=output_dir+'/'+planet'_scan_'+det_id+'.save'

;    print,'Writing data to dirfile'
;    err = writefield(detector_dirfile,file_string+'_CMB',float(bolo_signal_cmb))
;    err = writefield(detector_dirfile,file_string+'_DUST',float(bolo_signal_dust))
;    err = writefield(detector_dirfile,file_string+'_'+planet,float(bolo_signal_planet))
;    err = writefield(detector_dirfile,file_string+'_DIPOLE',float(dipole_signal))
;;    err = writefield(detector_dirfile,file_string+'_NOISE',float(noise))
;    err = writefield(detector_dirfile,file_string+'_RA',ra_rad)
;    err = writefield(detector_dirfile,file_string+'_DEC',dec_rad)

    ;Make Healpix maps
;    ang2pix_ring, nside_gna, (90. -target_dec_start_deg)*!dtor,$
;	 target_ra_start_deg*!dtor, ipix
;    res     = 2 &  grat    = 5.01
;    rot     = [ target_ra_start_deg, target_dec_start_deg, 0]
;    antisunpos,!constant.rjd0+rjd[0],ra_as,dec_as
;    query_annulus,nside_gna,ra_as,dec_as,45.,pix_as
;    gna[pix_as] = max(gna) 
;    mollview, gna, /on, grat=20,window=0,/silent,$
;	      title='Celestial map (RA/Dec)'    
;    gnomview, gna, /on, rot=rot, res=res, grat=grat,window=1,/silent,$
;      title=planet+' region, JD = '+strtrim(!constant.rjd0+rjd[0],2),$
;      glsize=1.5,coord=['C','C']
;    gnomview, mapt, /on, rot=rot, res=res, grat=grat,window=3,/silent,$
;      title=planet+' region, JD = '+strtrim(!constant.rjd0+rjd[0],2),$
;      glsize=1.5,coord=['C','C'],units='hours',factor=1./3600
;;    oplot, [target_ra_start_deg], [target_dec_start_deg], psym=1, col=230, thick=2
;;    saveimage, pngdir+'/planet_scan.jpeg',/png
    
; Map from bolometer timeline.
    w = where( n_hits ne 0, compl=w1, nw)
    if nw eq 0 then begin
;        print, ' '
        print, 'All map pixels in minimap are empty'
    endif else begin
        beam_map[w] = beam_map[w]/n_hits[w]
;        cmb_map[w]  = cmb_map[w]/n_hits[w]
;        dust_map[w]  = dust_map[w]/n_hits[w]
;        dipole_map[w]  = dipole_map[w]/n_hits[w]
;        total_map[w] = cmb_map[w]+dipole_map[w]+dust_map[w];+noise_map[w]
        beam_map[w1] = 0.;!healpix.bad_value 
    endelse

    totaltime                          = total(n_hits,/double)*mission.tsamp_sec
    focalplane[index].integration_time = focalplane[index].integration_time + totaltime
    fp[index].integration_time         = totaltime
    totaltime_alldetectors             = totaltime_alldetectors + totaltime
    totaltime                          = number_formatter(totaltime,dec=1)

    if ndet le 75 then begin
        psfile = psdir+'/'+plotrootname+'_beammap_'+det_id+'.ps'
        title  = det_string+', Total time [s] = '+totaltime
        if max(beam_map) gt 0. then begin
            ps_start,filename=psfile,/quiet
            plottv, beam_map, xra=[ra_min, ra_max]*!radeg, yra=[dec_min, dec_max]*!radeg, $
              xtitle='RA (deg)', ytitle='Dec (deg)', title=title, /iso, /scale, $
              zrange=[0,max(beam_map)]
            oplot_circle, target_ra_start_deg, target_dec_start_deg,$
              fwhm_arcmin/60./2.*(findgen(3)+1.)
            oplot_circle, target_ra_end_deg, target_dec_end_deg,$
              fwhm_arcmin/60./2.
            ps_end
        endif
    endif
    
    show_other_maps = 0
    if show_other_maps then begin

;            wind, 2, 2, /free
;            plottv, noise_map, xra=[ra_min, ra_max]*!radeg, yra=[dec_min, dec_max]*!radeg, $
;              xtitle='RA (deg)', ytitle='Dec (deg)', title=title, /iso, /scale, zrange=[-4000,4000]
;            saveimage, pngdir+'/noise_map_'+det_id+'.png',/png

        wind, 2, 2, /free
        plottv, cmb_map, xra=[ra_min, ra_max]*!radeg, yra=[dec_min, dec_max]*!radeg, $
          xtitle='RA (deg)', ytitle='Dec (deg)', title=title, /iso, /scale, zrange=[-100, 100]
        saveimage, pngdir+ '/cmb_map_'+det_id+'.png',/png
        
        wind, 2, 2, /free
        plottv, dust_map, xra=[ra_min, ra_max]*!radeg, yra=[dec_min, dec_max]*!radeg, $
          xtitle='RA (deg)', ytitle='Dec (deg)', title=title, /iso, /scale, zrange=[0, 100]
        saveimage, pngdir+ '/dust_map_'+det_id+'.png',/png
        
        wind, 2, 2, /free
        plottv, dipole_map, xra=[ra_min, ra_max]*!radeg, yra=[dec_min, dec_max]*!radeg, $
          xtitle='RA (deg)', ytitle='Dec (deg)', title=title, /iso, /scale, zrange=minmax(dipole_signal)
        saveimage, pngdir+ '/dipole_map_'+det_id+'.png',/png
        
        wind, 2, 2, /free
        plottv, total_map, xra=[ra_min, ra_max]*!radeg, yra=[dec_min, dec_max]*!radeg, $
          xtitle='RA (deg)', ytitle='Dec (deg)', title=title, /iso, /scale ;, zrange=[-200,200]
        saveimage, pngdir+ '/total_map_'+det_id+'.png',/png
    endif

endfor

;if totaltime_alldetectors gt 0. then begin
   psfile = psdir+'/'+plotrootname+'_integrationtime.ps'
   view_focalplane_integrationtime,fp,psfile,load_ct=load_ct    
;endif

end
