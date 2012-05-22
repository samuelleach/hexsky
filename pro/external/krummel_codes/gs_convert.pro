;+
; NAME:
;	GS_CONVERT
;
; PURPOSE:
; Procedure to use GhostScript (GS or gswin32c command line executable) to
; convert PostScript (or PDF) files to another format eg PNG, JPEG, PDF etc.
; The output type and resolution can be selected along with a limited set
; of other gswin32c command line options. gswin32c is "spawned" from IDL to do the
; actual conversion, this routine provides an easy way to do the conversion by
; building the DOS command and executing this with the spawn process. This routine
; requires that GhostScript is installed on the users PC and is installed under
; 'C:\Program Files\gs\' or 'c:\gs\', if not can set the 'GS_PATH' keyword to
; indicate where GhostScript is installed. Only some of the command line options
; for gswin32c are implemented here, for a full list of options see the USE.html
; file in the 'doc' directory of your GS installation. To crop the reulting image
; file, please see the routine 'CROP_IMAGE.PRO' or use an image package such as
; 'IrfanView'.
;
; CATEGORY:
;	Plotting/Conversion.
;
; CALLING SEQUENCE:
;	GS_CONVERT, Infile, Outfile, Dev
;
; INPUTS:
;	The follwoing three parameters must be present:
;
;	Infile:	This should contain the path and filename of the PostScript (or PDF)
;			file to be converted. Scalar String.
;
;	Outfile: This should contain a string with path and filename for the converted output
;			file. The filename extension should be set to the appropriate name
;			to match the selected device (see Dev input parameter). For example,
;			if 'png16m' is the selected device, then make sure the output filename
;			extension is '.png'. Note, if your postscript file contains multiple
;			pages and you want to convert them all to images, use a '%d' in the
;			output filename, which upon conversion, will contain the page number.
;			eg if your ps file contains 3 pages and the supplied output file name
;			is 'Out_%d.png', then the result will be 3 PNG files named Out_1.png,
;			Out_2.png and Out_3.png. Other options with this are to use '%02d'
;			instead of '%d' (note could use 03 or 04 etc, depending on how many digits
;			you require in the output filename), which for the above example would
;			results in the output files being named Out_01.png, Out_02.png and Out_03.png.
;
;	Dev:	Set this parameter to a string contaning the type of device
;			(output format) that you wish to convert the PostScript or
;			PDf file to.
;			Below are some of the common formats (see the Devices.htm file in 
;			the gs Docs directory for a full listing of supported output):
;				png16m	- Portable Network Graphics (PNG), 16 million colours.
;				png256	- Portable Network Graphics (PNG), 256 colours.
;				pnggray - Portable Network Graphics (PNG), gray scale.
;				jpeg 	- Joint Photographers Expert Group (JPEG), 16 million colours.
;				jpeggray 	- Joint Photographers Expert Group (JPEG), 16 million colours.
;				pdfwrite 	- Portable Document Format (PDF), vector format.
;
; KEYWORD PARAMETERS:
;	RES:	Set this keyword to the output resolution (in Dots Per Inch, DPI) you
;			require for the output image. If this is not set then a default of
;			300DPI is used. Note that this value is ignored if the output device
;			is pdfwrite.
;
;	PAPER:	Set this keyword to the paper size contained in your postscript file.
;			If this keyword is not set then 'A4' is used as the default.
;
;	GS_PATH: Set this keyword to the path where GhostScript is installed. This is
;			only required if the path is not 'c:\gs\' or 'c:\program files\gs\'.
;
;	TEXTALPHABITS and GRAPHICSALPHABITS: Set these keywords to control the use of
;			subsample antialiasing. Their use is highly recommended for producing
;			high quality rasterizations. The subsampling box size n should be 4
;			for optimum output, but smaller values can be used for faster rendering.
;			Antialiasing is enabled separately for text (TEXTALPHABITS) and graphics
;			(GRAPHICSALPHABITS) content. Allowed values are 1, 2 or 4. The default
;			value used here is 1 for both text and graphics. NOTE that if you select
;			4 for both text and graphics then your resulting image file will be larger!
;			Typically, I tend to use 4 for text and 1 for graphics for most of my 
;			images for use in presentations etc.
;
;
; OUTPUTS:
;	This procedure converts a PostScript (or PDF) file to the selected image format
;	or to a PDF file.
;
; RESTRICTIONS:
;	Requires GhostScript to be installed on the users PC.
;
; EXAMPLE:
;	To convert the one page postscript file 'CGA_CH4_data.ps' to a PNG image
;	of resolution 600DPI in the file 'test.png':
;	IDL> GS_CONVERT, 'c:\temp\CGA_CH4_data.ps','c:\temp\test.png','png16m',res=600
;
;	To convert the 70 page postscript file 'cga_all_agage.ps' to a PNG image
;	of resolution 150DPI in the files 'all_test_0XX.png':
;	IDL> GS_CONVERT, 'c:\temp\cga_all_agage.ps','c:\temp\test_%03d.png','png16m',res=150
;
;	To convert the 5 page postscript file 'windrose.ps' to a PDF file 'windrose.pdf':
;	IDL> GS_CONVERT, 'c:\temp\windrose.ps','c:\temp\windrose.pdf','pdfwrite'
;
;	To convert the one page postscript file 'half_page_fig.ps' to a PNG image
;	of resolution 300DPI and then crop it leaving default 2% white space around it:
;	IDL> GS_CONVERT, 'c:\temp\half_page_fig.ps','c:\temp\temp.png','png16m',res=300
;	IDL> CROP_IMAGE, 'c:\temp\temp.png', OUT_FILE='c:\temp\cropped_fig.png'
;
; MODIFICATION HISTORY:
; 	Written by:	Paul Krummel, CSIRO Marine and Atmospheric Research, 10 August 2005.
;	Modified by: Paul Krummel, CMAR, 15 August 2005. Added basic error checking and
;		messages for the case if the gswin32c executable is not found.
;
; THISNG to DO:
; Add options for EPS files and the EPSCrop option of gs (I think this also works with 
;  standard PS output from IDL, which I tested many moons ago). 
; eg from IDL newsgroup: 
;  gs -sDEVICE=png16m -sOutputFile=foo.png -dNOPAUSE -dBATCH -dEPSCrop -r300x300 foo.eps 
;
;-
;
PRO GS_CONVERT, INFILE, OUTFILE, DEV, RES=RES, PAPER=PAPER, GS_PATH=GS_PATH, $
		TEXTALPHABITS=TEXTALPHABITS, GRAPHICSALPHABITS=GRAPHICALPHABITS
