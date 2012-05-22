;+
; NAME:
;	CROP_IMAGE
;
; PURPOSE:
;	This procedure performs an autocrop on an image in
;	IDL based on white space or white background. It
;	will work with 8-bit (256 colours) or 24-bit (true
;	colour) images. It can also rotate images if required.
;
; CATEGORY:
;	Image manipulation
;
; CALLING SEQUENCE:
;	CROP_IMAGE, Image_File, OUT_FILE=Out_File, COORDS=CoOrds, PERC=Perc, ROT=Rot
;
; INPUTS:
;	Image_File:	This is the path and filename of the image
;			file to crop. Must be a string.
;
; KEYWORD PARAMETERS:
;	OUT_FILE:	Set this keyword to the desired output filename. If
;			this keyword is not set then the default is to overwrite
;			the input image file (Image_File above) with the cropped
;			image. Currently the output image will be in the same
;			format as the input image. Must be a string.
;
;	COORDS:		Set this keyword to a four element array containing
;			the min and max pixel locations where you want the image
;			to be cropped eg. [x_min,y_min,x_max,y_max]. If this
;			keyword is not set, the default is to auto-crop the image to
;			allow a 'PERC' % buffer of the total image pixel size on all
;			sides of the image from the first non white pixels.
;			NOTE: In some image formats the first pixel row starts at
;			the top of the image while in others it is at the bottom
;			of the image.
;
;	PERC:	Set this keyword to the percentage buffer to be used around
;			the image for the auto-cropping if the CoOrds keyword is
;			not set. If PERC is not set, then a default of 2% is used.
;			The percentage value is implemented by leaving a 'PERC' %
;			buffer (of the total image pixel size) of white pixels on
;			all sides of of the image from the first non white pixels.
;
;	ROT:		Set this keyword to the rotation (direction) that
;			is required based on the following table:
;		Direction  Transpose?  Rotation Counterclockwise  X1  Y1
;			0           No        None          X0 Y0
;			1           No         90�                    -Y0  X0
;			2           No        180�                    -X0  -Y0
;			3           No        270�                    Y0  -X0
;			4           Yes       None          Y0  X0
;			5           Yes        90�                    -X0  Y0
;			6           Yes       180�                    -Y0  -X0
;			7           Yes       270�                    X0  -Y0
;
;
; OUTPUTS:
;	Writes an image to file, see OUT_FILE above.
;
; RESTRICTIONS:
;	Only works for 8- or 24-bit images. Requires IDL 5.4 or higher.
;
; PROCEDURE:
;	Straightforward image reading and cropping (sub array extraction)
;	based on COORDS OR simple checking for first non-white pixel
;	locations (if COORDS keyword not set) and taking 2% buffers
;	around these.
;
; EXAMPLE:
;	Read in the image CapeGrim_Map.png, auto crop it and write out
;	to same file name:
;		IDL> crop_image,'c:\krum\gaslab\map\CapeGrim_Map.png'
;	OR also rotate it 90 degress counter clockwise
;		IDL> crop_image,'c:\krum\gaslab\map\CapeGrim_Map.png', rot=1
;	OR rotate it 90 degress counter clockwise and allow a 5% buffer around the image
;		IDL> crop_image,'c:\krum\gaslab\map\CapeGrim_Map.png', rot=1, perc=5
;	Convert a postscript file to PNG and then crop it:
;		IDL> GS_CONVERT, 'c:\temp\half_page_fig.ps','c:\temp\temp.png','png16m',res=300
;		IDL> CROP_IMAGE, 'c:\temp\temp.png', OUT_FILE='c:\temp\cropped_fig.png'
;
; MODIFICATION HISTORY:
; 	Written by:	Paul Krummel, CSIRO Atmospheric Research, 28 Febuary 2001.
; 	Modified by Paul Krummel, CAR, 25 April 2001. Added COORDS keyword.
;	Modified by Paul Krummel, CAR, 23 August 2001. Added ROT keyword.
;	Modified by Paul Krummel, CAR, 17 January 2002. Added file checking
;		to see if input image file variable (im_file) is of type string
;		and if input image file exists or not.
;	Modified by Paul Krummel, CAR, 31 January 2002. Fixed oversight (bug)
;		with rotating the image when it is 24 bit!! ROT now works for
;		24-bit images.
;	Modified by Paul Krummel, CAR, 6 June 2002. Made code more efficient
;		when rotating large true colour images by using zero-based array
;		indexing.
;	Modified by Paul Krummel, CMAR, 12 August 2005. Added the 'PERC' keyword
;		to allow setting of the percentage amount of buffer to leave around
;		the image if the 'CoOrds' keyword is not set. Previously the perc
;		value for the auto cropping was set to 2%.
;-

