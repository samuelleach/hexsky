pro run_gs_convert_ps_to_pdf
;
; Quick procedure to interface with GS_CONVERT.PRO
; routine to enable user selected mutliple files for
; conversion from postscript to PDF. Assumes input file
; name will be used for output file name but with a '.pdf'
; extension. Also assumes input file has extension '.ps'.
;
; Paul Krummel, CSIRO Marine & Atmospheric Research, 17 October 2005.
;
; ++++
; Get the user to select the postscript files for conversion
psfiles=dialog_pickfile(/multiple,filter='*.ps')
;
; Find the directory name
dir=file_dirname(psfiles,/mark_directory)
; Construct the pdf filename
pdffiles=file_basename(psfiles,'.ps',/fold_case)+'.pdf'
pdffiles=dir+pdffiles
;
; How many files to convert?
n_files=n_elements(psfiles)
;
; Do the conversion here, loop around the files
for i=0,n_files-1 do begin
;
; Print to screen the input and output file names
	print,'Converting '+psfiles[i]+' to '+pdffiles[i]
; Call gs_convert
	gs_convert, psfiles[i], pdffiles[i], 'pdfwrite'
;
endfor
;
beep
;
end