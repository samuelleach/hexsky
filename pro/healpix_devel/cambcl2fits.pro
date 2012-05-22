pro cambcl2fits,cambclfile

  ;AUTHOR: S. Leach
  ;PURPOSE: Convert a CAMB ascii Cl file to a healpix fits Cl
  ;         (eg for use with synfast)

  asc_read,cambclfile,ll,tt,ee,bb,te

  ncl = n_elements(tt)

  cl = make_array(ncl+1,4,value=0.)
  ll = dindgen(ncl+1) +1d0
  cl[1:ncl,0] = tt/ll/(ll+1.)*2d0*!dpi
  cl[1:ncl,1] = ee/ll/(ll+1.)*2d0*!dpi
  cl[1:ncl,2] = bb/ll/(ll+1.)*2d0*!dpi
  cl[1:ncl,3] = te/ll/(ll+1.)*2d0*!dpi

  fitsfile_out = fsc_base_filename(cambclfile)+'.fits'

  cl2fits,cl,fitsfile_out


end
