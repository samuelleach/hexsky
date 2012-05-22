;liese naechste Datenzeile, Kommentarzeilen mit ';' oder '!' skippen
FUNCTION readnextline,lun,line
  ok=0
  while not eof(lun) and ok eq 0 do begin
      readf,lun,line
      bl= byte(strtrim(line,2))
      ok=1                      ;suche Kommentarzeilen
      if bl(0) eq 59 then ok=0  ; ;
      if bl(0) eq 33 then ok=0  ; !
      IF bl(0) eq 35 then ok=0  ; #
      if strlen(line) eq 0 then ok=0
  end
  return,ok
end
;
FUNCTION readtab, filename, cols=cols
;+
; NAME:
;
;       READTAB
;
; PURPOSE:
;
;       Read any kind of ASCII-tables into floating point array
;       Empty Lines or lines starting with ';','#' or '!' are ignored
;
; CATEGORY:
;
;       Input/Output
;
; CALLING SEQUENCE:
;
;       var= READTAB(filename, [cols])
;
; INPUTS:
;
;       Filename  -  Input Datafile
;
;
; KEYWORD PARAMETERS:
;
;       COLS - Vektor with colum numbers to pick, otherwise all
;              colums are returned
;
; OUTPUTS:
;
;       Floating point array with dimension specified by Colums and
;       Rows in the input file
;
;-

;  on_error, 2
  if n_params() eq 0 then message,'*** Aufruf var=READTAB(filename)'
  openr,lun,filename,/get_lun
  line=''

;erste Zeile lesen
  if readnextline(lun,line) eq 0 then message,'*** Keine Daten !'
  bl=byte(line)
  s= size(bl) & n= s(1) -1
; Anzahl der Spalten ermitteln
  ncol=0 & ws=0 & wsold=1
  for i=0,n do begin
      if bl(i) eq 32 or bl(i) eq 09 then ws=1 else ws=0
      if ws ne wsold then begin
          if ws eq 0 then ncol=ncol+1
          wsold=ws
      end
  end
  print,'File hat ',ncol,' Spalten'
  datline= fltarr(ncol)

; Zeilen lesen
  point_lun,lun,0
  i=0
  while not eof(lun) do begin
      if readnextline(lun,line) eq 1 then begin
          i=i +1
          reads,line,datline
          if i eq 1 then data=datline $
          else           data= [[data],[datline]]
      end
  end
  print,'      ',i,' Zeilen gelesen'
  close,lun & free_lun,lun

  if keyword_set(cols) then begin
      cols=cols-1               ;Spaltennr ab 1 !
      data=data([cols],*)
  end
  return,data
end