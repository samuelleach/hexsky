FUNCTION map2patch,map,patchsize_deg,map_centre_deg,$
                   pol_map=pol_map,pixsize_deg=pixsize_deg,gnomview=gnomview

  ;AUTHOR: S. Leach
  ;PURPOSE: Perform a flat patch projection of a nested Healpix map.

  if n_elements(pol_map) eq 0 then pol_map = 0
  if n_elements(gnomview) eq 0 then gnomview = 0

  npix        = n_elements(map[*,0])
  nside       = npix2nside(npix)

  if n_elements(pixsize_deg) eq 0 then begin
     reso_arcmin = nside_to_pixsize(nside)
     pxsize      = floor(patchsize_deg/(reso_arcmin/60.))
  endif else begin
     reso_arcmin = pixsize_deg*60.
     pxsize      = floor(patchsize_deg/pixsize_deg)
  endelse
  pysize      = pxsize
  
  gnomview,map,1,plot=gnomview,map_out=map_out,/nest,reso_arcmin=reso_arcmin,pxsize=pxsize,pysize=pysize,/silent,$
           rot=map_centre_deg,truecolors=0

  if pol_map then begin
     flatpatch        = make_array(pxsize,pysize,3)
     flatpatch[*,*,0] = map_out
     gnomview,map,2,plot=gnomview,map_out=map_out,/nest,reso_arcmin=reso_arcmin,pxsize=pxsize,pysize=pysize,/silent,$
              rot=map_centre_deg,truecolors=0
     flatpatch[*,*,1] = map_out
     gnomview,map,3,plot=gnomview,map_out=map_out,/nest,reso_arcmin=reso_arcmin,pxsize=pxsize,pysize=pysize,/silent,$
              rot=map_centre_deg,truecolors=0
     flatpatch[*,*,2] = map_out    
  endif else begin
     flatpatch = map_out
  endelse

  return,flatpatch


end
