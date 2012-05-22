pro flatten_postscript,psfile,epsfile=epsfile

  ;AUTHOR: S. Leach
  ;PURPOSE: "Flatten" a postrscipt image by converting to postscript
  ;          and then back to eps format
  
  pngtmpfile = fsc_base_filename(psfile)+'.png'
  epsfile    = fsc_base_filename(psfile)+'.eps'
  
  spawn,'convert -density 200 '+psfile+' '+pngtmpfile
  spawn,'convert -density 200 '+pngtmpfile+' '+epsfile

  spawn,'rm -rf '+pngtmpfile


end