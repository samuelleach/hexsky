; -----------------------------------------------------------------------------
;
;  Copyright (C) 1997-2008  Krzysztof M. Gorski, Eric Hivon, Anthony J. Banday
;
;
;
;
;
;  This file is part of HEALPix.
;
;  HEALPix is free software; you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation; either version 2 of the License, or
;  (at your option) any later version.
;
;  HEALPix is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with HEALPix; if not, write to the Free Software
;  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;
;  For more information about HEALPix see http://healpix.jpl.nasa.gov
;
; -----------------------------------------------------------------------------
pro proj2out, planmap, Tmax, Tmin, color_bar, dx, title_display, sunits, $
              coord_out, do_rot, eul_mat, planvec, vector_scale, $
              CHARSIZE=charsize, COLT=colt, CROP=crop, GIF = gif, GRATICULE = graticule, $
              HXSIZE = hxsize, NOBAR = nobar, NOLABELS = nolabels, NOPOSITION = noposition, $
              PREVIEW = preview, $
              PS = ps, PXSIZE=pxsize, PYSIZE=pysize, ROT=rot_ang, SUBTITLE = subtitle, $
              TITLEPLOT = titleplot, XPOS = xpos, YPOS = ypos, $
              POLARIZATION=polarization, $
              PNG = png, OUTLINE = outline, $
              PROJECTION=projection, MOLLWEIDE=mollweide, GNOMIC=gnomic, CARTESIAN=cartesian, $
              ORTHOGRAPHIC=orthographic, FLIP=flip, HALF_SKY=half_sky,COORD_IN=coord_in, $
              IGRATICULE = igraticule, HBOUND = hbound, DIAMONDS = diamonds, WINDOW = window_user, $
              TRANSPARENT = transparent, EXECUTE=execute, SILENT=silent, GLSIZE=glsize, IGLSIZE=iglsize, SHADEMAP=SHADEMAP, RETAIN=retain, TRUECOLORS=truecolors

