PRO Disc_Coords, disclon, disclat, listpix, RA, DEC, Radius, $
                 Full=Full, nside=nside

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

If NOT defined(nside) Then Begin
    Print, 'Using nside=512'
    nside=512
EndIf

If keyword_set(full) Then Begin
    If n_params() NE 3 Then Begin
        Message, /inf, 'Incorrect number of parameters.'
        Message, /noname, /noprefix, $
          'SYNTAX: Disc_Coords, Disclon, Disclat, Listpix, ' + $
          '[RA, DEC, Radius, NSIDE=, /FULL]'
    Endif
    npix=nside2npix(nside)
    listpix=findgen(npix)
Endif Else Begin
    If n_params() NE 6 Then Begin
        Message, /inf, 'Incorrect number of parameters.'
        Message, /noname, /noprefix, $
          'SYNTAX: Disc_Coords, Disclon, Disclat, Listpix, ' + $
          '[RA, DEC, Radius, NSIDE=, /FULL]'
        Return
    Endif
    Ang2Vec, DEC, RA, vec_cen, /astro
    vec_cen=ROTATE_COORD(vec_cen, inco='Q', outco='G')
    QUERY_DISC, nside, vec_cen, radius, Listpix, npix, /deg, /inclusive
EndElse


Pix2Vec_Ring, nside, listpix, vec
Vec2Ang, vec, DiscLat, DiscLon, /Astro

END
