
;080701_17:12:48 before adding polarization vectors


pro plottv, z, x, y, scale = scale, xrange=xrange, yrange = yrange, zrange = zrange, $
            noaxis=noaxis, nolabels= nolabels, compress = compr_f, contours=contours, $
            zunits=zunits, _extra = extrakw, charsize=charsize, npeaks=npeaks, $
            minpeaks=minpeaks, polvec=polvec, colvec=colvec, arrow_thick=arrow_thick
;            true_xrange=true_xrange, true_yrange=true_yrange

;+
; plottv, z, x, y, scale = , xrange=, yrange = , noaxis=, _extra = extrakw,
; nolabels=, compress =, contours=, clabels=, zunits
;
; overplot a TV(SCL) output and a frame created by PLOT
;  if !p.position is defined before hand, (or position is passed as a keyword) 
;  the plot will be made where specified by this variable or keyword
;  otherwise it follows IDL default rules
;
;
; z, x, y
; z   : the 2D pixelised map to be TV(SCL)-ed
; x   : pixel coordinates on 1st dimension (1D), optional
; y   : pixel coordinates on 2nd dimension (1D), optional
;  the map should be pixelised on a uniform cartesian grid (but with different
;  scale in X and Y)
;
; scale= : if set USE TVSCL rather than TV
;
; xrange=, yrange= : 2-elements vectors indicating the X-range and Y-range to plot
;  (useful to crop the map)
;
; zrange : 2-element vectors indicating the range of the Z data to plot
;
; noaxis= : if set, no axis is plotted
;
; nolabels= : if set, axis are plotted, without ticks or labels
;
; compress= : undersampling factor applied to the map for the Postcript output
; (to make smaller file)
;
; contours = value of contour levels to overplot.
;
; zunits = units of Z field, will appear on color scale
; 
; _extra = place holder for all the keywords passed directly to PLOT (including position=, title=,
; xtitle=, ...)
;
; npeaks: number of peaks to mark and label (starting from the highest)
;  if npeaks < 0, all peaks are marked
;
; minpeaks: if present, all peaks > minpeaks are marked and labelled.
;
; version 1.0  EH, 2001-01-23
; version 1.01 EH, 2002-10-17 added some comments
; version 1.02 EH, 2002-11-11 added a Syntax message
; version 1.03 EH, 2004       added color rampe
;         1.04 EH, 2005-02    make x and y optional, added npeaks and minpeaks
;
; TODO : make it work for arbitrary input grid
;-

routine = 'PLOTTV'
syntax = routine+', z, [x, y, Scale=, Xrange=, Yrange=, Noaxis=, Nolabels=, '
synt2  = '         Compress=, Contours=, Zunits=, +all PLOT keywords]'
if n_params() eq 0 then begin
    print,syntax
    print,synt2
    message,'Abort'
endif

if undefined(compr_f) then compr = 1 else compr= compr_f
nx = n_elements(z[*,0])
ny = n_elements(z[0,*])

if defined(x) then begin
    xmin = min(x, max=xmax)
endif else begin
    xmin = 0 & xmax = nx
endelse
if defined(y) then begin
    ymin = min(y, max=ymax)
endif else begin
    ymin = 0 & ymax = ny
endelse

do_contours = (n_elements(contours) gt 0)

xprange=[xmin,xmax]
yprange=[ymin,ymax]
zz = z
if n_elements(xrange) eq 2 then begin
    xprange = xrange
    if n_elements(x) eq nx then begin
        kx = where( x ge min(xrange) and x le max(xrange), nkx)
        if (nkx gt 0) then zz = zz[kx,*]
    endif
endif
if n_elements(yrange) eq 2 then begin
    yprange = yrange
    if n_elements(y) eq ny then begin
        ky = where( y ge min(yrange) and y le max(yrange), nky)
        if (nky gt 0) then zz = zz[*,ky]
    endif
endif
nx = n_elements(zz[*,0])
ny = n_elements(zz[0,*])