PRO CROP_IMAGE, Im_File, OUT_FILE=Out_File, COORDS=CoOrds, PERC=Perc, ROT=Rot
;
; =====>> HELP
;
on_error,2
if (N_PARAMS(0) NE 1) or keyword_set(help) then begin
   doc_library,'CROP_IMAGE'
   if N_PARAMS(0) NE 1 and not keyword_set(help) then $
               message,'Incorrect number of parameters, see above for usage.'
   return
endif
;
; ++++
; THINGS STILL TO DO:
; Add options for different output image format
; Allow passing in an image array and passing image back again i.e.
;	no reading/writing from file on disk.
;
; ++++
;
; Make sure input image file variable is a string
if size(im_file,/type) ne 7 then message,'"image_file" must be a string!!'
;
; Check that the image files exists and is readable!
if not file_test(im_file,/read) then message,'Bugger ... '+im_file+ $
					' does not exist or is not readable!!'
;
; Read in the image
ok=query_image(im_file,info)
if not ok then message,'Oh BUGGER ... '+im_file+ $
			' is not a proper or supported image file!'
image = READ_image(im_File, R, G, B)
;
; ++++
; Check to see if coords were passed in, if so use them!
if n_elements(coords) gt 0 then begin
	c_min=coords[0] & c_max=coords[2]
	r_min=coords[1] & r_max=coords[3]
;
; ++++
; If not then autocrop
ENDIF ELSE BEGIN
;
; ++++
; Check if it is an 8 bit or 24 bit image
	case info.channels of
		1: BEGIN	; 8-bit
;
;			find the min colour used in the image
			i_min=min(image)
;
;	 		Check for white (r,g,b=255), just a test!
;			White is usually ALWAYS at 255 which usually is
; 			r=255, g=255, b=255, but just check to make sure!
			rgb=fix(r)+fix(g)+fix(b)
			wh=where(rgb[i_min:255] eq 765)+i_min
;			white can occur more than once!
;			Is usually 255 though, just use the max
			wh=max(wh)
;			Find where image is not white
			not_white=where(image ne wh, cnt_nw)
;
				END
;
		3: BEGIN	; 24-bit
;
;			24 bit image -> 16.7 million colours
			rgb=total(image,1)
;			White is 765
			wh=765
;			Find where image is not white
			not_white=where(rgb ne wh, cnt_nw)
;
				END
	endcase
;
; 	Convert this to columns and rows
	ncol = info.dimensions[0]
	nrow = info.dimensions[1]
	col = not_white MOD ncol
	row = not_white / ncol
;
;	 Find the min and max of the col and row
	c_min=min(col,max=c_max)
	r_min=min(row,max=r_max)
;
;	If the percentage keyword is not set then set to default 2%
	if n_elements(perc) eq 0 then perc=2
	perc=float(perc)/100.
;
;	 Find average of col and row sizes and take 2% of it
	buff=ceil((((c_max-c_min)+(r_max-r_min))/2)*perc)
;
; 	Now add this to make buffer around image and find new dimensions
	c_min= c_min-buff > 0
	c_max= c_max+buff < ncol-1
	r_min= r_min-buff > 0
	r_max= r_max+buff < nrow-1
;
; ++++
ENDELSE
;
; ++++
; resize the image, with 'buff' pixels added on all sides
case info.channels of
	1: image=image[c_min:c_max,r_min:r_max] ; 8 bit
	3: image=image[*,c_min:c_max,r_min:r_max] ; 24 bit
endcase
;
; ++++
; if requested, rotate the image
if n_elements(rot) gt 0 then begin
	case info.channels of
		1: image=rotate(image,rot) ; 8 bit image
		3: begin   ; 24 bit image
;			Rotate the individual channels of the image by requested amount
			ir=rotate(reform(image[0,*,*]),rot) ; 24 bit red
			ig=rotate(reform(image[1,*,*]),rot) ; 24 bit green
			ib=rotate(reform(image[2,*,*]),rot) ; 24 bit blue
;           Reassign the individual channels to 3D and delete the variable
			sz=size(ir,/dimension)
;			image=bytarr(3,sz[0],sz[1])
;			image[0,*,*]=temporary(ir)
;			image[1,*,*]=temporary(ig)
;			image[2,*,*]=temporary(ib)
;			The code below is more efficient for large true colour images
;			than the above code ie using zero-based array indexing,
;			but this requires transposing the array, which is still quick!
			image=bytarr(sz[0],sz[1],3)
			image[0,0,0]=temporary(ir)
			image[0,0,1]=temporary(ig)
			image[0,0,2]=temporary(ib)
			image = TRANSPOSE(image, [2, 0, 1])
				end
	endcase
endif
;
; ++++
; Write out the image
if keyword_set(out_file) then o_file=out_file $
else o_file=im_file
WRITE_image, o_file, info.type, Image, R, G, B
;
; ++++
end