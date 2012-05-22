pro outline__define,nvert=nvert

  ;AUTHOR: S. Leach
  ;PURPOSE: This is where a Healpix 'outline' struct information gets defined.

  if n_elements(nvert) eq 0 then nvert = 84

  outline = { OUTLINE,$
              coord : 'C',$
              ra  : findgen(nvert),$
              dec : findgen(nvert),$
              linestyle : -1,$
              psym: 0,$
              symsize : 1$
  }
  
end
