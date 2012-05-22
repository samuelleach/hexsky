;-------------------------------------------------------------------
;NAME:
;   EBEX PLOT
;
;PURPOSE:
;   Make a nice plot in IDL
;
;INPUT:
;   MAP - a n x n image
;   N = number of pixels on each side of the image
;   RA/DEC = position of the central pixel, in degrees

;OUTPUT:
;   A pretty map and scale!
;
;KEYWORDS:
;  RESO - the resolution of your map. defaults to 0.17578
;         arcminutes/pixel if not set
;  TITLE - Create a title
;
;ROUTINES USED:
;  TEMP - finds the max and min of an image where several points are
;           assigned NAN, thus defeating IDL's procedures of max and
;           min.
; COLORBAR - adds a colorbar to the map.
;
;-------------------------------------------------------------------


PRO ebex_plot, map, n_pix, RA, DEC,reso, title = title

n_i = n_elements(map[*,0])
n_j = n_elements(map[0,*])

;x_zero = 83.-3584*0.17578/60.
;y_zero = -51.5 - 3584*0.17578/60.

x_zero = RA-n_pix/2.*reso/60.
y_zero = DEC-n_pix/2.*reso/60.


maxmin = temp(map)

range = [float(maxmin.min),float(maxmin.max)]


plot_map, map, ct =13 , title = title, xtitle = 'RA [deg]', ytitle = 'DEC [deg]', dx =reso/60., dy = reso/60, x0 = x_zero, y0 = y_zero

loadct, 13

colorbar, ncolors = 255, position =[0.1,0.07,0.9,0.1], range = range, title = 'Temperature [microKelvin]'

END
