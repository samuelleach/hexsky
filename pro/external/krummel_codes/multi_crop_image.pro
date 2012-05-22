pro multi_crop_image
;
; Quick wrapper procedure to crop_image
; routine to handle multiple images.
;
; PBK, CAR, 7 September 2004.
; ++++
files=dialog_pickfile(/multiple)
files=files[sort(files)]
n_files=n_elements(files)
;
for i=0L,n_files-1L do begin
;	crop_image,files[i],rot=1
	print,'cropping image number ',i,' ',files[i]
	crop_image,files[i]
endfor
;
print, 'finished cropping files!'
beep
end