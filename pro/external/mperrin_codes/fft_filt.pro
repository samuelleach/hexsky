;+
; NAME: fft_filt.pro 
; PURPOSE:
;	High- or Low-pass filter an image in Fourier space.
;
; INPUTS:
; KEYWORDS:
; OUTPUTS:
;
; HISTORY:
; 	Began 2005-12-14 00:51:11 by Marshall Perrin 
;-

function fft_filt,image0,highpass=highpass,lowpass=lowpass, $
	cutoff=cutoff

if  ~(keyword_set(highpass)) and ~(keyword_set(lowpass)) then highpass=1
if ~(keyword_set(cutoff) ) then cutoff=10

	sz = size(image0)

	wf = where(finite(image0,/nan),nanct)
	if nanct gt 0 then image=fixnans(image0) else image=image0

	d = dist(sz[1],sz[2])

if ~(keyword_set(cutoff)) then cutoff = 4
;if keyword_set(highpass) then	dm = d gt (sz[1]+sz[2])/cutoff
;if keyword_set(lowpass) then	dm = d lt (sz[1]+sz[2])/cutoff

	ff = fft(image)
    highpassfilter = 1 - 1.0 / ( 1.0d + (dist(sz[1],sz[2])/cutoff)^2 )
    lowpassfilter =  1- highpassfilter

;imf = float(fft(ff,/inverse))
imfl = float(fft(ff*lowpassfilter,/inverse))
imfh = float(fft(ff*highpassfilter,/inverse))
	;atv,[image,imfl,imfh],/bl
	;stop


if keyword_set(highpass) then return, imfh
if keyword_set(lowpass) then return ,imfl

end
