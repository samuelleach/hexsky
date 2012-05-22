pro run_gs_convert_ps_to_png
;
; Quick procedure to interface with GS_CONVERT.PRO
; routine to enable user selected mutliple files for
; conversion from postscript to PNG image format at
; 300 DPI resolution and 16 million colours.
; Assumes input file name will be used for output
; file name but with a '_PXX.png' extension, where
; XX is the page number. Uses TextAlphaBits=4 to
; improve font rendering in final image.
; Also assumes input file has extension '.ps'.
;
; Paul Krummel, CSIRO Marine & Atmospheric Research, 13 October 2006.
;
; ++++
; Get the user to select the postscript files for conversion
psfiles=dialog_pickfile(/multiple,filter='*.ps')
;
; Find the directory name
dir=file_dirname(psfiles,/mark_directory)
; Construct the png filename
pngfiles=file_basename(psfiles,'.ps',/fold_case)+'%02d.png'
pngfiles=dir+pngfiles
;
; How many files to convert?
n_files=n_elements(psfiles)
;
; Do the conversion here, loop around the files
for i=0,n_files-1 do begin
;
; Print to screen the input and output file names
	print,'Converting '+psfiles[i]+' to '+pngfiles[i]
; Call gs_convert
	gs_convert, psfiles[i], pngfiles[i], 'png16m', res=300, TextAlphaBits=4
;
endfor
;
beep
;
end