; apply threshold if defined
if (n_elements(zrange) eq 2) then begin
    zz = zz > zrange[0] < zrange[1]
endif

style = 1  ; exact range
if (keyword_set(noaxis) or keyword_set(nolabels)) then style = style + 4 ; do not plot axis
; make frame and acquire position
plot,/nodata,xprange,yprange, _extra = extrakw, xstyle=style, ystyle=style, charsize=charsize, $
     xrange=xrange, yrange=yrange

position = fltarr(4)
position[[0,2]] = !x.window
position[[1,3]] = !y.window
dx = position[2] - position[0]
dy = position[3] - position[1]

if (!d.name eq 'X') then begin
    lx = nint(dx * !d.x_size)
    ly = nint(dy * !d.y_size)
endif else begin
    lx = nx/compr
    ly = ny/compr
endelse

do_scale = keyword_set(scale)
empty = replicate(' ',20)
c_linestyle = [0,2,3,4]

; color scale
x0 = position[2]+dx/7. & dxscl = dx/20.
posscl = [x0,position[1],x0+dxscl,position[3]]
zmin = min(zz,max=zmax)
plot,/nodata,[0,1],[zmin,zmax], position=posscl, xticks=1, $
     xtickn=empty, ytitle=zunits, xstyle=1, ystyle=1, charsize=charsize,/noerase   
ramp = findgen(1,256)/256. * (zmax-zmin) + zmin
ramp2 = congrid(ramp, lx * dxscl/dx, ly)
if do_scale then begin
   tvscl, ramp2, posscl[0], posscl[1], xsize = dxscl, ysize = dy,/NORMAL
   ;tvscl, ramp2, posscl[0], posscl[1]
endif else begin
    tv,    ramp2, posscl[0], posscl[1], xsize = dxscl, ysize = dy,/NORMAL
endelse
if do_contours then begin
    contour, ramp2, levels=contours,/noerase, position=posscl, xticks=1, xtickn=empty, ytickn=empty, xstyle=5, ystyle=5, c_linestyle = c_linestyle
endif
; -------------------

; put color figure at the right position
; map = congrid(zz,lx,ly)
; map = congrid(zz,lx,ly,/inter,/minus_one)
; map = congrid(zz,lx,ly,/inter)

; With congrid, there may be 1 pixel shifts due to nearest integer
;values of lx and ly (NP, Sept. 14, 2008). Use poly_2d instead (a la dispim_bar)
;map = congrid(zz,lx,ly)
if (!d.name eq 'X') then begin
    lx = dx * !d.x_size
    ly = dy * !d.y_size
endif else begin
    lx = nx/compr
    ly = ny/compr
endelse
map = poly_2d( zz, $	
               [[ 0, 0], [ nx /float(lx), 0]],  $
               [[ 0, ny /float(ly)], [ 0, 0]], $
               0,  lx, ly) 


; help,zz,lx,ly
; print,max(map),max(zz)
if do_scale then begin
   tvscl, map, position[0], position[1], xsize = dx, ysize = dy,/NORMAL
   ;tvscl, map, position[0], position[1]
endif else begin
    tv,    map, position[0], position[1], xsize = dx, ysize = dy,/NORMAL
endelse


if do_contours then begin
    contour,map,levels=contours,/noerase,xtickname=empty,ytickname=empty,xticks=1,yticks=1, xstyle=style, ystyle=style,pos=position, c_linestyle=c_linestyle
endif

; replot frame and ticks
;plot,/nodata,xprange, yprange, _extra = extrakw, $
;     xstyle=style, ystyle=style, pos= position, /noerase, charsize=charsize, $
;     xrange=xrange, yrange=yrange

; plot a frame with no ticks
p = position
if (keyword_set(nolabels) and not keyword_set(noaxis)) then begin
    plot,[p[0],p[2],p[2],p[0],p[0]],[p[1],p[1],p[3],p[3],p[1]],_extra = extrakw, xstyle=style, ystyle=style, pos= position,/normal,/noerase
endif

