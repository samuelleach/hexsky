pro ps_to_pdf, files
;
; This short procedure is a wrapper to the
; gs_convert.pro procedure which uses GhostScript
; to convert a postscript file to a pdf file.
;
; Paul Krummel, CMAR, 22 August 2005.
;
; ++++
; Check the files keyword, if not set then run dialog_pickfile
; to select the ps files to convert
if not keyword_set(files) then files=dialog_pickfile(/multiple)
;
; Loop around the number of files
n_files=n_elements(files)
for i=0,n_files-1 do begin
;
; find the path and filename, note assumes files have a .ps extension (suffix)!!
	path=file_dirname(files[i],/mark_directory)
	fname=file_basename(files[i],'.ps')
;
; Now call gs_convert
	gs_convert,files[i],path+fname+'.pdf','pdfwrite'
;
endfor
;
end