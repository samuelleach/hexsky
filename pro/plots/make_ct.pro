
pro make_ct, n, ct
if n_params() lt 1 then begin
    message, /info, "call is: "
    print, "make_ct, n, ct"
    return
endif

if n le 1 then ct=230 else ct = findgen(n)/(n-1) * (250 - 50) + 50.

end
