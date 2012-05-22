pro mprecess, a, d, equi1, equi2, exact=exact

if (equi1 eq 1950 and equi2 eq 2000) then begin
    if keyword_set(exact) then begin
        jprecess, a, d, ares, dres
        a = ares
        d = dres
    endif else begin
        precess, a, d, 1950, 2000
    endelse
endif

if (equi1 eq 2000 and equi2 eq 1950) then begin
    if keyword_set(exact) then begin
        bprecess, a, d, ares, dres
        a = ares
        d = dres
    endif else begin
        precess, a, d, 2000, 1950        
    endelse
endif

end