;
; ++++
; Check to make sure that have three parameters passed in, if not then stop.
;on_error,2
if N_PARAMS(0) NE 3 then begin
	message,'Naughty Naughty -> Unable to convert due to incorrect number of parameters, '+ $
			'must set Infile, Outfile and Dev. Please try again. Exiting.',/informational
	return
endif
;
; ++++
; Set some defaults
if not keyword_set(res) then res=300
if not keyword_set(paper) then paper='a4'
if not keyword_set(textalphabits) then textalphabits=1
if not keyword_set(graphicsalphabits) then graphicsalphabits=1
;
; Turn these into strings and remove spaces
res=strcompress(res,/remove_all)
textalphabits=strcompress(textalphabits,/remove_all)
graphicsalphabits=strcompress(graphicsalphabits,/remove_all)
;
; Is the GS_PATH keyword set? If not set it to the default.
if not keyword_set(gs_path) then gs_path=['c:\program files\gs\','c:\gs\']
;
; ++++
; Find the ghostscript command line executable -> assumes that it is
; installed under 'c:\program files\gs\' or 'c:gs\'. If not found then return
; to the calling routine.
gs_exe=file_search(gs_path,'gswin32c.exe',/fold_case,count=n_gs_exe)
if n_gs_exe eq 0 then begin
	message,'What the ... GSWIN32C.EXE not found on your computer ('+getenv('COMPUTERNAME')+'), '+ $
			'returning without converting your file:'+infile+' !!',/informational
	return
endif
;
; Piece the dos command together ready for spawn, also if more than one version
; installed, then just use the last one in the list!
dos_com='"'+gs_exe[n_gs_exe-1]+'" -sDEVICE='+dev+' -r'+res+' -q -dNOPAUSE -dBATCH'+ $
		' -dTextAlphaBits='+textalphabits+' -dGraphicsAlphaBits='+graphicsalphabits+ $
		' -sPAPERSIZE='+paper+' -sOutputFile="'+outfile+'" "'+infile+'"'
;
; Spawn the process, note need the extra quotes here to handle
; spaces in directory names.
spawn,'"'+dos_com+'"',/log_output
;
; ++++
; Finished
end