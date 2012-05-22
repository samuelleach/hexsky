function compute_range, image, nsigma=nsigma, percent=percent, indef=indef, order=order

;+
; NAME:
;    COMPUTE_RANGE
;
; PURPOSE:
;    Compute the appropriate dynamical range for the display of an
;    image. If no optional inputs are given, this function returns the
;    minimum and maximum value of IMAGE. Otherwise it returns:
;    [median(image) - nsigma*stdev(image) , 
;       median(image) + nsigma*stdev(image)].
;    The standard deviation of the image is computed by discarding
;    the PERCENT higher and lower values.
;
;    This function takes care of undefined values (INDEF optional input).
;
; CALLING SEQUENCE:
;     range = compute_range(image, nsigma=nsigma, percent=percent, indef=indef)
;
; INPUTS:
;     image : the array on which the computation is done (can be of
;                any size and dimension)
;
; OPTIONAL INPUTS:
;     nsigma : float 
;     percent : float
;     indef : float (default value is -32768.)
;
; OUTPUTS:
;     result (fltarr(2)) : the dynamical range of the input image.
;
; EXAMPLE:
;     imrange = compute_range(map, nsigma=2, percent=5.)
;
; MODIFICATION HISTORY:
;     01/04/2002 ; MAMD creation
;     17/10/2003; MAMD optimisation
;-

;to = systime(1)

if not keyword_set(indef) then indef=-32768.

range_out = [0., 0.]
ind_defined = where(image ne indef, nbindef)
if nbindef eq 0 then return, range_out

if keyword_set(percent) then begin
    if not keyword_set(order) then order = sort(image(ind_defined))
    nlimit = percent / 100. *nbindef
    order_use = order(nlimit:(nbindef-nlimit))
endif else order_use = lindgen(nbindef)

if keyword_set(nsigma) then begin
;    tempo = moment(image(ind_defined(order_use)))
;    xsigma = sqrt(tempo(1))
    xsigma = stdev(image(ind_defined(order_use)))
    med = median(image(ind_defined(order_use)))
    range_out = [med-nsigma*xsigma, med+nsigma*xsigma]
endif else begin
    range_out = minmax(image(ind_defined(order_use)))
endelse

range_out(0) = range_out(0)>min(image(ind_defined))
range_out(1) = range_out(1)<max(image(ind_defined))

;print, systime(1)-to

return, range_out

end
