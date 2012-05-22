function nFact,n
; Recursive factorial function written by J.Copley
if (n gt 1) then begin
   z=double(n)*nFact(double(n-1))
endif else begin
   z=1
endelse
return,z
end