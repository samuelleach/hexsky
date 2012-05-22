function get_hitmap,pointing_dirfile,focalplane,mission,$
                    output_dir=output_dir,nside_hitmap=nside_hitmap,$
                    first_sample=first_sample,nsample=nsample,$
                    pngfile=pngfile,hitmapfile=hitmapfile,window=window,$
		    get_conditionnumber=get_conditionnumber,$
		    skipdetectors=skipdetectors,$
                    intersectionmask=intersectionmask,$
                    hits_per_sample = hits_per_sample

; AUTHOR:  S. Leach (SISSA)
; PURPOSE: Simulate the hitmap for a given boresight pointing
;          and for all detectors in the focalplane struct with power=1.
   
  if(n_elements(output_dir)   eq 0)  then output_dir    ='./output'
  if(n_elements(nside_hitmap) eq 0)  then nside_hitmap  = 128
  if(n_elements(first_sample) eq 0)  then first_sample  = 0
  if(n_elements(nsample)      eq 0)  then nsample       = -1
  if(n_elements(skipdetectors) eq 0) then skipdetectors = 1
  if n_elements(get_conditionnumber) eq 0 then get_conditionnumber = 0
  if n_elements(hits_per_sample) eq 0 then hits_per_sample = 1.


  ;Location of output png files:
  pngdir = output_dir+'/png'
  spawn,'mkdir -p '+pngdir

  det_index = where(focalplane.power eq 1)
  ndet      = n_elements(det_index)
  make_ct, ndet, ct

  ;--------------------------
  ;Read in boresight pointing
  ;--------------------------
  ra_bs   = readfields(pointing_dirfile,'RA'  ,fframe=first_sample,nframe=nsample,/quiet)
  dec_bs  = readfields(pointing_dirfile,'DEC' ,fframe=first_sample,nframe=nsample,/quiet)
  beta_bs = readfields(pointing_dirfile,'BETA',fframe=first_sample,nframe=nsample,/quiet)
  
  cosra_bs    = cos(ra_bs)       & sinra_bs    = sin(ra_bs)
  cosdec_bs   = cos(dec_bs)      & sindec_bs   = sin(dec_bs)
  costheta_bs = cos(beta_bs+!pi) & sintheta_bs = sin(beta_bs+!pi)
  ra0         = ra_bs[0]         & dec0        = dec_bs[0] &
;  delvarx,ra_bs & delvarx,dec_bs 
  delvarx,dec_bs 

  nsn = n_elements(ra_bs)  
  if (get_conditionnumber) then begin
  ;; Time and omega HWP.
     rjd       = readfields(pointing_dirfile,'RJD',fframe=first_sample,nframe=nsample,/quiet)
     twoalpha  = 2d0*(2d0*2.0d0*!dpi*mission.fhwp_hz*rjd*24.d0*3600.d0 + beta_bs)
     twoalpha  = twoalpha mod (2.d0*!dpi)
     cos2alpha = cos(twoalpha)
     sin2alpha = sin(twoalpha)
     delvarx,twoalpha & delvarx, rjd
     aTa       = make_array( nside2npix( nside_hitmap),6,value=0D)
  endif else begin
     aTa       = make_array( nside2npix( nside_hitmap),value=0D)
  endelse
  delvarx,beta_bs
  
  ;-------------------
  ;Loop over detectors
  ;-------------------
  for idet = 0, ndet-1, skipdetectors do begin    
    index    = det_index(idet)
    det_id   = strtrim(floor(focalplane[index].index),2)
    wafer_id = strtrim(floor(focalplane[index].wafer),2)
    row_id   = strtrim(floor(focalplane[index].row),2)
    col_id   = strtrim(floor(focalplane[index].col),2)

    det_string  = '{Wafer, row, col} = {'+wafer_id+', '+row_id+', '+col_id+'}'
    file_string = 'w'+wafer_id+'_r'+row_id+'_c'+col_id

    counter,idet+1,ndet,'GET_HITMAP: Simulating detector '

    ;------------------------
    ;Get detector information
    ;------------------------
    xoff     = focalplane[index].az
    yoff     = focalplane[index].el
    freq_ghz = float(focalplane[index].channel)
    
    if (xoff eq 0.) and (yoff eq 0) then begin
       ra_rad     = ra_bs
       sindec_rad = sindec_bs
    endif else begin
       rotboresight3,cosra_bs,cosdec_bs, sinra_bs,sindec_bs,$
                     costheta_bs,sintheta_bs,xoff,yoff,$
                     ra_rad,dec_rad,sindec_rad
    endelse
;    beta_rad=beta_bs  ; Need to fix this

    ;--------------------
    ;Bin hits into hitmap
    ;--------------------
    ang2pix_ring2, nside_hitmap, sindec_rad, ra_rad, ipring,/costheta

     ;    hitmap = hitmap +
     ;    (histogram(ipring,MIN=0,max=n_elements(hitmap)-1L))*1d0 ;Seems slower ; may be fast for high 
      

    if (get_conditionnumber) then begin
    ; Bin up aTa elements
       for pp = 0L , n_elements(ipring)-1L do begin
          index        = ipring[pp]
          aTa[index,0] = aTa[index,0] + 1.d0                         ;aTa11
          aTa[index,1] = aTa[index,1] + cos2alpha[pp]                ;aTa12
          aTa[index,2] = aTa[index,2] + sin2alpha[pp]                ;aTa13
          aTa[index,3] = aTa[index,3] + cos2alpha[pp]*cos2alpha[pp]  ;aTa22
          aTa[index,4] = aTa[index,4] + cos2alpha[pp]*sin2alpha[pp]  ;aTa23
          aTa[index,5] = aTa[index,5] + sin2alpha[pp]*sin2alpha[pp]  ;aTa33
       endfor
    endif else begin
       for pp = 0L , n_elements(ipring)-1L do begin
          index      = ipring[pp]
          aTa[index] = aTa[index] + hits_per_sample
       endfor
    endelse

    ;--------------------------------------------------
    ; Get the 'intersection mask' between all detectors
    ;--------------------------------------------------
    if(n_elements(intersectionmask) gt 0) then begin
       intersectionmask = get_intersection_mask(intersectionmask,aTa[*,0])
    endif
    
 endfor
  
  if (get_conditionnumber) then begin
     index        = where(ata[*,0] eq 0.)
     ata[index,0] = !healpix.bad_value
  endif else begin
     index      = where(ata eq 0.)
     ata[index] = !healpix.bad_value
  endelse
  if window ne -1 then begin
     mollview, ata,1, grat=20,glsize=1.5,/silent,units='hits',$
               title='Celestial map (RA/Dec)',outline=outline_galacticplane(),$
               coord=['C','C'],window=window
  endif
  
  if(keyword_set(hitmapfile)) then begin
      write_fits_map,output_dir+'/'+hitmapfile,ata,order='RING',units='hits'
  endif



  return,aTa
  
end
