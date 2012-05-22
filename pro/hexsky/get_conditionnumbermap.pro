FUNCTION get_conditionnumbermap,ata,qu=qu

  ;AUTHOR: S. Leach
  ;PURPOSE: Return a map of the condition number, given the 
  ;         of the aTa matrix.

  w        = where( ata[*,0] eq !healpix.bad_value)
  if w[0] ne -1 then  ata[w,0] = 0.
  w = where( ata[*,0] ne 0., nw)


  if(not qu) then begin
     ;Building aTa matrices
     nstokes = 3
     map_ata = fltarr( nw, nstokes, nstokes)
     for ii = 0L, nw - 1 do begin
        ipix             = w[ii]
        map_ata[ii, 0,0] = ata[ipix,0]
        map_ata[ii, 1,0] = ata[ipix,1]
        map_ata[ii, 2,0] = ata[ipix,2]
        map_ata[ii, 0,1] = map_ata[ii, 1,0]
        map_ata[ii, 1,1] = ata[ipix,3]
        map_ata[ii, 2,1] = ata[ipix,4]
        map_ata[ii, 0,2] = map_ata[ii, 2,0]
        map_ata[ii, 1,2] = map_ata[ii, 2,1]
        map_ata[ii, 2,2] = ata[ipix,5]
     endfor
  endif else begin
     nstokes = 2
     map_ata = fltarr( nw, nstokes, nstokes)
     for ii = 0L, nw - 1 do begin
        ipix             = w[ii]
        map_ata[ii, 0,0] = ata[ipix,3]
        map_ata[ii, 1,0] = ata[ipix,4]
        map_ata[ii, 0,1] = map_ata[ii, 1,0]
        map_ata[ii, 1,1] = ata[ipix,5]
     endfor
  endelse

  message,'Evaluating condition number',/continue
  map_cond = fltarr( n_elements(ata[*,0]))
  for ii = 0L, nw-1L do begin
     ipix           = w[ii]
     ata            = reform( map_ata[ii,*,*], nstokes, nstokes)
     map_cond[ipix] = cond( ata, /double, lnorm=2)
  endfor
  
  return,map_cond


end
