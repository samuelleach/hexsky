;+
; NAME: texprint
; PURPOSE:
;
; print out an IDL array in LaTeX table syntax, suitable for pasting
; into your paper. 
;
;
; INPUTS:
; 		table	some 2d array
; KEYWORDS:
; 		labels	string array of row labels. Goes into the first column
; 		/labelrows	use labels for rows (default is columns
; 		/longtable	use longtable instead of deluxetable
; OUTPUTS:
;
; HISTORY:
; 	Began 2006-04-14 14:51:09 by Marshall Perrin 
;-

PRO texprint, table,nozeros=nozeros,labels=labels,head=head,$
	textout=textout,longtable=longtable,caption=caption,$
	labelrows=labelrows

	if ~(keyword_set(textout)) then textout=1


	sz = size(table)
	ncol = sz[1]
	nrow = sz[2]


   textopen,'TEXPRINT',TEXTOUT=textout,SILENT=silent
   
	if keyword_set(head) then begin
		nc = ncol + (keyword_set(labels)*keyword_set(labelrows))
		align=strc(strc(strarr(nc)+"l",/join,delim=""))
		if ~(keyword_set(longtable)) then begin
			printf,!TEXTUNIT, "\begin{deluxetable}{"+align+"}"
			printf,!TEXTUNIT, "\tablecolumns{"+strc(nc)+"}"
			if keyword_set(caption) then  printf,!TEXTUNIT, "\tablecaption{"+caption+"}"
			printf,!TEXTUNIT, "\startdata"
		endif else  begin
			printf,!TEXTUNIT, "\begin{longtable}{"+align+"}"
;			printf,!TEXTUNIT, "\tablecolumns{"+strc(nc)+"}"
;			if keyword_set(caption) then  printf,!TEXTUNIT, "\tablecaption{"+caption+"}"
			printf,!TEXTUNIT, "\hline"
			printf,!TEXTUNIT, "\endhead"
			if keyword_set(caption) then  printf,!TEXTUNIT, "\caption{"+caption+"} \\"
		endelse
	
		
	endif

	; label columns
	if keyword_set(labels) and ~keyword_set(labelrows) then begin
		for ic=0L,ncol-2 do begin
			printf,!TEXTUNIT,  labels[ic],format = '($,A," & ")'
		endfor
		printf,!TEXTUNIT,labels[ic]," \\"
	endif

	for ir=0L,nrow-1 do begin
		if keyword_set(labels) and keyword_set(labelrows) then printf,!TEXTUNIT, labels[ir],format='($,A," & ")'
		for ic=0L,ncol-2 do begin
			if keyword_set(nozeros) && table[ic,ir] eq 0 then $
				printf,!TEXTUNIT,  "      ",format='($,A," & ")' else $
				printf,!TEXTUNIT,  table[ic,ir],format = '($,A," & ")'
		endfor 
		if keyword_set(nozeros) && table[ic,ir] eq 0 then printf,!TEXTUNIT,  "    \\ " else printf,!TEXTUNIT,table[ic,ir]," \\"
	endfor 
	if keyword_set(head) then begin
		if ~(keyword_set(longtable)) then begin
			printf,!TEXTUNIT, "\enddata"
			printf,!TEXTUNIT, "\end{deluxetable}"
		endif else begin
			printf,!TEXTUNIT, "\hline"
			printf,!TEXTUNIT, "\end{longtable}"
		endelse
	endif
	
	  textclose, TEXTOUT = textout          ;Close unit opened by TEXTOPEN
	  

end
