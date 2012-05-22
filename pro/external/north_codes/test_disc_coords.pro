PRO test_Disc_Coords;, disclon, disclat, listpix, RA, DEC, Radius, $
                 ;Full=Full, nside=nside

  nside=512
  disc_coords,disclon,disclat,listpix,120.,-45,45.,nside=nside
  disc_coords,disclon,disclat,listpix2,120.,-45,44.,nside=nside
  
  listpix=setdifference(listpix,listpix2)
  map = make_array(nside2npix(nside),value=1.)
  map(listpix)=0.

  mollview,map
  
  
  
;+
;PURPOSE
;   Find the coordinates of all the pixles in a disc with a
;   given central RA, Dec and Radius.  Returns the pixel numbers,
;   galactic longitude, latitude and total number of all pixels in the
;   disc.  Pixel numbers are based on a given Nside and Galactic
;   coordinate system.
;SYNTAX:
;   Disc_Coords, Disclon, Disclat, Listpix, [RA, DEC, Radius, NSIDE=, /FULL]
;INPUTS:
;   RA     : Right Ascension of centre of disc
;            (only required if keyword full NOT set)
;   DEC    : Declination of centre of disc
;            (only required if keyword full NOT set)
;   Radius : Radius of disc in degrees
;            (only required if keyword full NOT set)
;   Nside  : nside of map.  Default = 512
;OUTPUTS:
;   DiscLon : real vector containing the galactic longditude
;             of all the pixels in the disc/on the sky
;   DiscLat : real vector containing the galactic latitude
;             of all the pixels in the disc/on the sky
;   Listpix : integer vector containing pixel numbers
;             of all the pixels in the disc/on the sky.
;OPTIONAL KEYWORDS:
;   Full : If set, coords of pixels over full sky are calculated
;EXTERNAL PROCEDURES:
;   nside2npix
;   ang2vec
;   rotate_coord
;   query_disc
;   pix2vec_ring
;   vec2ang
;MODIFICATION HISTORY:
;   OCT 05 : Created by Chris north (cen@astro.ox.ac.uk
;TO DO:
;
;-
END
