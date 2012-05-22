PRO wind, nwin, ind, free=free, xsize=xsize, ysize=ysize, title=title


ind = ind < 4
if not keyword_set( xsize) then xsize = 425
if not keyword_set( ysize) then ysize = 350

spawn, 'uname -n', uname
if (uname eq 'plck-macx.ias.u-psud.fr') or $
   (uname eq 'Ordinateur-de-Nicolas-Ponthieu.local') then begin

    case ind of
        1 : begin
            xpos = 0
            ypos = 500
        end
        2 : begin
            xpos = 0
            ypos = 300
        end
        3 : begin
            xpos = xsize + 1
            ypos = 500
        end
        4 : begin
            xpos = xsize + 1
            ypos = 300
        end
    endcase

endif else begin
    x=0
    if ind eq 1 then ypos = 300 else y=418
endelse

IF keyword_set(free) THEN begin
    window, /free, xpos = xpos, ypos = ypos, xsize = xsize, ysize = ysize,title=title
endif else begin
    window,nwin,xpos=xpos,ypos=ypos,xsize=xsize, ysize=ysize,title=title
ENDELSE

END
