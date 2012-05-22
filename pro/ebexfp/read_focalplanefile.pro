function read_focalplanefile,focalplanefile,phi0_deg=phi0_deg,outputdir=outputdir

  ;AUTHOR: S. Leach
  ;PURPOSE: Program to read in focalplane file (e.g. 'ebex_fpdb.txt') into a structure 
  ;         and optionally perform a rotation.

  if (n_elements(phi0_deg) eq 0) then phi0_deg = 0.
  if n_elements(outputdir) eq 0 then outputdir = './output'

  ;Read in data
  readcol,focalplanefile,index,wafer,row,col,aztmp,eltmp,channel,power,/silent

  ;Perform a rotation
  phi = phi0_deg*!dtor
  az  =  cos(phi)*aztmp + sin(phi)*eltmp
  el  = -sin(phi)*aztmp + cos(phi)*eltmp
  
  focalplane = make_array(n_elements(index),value={detector})

  focalplane.index    = index
  focalplane.wafer    = wafer 
  focalplane.row      = row
  focalplane.col      = col 
  focalplane.az       = az
  focalplane.el       = el 
  focalplane.channel  = channel 
  focalplane.power    = power
  focalplane.integration_time = 0.
  
  if phi0_deg ne 0. then begin
     spawn,'mkdir -p '+outputdir+'/fp'
     outfile = outputdir+'/fp/ebexfp_phi0'+number_formatter(phi0_deg,dec=1)+'.dat'
     print,'Writing rotated focalplane to '+outfile
     asc_write,outfile,floor(index),floor(wafer),floor(row),floor(col),az,el,floor(channel),floor(power)
  endif

  return,focalplane

end	