;===============================================================================
;+
;  PROJ2OUT
;  ouputs on X-screen or PS file or GIF or PNG file a gnomonic or
;  mollweide or cartesian map
;
;  IN:
;    planmap, Tmax, Tmin, color_bar, dx, title_display, sunits, 
;    coord_out, do_rot, eul_mat, planvec, vector_scale
;
;  KEYWORDS:
;     CHARSIZE=charsize, COLT=colt, CROP=crop, GIF = gif, GRATICULE = graticule, HXSIZE = hxsize, $
;              NOBAR = nobar, NOLABELS = nolabels, NOPOSITION = noposition, $
;              PREVIEW = preview, PS = ps, $
;              PXSIZE=pxsize, PYSIZE=pysize, ROT = rot_ang, SUBTITLE = subtitle, $
;              TITLEPLOT = titleplot, XPOS = xpos, YPOS = ypos, $
;              POLARIZATION=polarization,$
;              PNG=png, OUTLINE = outline,$
;              PROJECTION=projection, MOLLWEIDE=mollweide, $
;              GNOMIC=gnomic, CARTESIAN=cartesian,
;              ORTHOGRAPHIC=orthographic, $
;              FLIP=flip, HALF_SKY=half_sky,COORD_IN=coord_in, IGRATICULE=,
;              HBOUND=, DIAMONDS =, WINDOW =, TRANSPARENT=, EXECUTE=, SILENT=
;              GLSIZE=, IGLSIZE=, SHADEMAP=
;
;   for more information, see Gnomview.pro Mollview.pro
;
;   March 1999, EH
;   Nov 2000, EH, plot polarisation
;   May 2002, EH, merge gnom2out and moll2out
;   Jun 2002, EH, added the cartesian projection facility (hacked from
;       G. Giardino's pol2out)
;   Aug 2002, EH, added the orthographic projection facility
;   Jul 2002, EH, changed vector field loop index to LONG
;   Jan 2007, EH, added window keyword
;   Sep 2007, EH, the /CROP-ped image now include graticules, ...,
;   added /TRANSPARENT, EXECUTE=, /SILENT
;   May 2009, EH, added SHADEMAP (shade for orthographic PNG output)
;                 a single call to tvrd()
;                 uses Z buffer when window<0
;                 introduce RETAIN
;   Sep 2009, EH, TRANSPARENT can now be in {0,1,2,3}
;   Nov 2009, EH, retrofitting for GDL. 
;                 Everything works as in IDL except PS outputs and
;                 transparent pixels in PNG
;-
;===============================================================================

identify_projection, projtype, projection=projection, mollweide=mollweide, gnomic=gnomic, cartesian=cartesian, orthographic=orthographic,  diamonds = diamonds
do_gnom = 0
do_moll = 0
do_cart = 0
do_orth = 0
do_fullsky = 0 ; dummy, only matters for orthview
do_gif = keyword_set(gif)
do_png = keyword_set(png)
do_ps  = keyword_set(ps)
do_image = (do_gif || do_png)
do_true = keyword_set(truecolors)
do_crop = keyword_set(crop)

if undefined(polarization) then polarization=0
do_polamplitude = (polarization eq 1)
do_poldirection = (polarization eq 2)
do_polvector    = (polarization eq 3)
;-------------------------------------------------
in_gdl = is_gdl()
in_idl = ~in_gdl
if (do_ps) then test_preview
@idl_default_previewer ; defines the paper size
if (do_ps and undefined(papersize)) then papersize = 'a4'

xsize = (size(planmap))(1)
ysize = (size(planmap))(2)

if (projtype eq 2) then begin
;  ---- Gnomonic specific definitions for the plot ----
    routine    = 'GNOMVIEW'
    proj_small = 'gnomic'
    proj_big   = 'Gnomic'
    do_gnom    = 1

;     du_dv = 1.                  ; aspect ratio
    du_dv = xsize/float(ysize)                  ; aspect ratio
    fudge = 1.00                ; 
    xc = (xsize-1)/2. & delta_x = (xsize-1 - xc)
    yc = (ysize-1)/2. & delta_y = (ysize-1 - yc)
; u and v range of the map
    umin = - dx * xc * fudge & umax = dx * xc * fudge
    vmin = - dx * yc * fudge & vmax = dx * yc * fudge
; position of the rectangle in the final window
    w_xll = 0.00 & w_xur = 1.00 & w_dx = w_xur - w_xll
    w_yll = 0.10 & w_yur = 0.90 & w_dy = w_yur - w_yll
    w_dx_dy = w_dx / w_dy       ; 1.4
; color bar, position, dimension
    cbar_dx = 1./3.
    cbar_dy = 1./70.
    cbar_xll = (1. - cbar_dx)/2.
    cbar_xur = (1. + cbar_dx)/2.
    cbar_yur = w_yll - cbar_dy
    cbar_yll = cbar_yur - cbar_dy
; polarisation color ring, position, dimension
    cring_dx = 1./15.
    cring_dy = 1./15.
    cring_xll = .025
; cring_xur = .025 + cring_dx
; cring_yur = w_yll
; cring_yll = cring_yur - cring_dy
    cring_yll = .025
; location of astro. coordinate
    x_aspos = 0.5
    y_aspos = 0.04
; location of pol vector scale
    vscal_x = 0.05
    vscal_y = 0.01
; location of title and subtitle
    x_title = 0.5 & y_title = 0.95
    x_subtl = 0.5 & y_subtl = 0.915
    if (do_ps) then begin
; default X dimension of hardcopy (cm)
        hxsize_def = 15.
; offset along the long axis of the page
        yoffset = (papersize eq 'a4') ? 2 : 1
;yoffset = 2  ; Europe (A4)
;yoffset = 1                 ; US (letter)
    endif
endif

if (projtype eq 1) then begin
;  ---- Mollweide specific definitions for the plot ----
    routine    = 'MOLLVIEW'
    proj_big   = 'Mollweide'
    proj_small = 'mollweide'
    do_moll    = 1

    du_dv = 2.                  ; aspect ratio
    fudge = 1.02                ; spare some space around the Mollweide egg
    xc = 0.5*(xsize-1) & delta_x = (xsize-1 - xc)
    yc = 0.5*(ysize-1) & delta_y = (ysize-1 - yc)
; x and y range of egg
    umin = - du_dv * fudge & umax = du_dv * fudge
    vmin = - fudge         & vmax =         fudge
; position of the egg in the final window
    w_xll = 0.0 & w_xur = 1.0 & w_dx = w_xur - w_xll
    w_yll = 0.1 & w_yur = 0.9 & w_dy = w_yur - w_yll
    w_dx_dy = w_dx / w_dy       ; 1./.8
; color bar, position, dimension
    cbar_dx = 1./3.
    cbar_dy = 1./70.
    cbar_xll = (1. - cbar_dx)/2.
    cbar_xur = (1. + cbar_dx)/2.
    cbar_yur = w_yll - cbar_dy
    cbar_yll = cbar_yur - cbar_dy
; polarisation color ring, position, dimension
    cring_dx = 1./10.
    cring_dy = 1./10.
    cring_xll = .025
; cring_xur = .025 + cring_dx
; cring_yur = w_yll
; cring_yll = cring_yur - cring_dy
    cring_yll = .025
; location of pol vector scale
    vscal_x = 0.05
    vscal_y = 0.02
; location of title and subtitle
    x_title = 0.5 & y_title = 0.95
    x_subtl = 0.5 & y_subtl = 0.905
    if (do_ps) then begin
; default X dimension of hardcopy (cm)
        hxsize_def = 26.
; offset along the long axis of the page
        yoffset = (papersize eq 'a4') ? 2 : 1
    ;yoffset = 2  ; Europe (A4)
    ;yoffset = 1                 ; US (letter)
    endif
endif

if (projtype eq 5) then begin
;  ---- Diamonds specific definitions for the plot ----
    routine    = 'DIAMONDS'
    proj_big   = 'Diamonds'
    proj_small = 'diamonds'
    do_moll    = 1

    du_dv = 2.                  ; aspect ratio
    fudge = 1.00                ; spare some space around the 12-Diamonds
    xc = 0.5*(xsize-1) & delta_x = (xsize-1 - xc)
    yc = 0.5*(ysize-1) & delta_y = (ysize-1 - yc)
; x and y range of egg
    umin = - du_dv * fudge & umax = du_dv * fudge
    vmin = - fudge         & vmax =         fudge
; position of the egg in the final window
    w_xll = 0.0 & w_xur = 1.0 & w_dx = w_xur - w_xll
    w_yll = 0.1 & w_yur = 0.9 & w_dy = w_yur - w_yll
    w_dx_dy = w_dx / w_dy       ; 1./.8
; color bar, position, dimension
    cbar_dx = 1./3.
    cbar_dy = 1./70.
    cbar_xll = (1. - cbar_dx)/2.
    cbar_xur = (1. + cbar_dx)/2.
    cbar_yur = w_yll - cbar_dy
    cbar_yll = cbar_yur - cbar_dy
; polarisation color ring, position, dimension
    cring_dx = 1./10.
    cring_dy = 1./10.
    cring_xll = .025
; cring_xur = .025 + cring_dx
; cring_yur = w_yll
; cring_yll = cring_yur - cring_dy
    cring_yll = .025
; location of pol vector scale
    vscal_x = 0.05
    vscal_y = 0.02
; location of title and subtitle
    x_title = 0.5 & y_title = 0.95
    x_subtl = 0.5 & y_subtl = 0.905
    if (do_ps) then begin
; default X dimension of hardcopy (cm)
        hxsize_def = 26.
; offset along the long axis of the page
        yoffset = (papersize eq 'a4') ? 2 : 1
    ;yoffset = 2  ; Europe (A4)
    ;yoffset = 1                 ; US (letter)
    endif
endif

if (projtype eq 4) then begin
;  ---- Orthographic specific definitions for the plot ----
    routine    = 'ORTHVIEW'
    proj_big   = 'Orthographic'
    proj_small = 'orthographic'
    do_orth    = 1
    
    if keyword_set(half_sky) then do_fullsky = 0 else do_fullsky = 1
    if (do_fullsky) then du_dv = 2. else du_dv = 1. ; aspect ratio

    fudge = 1.02                ; spare some space around the Orthographic disc
    xc = 0.5*(xsize-1) & delta_x = (xsize-1 - xc)
    yc = 0.5*(ysize-1) & delta_y = (ysize-1 - yc)
; x and y range of disc
    umin = - du_dv * fudge & umax = du_dv * fudge
    vmin = - fudge         & vmax =         fudge
; position of the disc in the final window
    w_xll = 0.0 & w_xur = 1.0 & w_dx = w_xur - w_xll
    w_yll = 0.1 & w_yur = 0.9 & w_dy = w_yur - w_yll
    w_dx_dy = w_dx / w_dy       ; 1./.8
; color bar, position, dimension
    cbar_dx = 1./3.
    cbar_dy = 1./70.
    cbar_xll = (1. - cbar_dx)/2.
    cbar_xur = (1. + cbar_dx)/2.
    cbar_yur = w_yll - cbar_dy
    cbar_yll = cbar_yur - cbar_dy
; polarisation color ring, position, dimension
    cring_dx = 1./10.
    cring_dy = 1./10.
    cring_xll = .025
; cring_xur = .025 + cring_dx
; cring_yur = w_yll
; cring_yll = cring_yur - cring_dy
    cring_yll = .025
; location of pol vector scale
    vscal_x = 0.05
    vscal_y = 0.02
; location of title and subtitle
    x_title = 0.5 & y_title = 0.95
    x_subtl = 0.5 & y_subtl = 0.905
    if (do_ps) then begin
; default X dimension of hardcopy (cm)
        hxsize_def = 26.
; offset along the long axis of the page
        yoffset = (papersize eq 'a4') ? 2 : 1
    ;yoffset = 2  ; Europe (A4)
    ;yoffset = 1                 ; US (letter)
    endif
endif

if (projtype eq 3) then begin
    ;------------ cartesion projection ----------------
    routine    = 'CARTVIEW'
    proj_small = 'cartesian'
    proj_big   = 'Cartesian'
    do_cart    = 1
    
;     du_dv = 1.                  ; aspect ratio
    du_dv = xsize/float(ysize)                  ; aspect ratio
    fudge = 1.00                ; 
    xc = (xsize-1)/2. & delta_x = (xsize-1 - xc)
    yc = (ysize-1)/2. & delta_y = (ysize-1 - yc)
; u and v range of the map
    umin = - dx * xc * fudge & umax = dx * xc * fudge
    vmin = - dx * yc * fudge & vmax = dx * yc * fudge
; position of the rectangle in the final window
    w_xll = 0.00 & w_xur = 1.00 & w_dx = w_xur - w_xll
    w_yll = 0.10 & w_yur = 0.90 & w_dy = w_yur - w_yll
    w_dx_dy = w_dx / w_dy       ; 1.4
; color bar, position, dimension
    cbar_dx = 1./3.
    cbar_dy = 1./70.
    cbar_xll = (1. - cbar_dx)/2.
    cbar_xur = (1. + cbar_dx)/2.
    cbar_yur = w_yll - cbar_dy
    cbar_yll = cbar_yur - cbar_dy
; polarisation color ring, position, dimension
    cring_dx = 1./15.
    cring_dy = 1./15.
    cring_xll = .025
    cring_yll = .025
; location of astro. coordinate
    x_aspos = 0.5
    y_aspos = 0.04
; pol vector scale
    vscal_x = 0.05
    vscal_y = 0.01
; location of title and subtitle
    x_title = 0.5 & y_title = 0.95
    x_subtl = 0.5 & y_subtl = 0.915
    if (do_ps) then begin
; default X dimension of hardcopy (cm)
        hxsize_def = 15.
; offset along the long axis of the page
        yoffset = (papersize eq 'a4') ? 2 : 1
    ;yoffset = 2  ; Europe (A4)
    ;yoffset = 1                 ; US (letter)
    endif
endif
;====================================================

do_shade = (do_orth && defined(shademap))
; set color table and character size
ct          = defined(colt)     ? colt     : 33
charsfactor = defined(charsize) ? charsize : 1.0

; alter the color table
; -----------------------
if (~keyword_set(silent)) then print,'... computing the color table ...'
if (do_true) then begin
    loadct, 0, /silent
    tvlct,red,green,blue,/get
endif else begin
    if (do_poldirection) then begin
        LOADCT, 0, /SILENT
        ncol = 256
        one = replicate(1.,ncol)
        tvlct,[0,0,0,findgen(ncol-3)]/(ncol-3)*720,one,one,/hsv ; hue is in degrees
    endif else begin
        LOADCT, abs(ct), /SILENT
    endelse
    tvlct,red,green,blue,/get
    if (ct lt 0) then begin
        red = reverse(red) & green = reverse(green) & blue = reverse(blue)
    endif
endelse
; set up some specific definitions
; reserve first colors for Black, White and Neutral grey
idx_black = 0B & idx_white = 1B   & idx_grey = 2B   & idx_bwg = [idx_black, idx_white, idx_grey]
col_black = 0B & col_white = 255B & col_grey = 175B & col_bwg = [col_black, col_white, col_grey]
;col_black = 0B & col_white = 255B & col_grey = 255B & col_bwg = [col_black, col_white, col_grey]
red  [idx_bwg] = col_bwg
green[idx_bwg] = col_bwg
blue [idx_bwg] = col_bwg
TVLCT,red,green,blue

; ---------------------
; open the device
; ---------------------
old_device=!d.name
my_background = !p.background
my_color = !p.color
if (~keyword_set(silent)) then print,'... here it is.'
titlewindow = proj_big+' projection : ' + title_display
back      = REPLICATE(BYTE(!P.BACKGROUND),xsize,(ysize*cbar_dy*w_dx_dy)>1)
if (do_ps) then begin
    ; 2009-11-04: 'ps' in GDL does not support: COLOR, BITS, XSIZE, ...
    if DEFINED(hxsize) then hxsize = (hxsize > 3) < 200 else hxsize = hxsize_def
    if ((size(ps))(1) ne 7) then file_ps = 'plot_'+proj_small+'.ps' else file_ps = ps
    SET_plot,'ps'
    do_portrait = 0
    do_landscape = 0
    DEVICE, FILE=file_ps, /COLOR, BITS = 8 ; opens the file that will receive the PostScript plot
    if (do_gnom || (do_orth && ~do_fullsky)) then begin
        do_portrait = 1
        DEVICE, /PORTRAIT,  XSIZE=hxsize, YSIZE=hxsize/du_dv*w_dx_dy, XOFFSET=4, YOFFSET=2
    endif
    if (do_moll || (do_orth && do_fullsky)) then begin
        do_landscape = 1
        DEVICE, /LANDSCAPE, XSIZE=hxsize, YSIZE=hxsize/du_dv*w_dx_dy, XOFFSET=4, YOFFSET=hxsize+yoffset
    endif
    if (do_cart) then begin
        do_landscape = 1
;         DEVICE, /LANDSCAPE, XSIZE=hxsize, YSIZE=hxsize/du_dv*w_dx_dy, XOFFSET=4, YOFFSET=hxsize+yoffset
        DEVICE, /LANDSCAPE, XSIZE=hxsize, YSIZE=hxsize/du_dv*w_dx_dy, XOFFSET=0, YOFFSET=hxsize+yoffset
    endif
    TVLCT,red,green,blue
    thick_dev = 2. ; device dependent thickness factor
endif else begin ; X, png or gif output
    idl_window = defined(window_user) ? window_user : 32 ; idl_window = 32 or window_user
    free_window    =  (idl_window gt 31) ; random  window if idl_window > 31
    virtual_window =  (idl_window lt 0)  ; virtual window if idl_window < 0
    reuse_window   =  (~free_window && ~virtual_window && !d.window eq idl_window && !d.x_size eq long(xsize) && !d.y_size eq long(ysize*w_dx_dy))
    use_z_buffer   = (virtual_window && do_image)
    window_retain  = defined(retain) ? retain : 2
    if (use_z_buffer) then begin
        character_size = [!d.x_ch_size,!d.y_ch_size]
        set_plot,'z'
        device,set_resolution= [xsize, ysize*w_dx_dy], set_character_size=character_size,z_buff=1
    endif
    ;;if (!D.NAME eq 'X') then  DEVICE, PSEUDO = 8 ; for Windows compatibility ;
    ;;commented out 2009-10-28
    ;to_patch = ((!d.n_colors GT 256) && do_image  && ~do_crop)
    ;to_patch = ((!d.n_colors GT 256) && do_image && in_idl)
    to_patch = ((!d.n_colors GT 256) && do_image)
    if (in_gdl) then begin
        device ; in GDL, Decomposed keyword is either ignored (device='X') or unvalid (device='Z') 
        if (to_patch) then loadct,0,/silent ; emulate decomposed
    endif else begin
        device, decomposed = to_patch
    endelse
    if (reuse_window) then begin
        wset, idl_window
    endif else begin
        if (~use_z_buffer) then begin
            WINDOW, idl_window>0, FREE=free_window, PIXMAP=virtual_window, $
                    XSIZE = xsize, YSIZE = ysize*w_dx_dy, TITLE = titlewindow, $
                    XPOS=(in_gdl && undefined(xpos)) ? 0 : xpos
                    YPOS=(in_gdl && undefined(ypos)) ? 0 : ypos
                    RETAIN=window_retain
        endif
        if (~virtual_window && (!d.x_size lt long(xsize) || !d.y_size lt long(ysize*w_dx_dy))) then begin
            message,level=-1,/info,'==========================================================='
            message,level=-1,/info,'WARNING: Because of screen and window manager limitations,'
            message,level=-1,/info,'         the actual window is not as large as expected !'
            message,level=-1,/info,strtrim(!d.x_size,2)+'*'+  strtrim(!d.y_size,2)+'    <    '+  strtrim(long(xsize),2)+'*'+strtrim(long(ysize*w_dx_dy),2)
            message,level=-1,/info,'         The result is unpredictable.'            
            message,level=-1,/info,' If you are only interested in GIF/PNG output, you can use a virtual window (WINDOW<0) instead'            
            message,level=-1,/info,'==========================================================='
        endif
    endelse
    if (in_idl) then TVLCT,red,green,blue
    thick_dev = 1. ; device dependent thickness factor
endelse

!p.background = my_background
!p.color = my_color
; -------------------------------------------------------------
; make the plot
; -------------------------------------------------------------
myplot={urange:[umin,umax],vrange:[vmin,vmax],position:[w_xll,w_yll,w_xur,w_yur],xstyle:5,ystyle:5}
plot, /nodata, myplot.urange, myplot.vrange, pos=myplot.position, XSTYLE=myplot.xstyle, YSTYLE=myplot.ystyle
; GDL does not set the background when doing a plot in Z buffer
if (in_gdl && use_z_buffer) then tv, replicate(!p.background, xsize, ysize*w_dx_dy)
; ---------- projection independent ------------------
; map itself
if (do_shade && ~do_image) then begin
    ; shaded for X or PS
    image = planmap
    image3d  =   make_array(/uint, xsize, ysize, 3)
    image3d[*,*,0] = uint( (256. * red  [image] * shademap) < 65535.)
    image3d[*,*,1] = uint( (256. * green[image] * shademap) < 65535.)
    image3d[*,*,2] = uint( (256. * blue [image] * shademap) < 65535.)
    if (do_ps) then loadct,0,/silent ; must be in grey-scale for TrueColor PS output
    TV, bytscl(image3d),w_xll,w_yll,/normal,xsize=1.,true=3
    if (do_ps) then tvlct,red,green,blue ; revert to custom color table
    image3d = 0
endif else if (do_true  && ~do_image) then begin
                                ; truecolors for X or PS, red, green, blue are
                                ; only useful for the {0,1,2}={Black, white, grey}
    image3d = make_array(/byte, xsize, ysize, 3)
    image3d[*,*,0] = red  [planmap[*,*,0]]
    image3d[*,*,1] = green[planmap[*,*,1]]
    image3d[*,*,2] = blue [planmap[*,*,2]]
;;;    if (do_ps) then loadct,0,/silent; must be in grey-scale for TrueColor PS output
    tv, image3d, w_xll,w_yll,/normal,xsize=1.,true=3
;;;    if (do_ps) then tvlct,red,green,blue ; revert to custom color table
    image3d = 0
endif else begin
    TV, planmap,w_xll,w_yll,/normal,xsize=1.
endelse
hpxv11 = 0

; the polarisation color ring
if (do_poldirection) then begin
    npring = xsize*cring_dx
    one = replicate(1.,npring)
    yy  = one # (findgen(npring) - npring/2)
    xx  = transpose(yy)
    tt  = (xx^2 + yy^2) / float(npring)^2
    mask = byte(tt lt .25 and tt gt 0.05)
    if (hpxv11) then begin
        ; angles are measured from horizontal
        angle = atan(yy,xx)  * !radeg + 180. ; angle in deg in [0,360]
    endif else begin
        ; angles are measured from vertical
        angle = atan(xx,-yy)  * !radeg + 180. ; angle in deg in [0,360]
    endelse
    color_ring = (bytscl(angle,TOP=252) + 3B) * mask + byte((1-mask)*!P.BACKGROUND); in [3,255] in ring and !p.background outside ring
    TV,color_ring,cring_xll,cring_yll,/normal,xsize = npring/float(xsize)
endif

; polarisation vector field
if (do_polvector) then begin
    dyg = 10. & dxg = dyg
    pol_rescale = float(dyg)/ysize
    xg = (lindgen(xsize/dxg)+.5) #  replicate(dxg, ysize/dyg)
    yg = (lindgen(ysize/dyg)+.5) ## replicate(dyg, xsize/dxg)
    u = umin + xg * (umax-umin) / xsize
    v = vmin + yg * (vmax-vmin) / ysize
    for i=0L, n_elements(xg)-1 do begin
        norm = planvec[xg[i],yg[i],0] * pol_rescale * (vmax-vmin)
        angle = planvec[xg[i],yg[i],1]
        if (hpxv11) then begin
            ; angles are measured from horizontal
            if (norm gt 0) then plots, u[i]+norm*cos(angle)*[-.5,.5], v[i]+norm*sin(angle)*[-.5,.5]
        endif else begin
            ; angles are measured from vertical
            if (norm gt 0) then plots, u[i]-norm*sin(angle)*[-.5,.5], v[i]+norm*cos(angle)*[-.5,.5]
        endelse
    endfor
endif

;  the color bar
if (~(keyword_set(nobar) || do_poldirection || do_true)) then begin
    color_bar = BYTE(CONGRID(color_bar,xsize*cbar_dx)) # REPLICATE(1.,(ysize*cbar_dy*w_dx_dy)>1)
    back(xsize*cbar_xll,0) = color_bar
    TV, back,0,cbar_yll,/normal,xsize = 1.
endif

;  the color bar labels
if (~(keyword_set(nobar) || keyword_set(nolabels) || do_true || do_poldirection)) then begin
    format = '(g10.2)'
    if ((Tmax - Tmin) ge 50 and MAX(ABS([Tmax,Tmin])) le 1.e5) then format='(i8)'
    if ((Tmax - Tmin) ge 5  and MAX(ABS([Tmax,Tmin])) le 1.e2) then format='(f6.1)'
    strmin = STRING(Tmin,format=format)
    strmax = STRING(Tmax,format=format)
    XYOUTS, cbar_xll, cbar_yll,'!6'+STRTRIM(strmin,2)+' ',ALIGN=1.,/normal, chars=1.3*charsfactor
    XYOUTS, cbar_xur, cbar_yll,'!6 '+STRTRIM(strmax,2)+' '+sunits,ALIGN=0.,/normal, chars=1.3*charsfactor
endif

; the polarisation vector scale
if (~keyword_set(nobar)  && do_polvector) then begin
    plots, vscal_x*[1,1], vscal_y+[0, 5*pol_rescale]*w_dy, /normal
    format = '(g10.2)'
    if ((5*vector_scale) lt 1.e3 and (5*vector_scale) ge 10) then format = '(f5.1)'
    if ((5*vector_scale) lt 10 and (5*vector_scale) gt 1.e-1) then format = '(f4.2)'
    xyouts, vscal_x, vscal_y + .5*(5*pol_rescale)*w_dy, '!6  '+strtrim(string(5*vector_scale,form=format),2)+' '+sunits,ALIGN=0.,/normal, chars=1.1*charsfactor
endif

;  the title
if (~ keyword_set(titleplot)) then title= '!6'+title_display else title='!6'+titleplot
XYOUTS, x_title, y_title ,title, align=0.5, /normal, chars=1.6*charsfactor

;  the subtitle
if (keyword_set(subtitle)) then begin
    XYOUTS, x_subtl, y_subtl ,'!6 '+subtitle, align=0.5, /normal, chars=1.6*.75*charsfactor
endif

; ---------- projection dependent ------------------

if (do_gnom) then begin
;  astronomical position of central point
    if (not keyword_set(noposition)) then begin
        if (undefined(rot_ang)) then rot_ang = [0.,0.,0.] else rot_ang = ([rot_ang,0,0])(0:2)
        rot_0 = STRTRIM(STRING(rot_ang(0),form='(f6.1)'),2)
        rot_1 = STRTRIM(STRING(rot_ang(1),form='(f6.1)'),2)
        XYOUTS,x_aspos,y_aspos,'('+rot_0+', '+rot_1+') '+decode_coord(coord_out),/normal,align=0.5
    endif

; ; cross in the middle of plot
; plots,0,0,ps=1,syms=5,thick=4
; phi = findgen(31)/30.*2*!pi
; x_circle = cos(phi)
; y_circle = sin(phi)
; radius = tan(1.*!dtor/2.) ; radius = fwhm/2
; xyouts,0.7*umax,-0.8*vmax,'100 GHz'
; oplot,0.92*umax+radius*x_circle,-0.8*vmax+radius*y_circle,thick=3
; radius = tan(1./1.5*!dtor/2.)
; xyouts,0.7*umax,-0.9*vmax,'150 GHz'
; oplot,0.92*umax+radius*x_circle,-0.9*vmax+radius*y_circle,thick=3

endif

grattwice=0
;  the graticule in output astrophysical coordinates
if (KEYWORD_SET(graticule)) then begin
    grattwice =1
    glabelsize = charsfactor * (keyword_set(glsize) ? glsize : 0 )
    oplot_graticule, graticule, eul_mat, projection=proj_small, flip = flip, thick = 1.*thick_dev, color = !p.color, half_sky=half_sky, linestyle=0, charsize=glabelsize, reso_rad=dx
endif 

;  the graticule in input coordinates
if (KEYWORD_SET(igraticule)) then begin
    lines_ig = 2*grattwice ; either 0 or 2
    iglabelsize = charsfactor * (keyword_set(iglsize) ? iglsize : 0 )
    oplot_graticule, igraticule, eul_mat, projection=proj_small, flip = flip, thick = 1.*thick_dev, color = !p.color, half_sky=half_sky, linestyle=lines_ig, coordsys=[coord_in,coord_out], charsize=iglabelsize, reso_rad=dx
endif 

; outlines on the map
if (keyword_set(outline)) then begin
;    outline_coord2uv, outline, coord_out, eul_mat, projection=proj_small, flip = flip, /show, thick = 3.*thick_dev, half_sky=half_sky
    for ff=0,n_elements(outline)-1 do begin
        outline_coord2uv, outline[ff], coord_out, eul_mat, projection=proj_small, flip = flip, /show, thick = 3.*thick_dev, half_sky=half_sky
    endfor
endif

; overplot pixel boundaries
if keyword_set(hbound) then begin
    if (hbound gt 0) then oplot_healpix_bounds, hbound, eul_mat, projection=proj_small, flip = flip, thick = 1.*thick_dev, color = !p.color, half_sky=half_sky, linestyle=0, coordsys=[coord_in,coord_out]
endif

; overplot user defined commands
if keyword_set(execute) then begin
    junk=execute(execute)
    ; reset the plotting area for cursor to work properly
    plot, /nodata, myplot.urange, myplot.vrange, pos=myplot.position, XSTYLE=myplot.xstyle, YSTYLE=myplot.ystyle,/noerase
endif

; -----------------------------------------------
;       output the PS/GIF/PNG
; -----------------------------------------------

;  gif/png output
if do_image then begin
    valid_transparent = 0
    if (keyword_set(transparent)) then begin
        itr = nint(transparent)
        if (itr lt 0 or itr gt 3) then begin
            message,/info,'keyword TRANSPARENT must be in {0,1,2,3}'
            message,/info,'current value '+string(transparent)+' will be ignored.'
        endif else valid_transparent = 1
    endif

    if (do_gif) then begin
        if (DATATYPE(gif) ne 'STR') then file_image = 'plot_'+proj_small+'.gif' else file_image = gif
    endif else begin
        if (DATATYPE(png) ne 'STR') then file_image = 'plot_'+proj_small+'.png' else file_image = png
    endelse
;    image = (do_true) ? tvrd(true=3) : tvrd() ; a single call to tvrd()
    image = tvrd()
    if (do_shade) then begin
        image3d  =   make_array(/uint, 3,!d.x_size,!d.y_size)
        allshade =   make_array(/float,  !d.x_size,!d.y_size,value=1.0)
        allshade[w_xll*!d.x_size,w_yll*!d.y_size] = shademap
        shademap = 0
        image3d[0,*,*] = uint( (256. * red  [image] * allshade) < 65535.)
        image3d[1,*,*] = uint( (256. * green[image] * allshade) < 65535.)
        image3d[2,*,*] = uint( (256. * blue [image] * allshade) < 65535.)
        if (in_gdl) then image3d = bytscl(image3d) ; GDL's write_png won't deal correctly with 16bit integers
        allshade = 0
    endif
    if (do_true) then begin
        dim3d = valid_transparent ? 4 : 3
        image3d  =   make_array(/byte, dim3d, !d.x_size, !d.y_size)
        ix_low = long(w_xll*!d.x_size) & iy_low = long(w_yll*!d.y_size) & iy_hi = long(w_yur*!d.y_size)-1
        image3d[0,*,*] = red[image] & image3d[1,*,*] = green[image] & image3d[2,*,*] = blue[image]
        image3d[0, ix_low:*, iy_low:iy_hi] = red[  planmap[*,*,0]]
        image3d[1, ix_low:*, iy_low:iy_hi] = green[planmap[*,*,1]]
        image3d[2, ix_low:*, iy_low:iy_hi] = blue[ planmap[*,*,2]]
        if (valid_transparent) then begin
            image3d[3,*,*] = 255B
            if (itr   and 1) then begin ; turn grey  into transparent
                pix_tr = where( total(abs(image3d[0:2,*,*]-col_grey ),1) eq 0, n_tr)
                if (n_tr gt 0) then image3d[3 +4*pix_tr] = 0B
            endif
            if (itr/2 and 1) then begin ; turn white into transparent
                pix_tr = where( total(abs(image3d[0:2,*,*]-col_white),1) eq 0, n_tr)
                if (n_tr gt 0) then image3d[3 +4*pix_tr] = 0B
            endif
        endif
    endif
    ; deal with transparent colors for not TRUECOLORS, not SHADED images
    if ~(do_true || do_shade) then begin
        transp_colors = replicate(255B, 256) ; all colors are opaque
        if (valid_transparent) then begin
                                ; transparent = {1,3} -> grey pixels  are transparent
                                ; transparent = {2,3} -> white pixels are transparent
            if (itr   and 1) then transp_colors[idx_grey ] = 0B ; turn grey  into transparent
            if (itr/2 and 1) then transp_colors[idx_white] = 0B ; turn white into transparent
        endif
    endif
    if do_crop then begin
        y_crop_low = round(w_yll * n_elements(image[0,*])) & y_crop_hi  = y_crop_low + ysize - 1
        cropped = image[*,y_crop_low:y_crop_hi]
        if do_gif then write_gif,file_image,cropped,red,green,blue
        if do_png then begin
            if (do_shade || do_true) then begin
                write_png, file_image, image3d[*,*,y_crop_low:y_crop_hi]
            endif else begin
                if (keyword_set(transparent)) then begin
                    write_png,file_image,cropped,red,green,blue, transparent=transp_colors
                endif else begin
                    write_png,file_image,cropped,red,green,blue
                endelse
            endelse
        endif
    endif else begin
        if do_gif then write_gif,file_image, image,red,green,blue
        if do_png then begin
            if (do_shade || do_true) then begin
                write_png, file_image, image3d
            endif else begin
                if (keyword_set(transparent)) then begin
                    write_png,file_image, image,red,green,blue, transparent=transp_colors
                endif else begin
                    write_png,file_image, image,red,green,blue
                endelse
            endelse
        endif
    endelse
    if (to_patch && ~use_z_buffer) then begin 
        if (in_gdl) then begin
            device, decomposed=0
            tvlct,red,green,blue ; revert to custom color table
        endif else begin
            device,decomposed=0     ; put back colors on X window and redo color image
        endelse
        if (do_shade || do_true) then begin
            tv, bytscl(image3d),0,0,/normal,xsize=1.,true=1
        endif else begin
            tv, image
        endelse
    endif
    image = 0
    if (~keyword_set(silent)) then print,'IMAGE file is in '+file_image
    if (keyword_set(preview)) then begin
        test_preview, found_preview ;, /crash
        if (found_preview gt 0) then begin
            resolve_routine,'preview_file',/either ; ,compile_full_file=in_idl
            if do_gif then preview_file, file_image, /gif
            if do_png then preview_file, file_image, /png
        endif
    endif
endif


if (do_ps) then begin
    device,/close
    set_plot,old_device
    if (~keyword_set(silent)) then print,'PS file is in '+file_ps
    if (keyword_set(preview)) then begin
        test_preview, found_preview ;, /crash
        if (found_preview gt 0) then begin
            resolve_routine,'preview_file',/compile_full_file,/either
            preview_file, file_ps, /ps, landscape=do_landscape
        endif
    endif
endif else if (use_z_buffer) then begin
    device,/close ;,decomp=~to_patch
    set_plot,old_device
endif


return
end