do_peaks = (keyword_set(npeaks) or defined(minpeaks))
npk = (defined(npeaks)) ? npeaks : -1
ng = 1
if defined(gpeak) then ng = (gpeak > 1)

if (do_peaks and npk ne 0) then begin
    ; location of local maxima: pixels with second derivative > 0
    smap = zz ; operate on raw input map
    sz = size(smap) & sx = sz[1] & sy = sz[2]
    sp0 = shift(smap, 1)     & sm0 = shift(smap,-1)
    s0p = shift(smap, 0,  1) & s0m = shift(smap, 0, -1)
    spp = shift(sp0,  0,  1) & spm = shift(sp0,  0, -1)
    smp = shift(sm0,  0,  1) & smm = shift(sm0,  0, -1)
    mask1 = (((sp0 > sm0) > (s0p > s0m)) > ((spp > spm) > (smp > smm))) ; largest of all 8 surrounding pixels
    kd = where(smap gt mask1, nd)
    sp0=0 & sm0=0 & s0p=0 & s0m=0 & spp=0 & spm=0 & smp=0 & smm=0 & mask1=0
    ; limit overcrowding by removing local maxima too close to higher peaks
;     if (nd gt 0 and ng gt 1) then begin
;         ploc = fltarr(sx,sy) & phi = ploc
;         ploc[kd] = 1 & phi[kd] = smap[kd]
;         w = replicate(1,ng,ng)
;         cp = convol(ploc, w,/center)
;     endif
    ; loop over remaining peaks, find those matching criteria and plot them
    if (nd gt 0) then begin
        peaks = smap[kd]
        srt = reverse(sort(peaks)) ; sort peaks in decreasing order
        if (npk gt 0) then srt = srt[0:(npk < nd)-1] ; keep only the Npeaks highest
        if defined(minpeaks) then begin ; are keep all those highest than minpeaks
            hipk = where(peaks[srt] ge minpeaks, nhipk)
            if nhipk gt 0 then srt = srt[hipk] else goto, peak_done
        endif
        peaks = peaks[srt] & kd = kd[srt] & nn = n_elements(srt)
        ix = (kd mod sx) & iy = long(kd / sx)
;         junk = max(smap,iimx)
;         print,nd,kd[0],ix[0],iy[0],peaks[0],iimx,iimx mod sx, long(iimx/sx),junk
        xp = xmin + ix*(xmax-xmin)/sx & yp = ymin + iy*(ymax-ymin)/sy
        plots, xp, yp, psym=5,syms=2,/data,thick=4,col=!p.background
        plots, xp, yp, psym=5,syms=2,/data,thick=2,col=!p.color
        if defined(charsize) then chsz = charsize*0.6
        for i=0,nn-1 do begin
            speak = strtrim(string(peaks[i],form='(g10.3)'),2)
            xyouts, xp[i], yp[i], ' !5'+speak,align=0, charsize = chsz,charthick=4,col=!p.background
            xyouts, xp[i], yp[i], ' !5'+speak+'!6',align=0, charsize = chsz,charthick=2,col=!p.color
        endfor
    endif
    peak_done:
endif

; replot frame and ticks
plot,/nodata,xprange, yprange, _extra = extrakw, $
     xstyle=style, ystyle=style, pos= position, /noerase, charsize=charsize, $
     xrange=xrange, yrange=yrange

if keyword_set(polvec) then begin
   res = convert_coord( polvec[1,*], polvec[2,*], /data, /to_device)
   xx1 = res[0,*] - 0.5*polvec[0,*]*sin(polvec[3,*]*!dtor)
   xx2 = res[0,*] + 0.5*polvec[0,*]*sin(polvec[3,*]*!dtor)
   yy1 = res[1,*] + 0.5*polvec[0,*]*cos(polvec[3,*]*!dtor)
   yy2 = res[1,*] - 0.5*polvec[0,*]*cos(polvec[3,*]*!dtor)
   
   arrow, xx1, yy1, xx2, yy2, hsize=0.01, col=colvec, thick=arrow_thick
Endif

return
end

