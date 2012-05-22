;----------------------------------------------------------------------
;NAME:
;   PLOT_POLARISATION
;
;PURPOSE:
;  Makes a plot of A_x and A_y polarisation assuming a rotating half
;  wave plate and fixed polarisation grid used in the same manner as
;  that which was used in make_synfast_timestream
;
;INPUTS:
;  TIMESTREAM - an anonymous structure with all the following fields:
;     *POLARISATION_STREAM - a n_bolo by N array representing the value sampled
;       a each instant for each bolometer, in delta T micro Kelvin.     
;     *N_BOLO - the number of bolometers in your array.  This uniquely
;       identifies which scope was used to form the timestream.
;     *RESO_ARCMIN - the resolution, in arcminutes, of the image this
;       timestream was made from.  Arcminutes on side of one pixel.
;     *DATA_RATE - the rate at which data was collected to form this
;       timestream, in Hz.
;  SCOPE - an anonymous structure which has all of the following:
;     *BOLO_ARRAY  - a 2 by N array giving the offsets of each of
;       the bolometers from the central pointing of the scope,
;       in arcminutes.
;     *FWHM_ARCMIN - the full width half max of your scope's beam.
;  SCAN- an anonymous structure with all the following fields:
;     *RA_DEC - a 2 by N array of the right ascesion and declination of
;       your scope pointing, transformed from azi_alt.
;     *DATA_RATE - the rate at which pointing and lsts are calculated, in Hz.
;     *INTEGRATE_TIME - the total time the scan represents, in seconds.
;    
;OUTPUTS:
;   MAPS - an anonymous structure with all the following fields:
;     *MAP_X  - an n_pix by n_pix map of the A_x polarisation in microK
;     *MAP_Y  - an n_pix by n_pix map of the A_y polarisation in microK
;     *HITS - an n_pix by n_pix map of the hits on each pixel
;
;KEYWORDS:
;  SPEED - Angular Velocity of half wave plate. If not set will
;            default to 4Hz.
;  SPT - assumes structures of scope and scan are in SPT format
;        opposed to EBEX format.
;
;ROUTINES USED:
;   PLOT_POLARISATION_ONE - Takes the one dimension array of detected
;                           polarisation temperature from the
;                           bolometer, imitates in reverse the grid
;                           and the HWP and comes back with the
;                           incident photon A_x and A_y. 
;   MAKE_BASIC_MAP - An SPT routine which takes an existing map, adds
;                    information to it, keeps tracks of the hits, in a
;                    very efficient way. Written by KM, Nov.17 2005
;------------------------------------------------------------------------------

FUNCTION plot_polarisation, timestream, scope, scan, n_pix, speed = speed, spt=spt, pointing = pointing

n = n_elements(timestream.polarisation[0,*])
;n = n_elements(timestream.delta[0,*])
n_bolo = timestream.n_bolo
timer = systime(/seconds)

if keyword_set(speed) eq 0 then begin

;vec_final = plot_polarisation_one(timestream, scope, scan)
vec_final = plot_polarisation_one(timestream)
endif else begin

;vec_final = plot_polarisation_one(timestream, scope, scan, speed=speed)
vec_final = plot_polarisation_one(timestream, speed=speed)
endelse

if keyword_set(spt) eq 0 then begin
print, 'Beginning Ebex'
pixel = get_bolo_pixel(timestream, scope, scan, n_pix, pointing = pointing)

;delvarx, timestream
delvarx, pointing

delta = fltarr(n_pix, n_pix)
map_y = fltarr(n_pix, n_pix)
map_x = fltarr(n_pix, n_pix)
hits = fltarr(n_pix, n_pix)

for i=0, n_bolo-1 do  begin
for j = long64(0), n-1 do begin

delta[pixel.x[i,j],pixel.y[i,j]]+=timestream.delta[i,j]
map_x[pixel.x[i,j],pixel.y[i,j]]+=vec_final[j,0,i]
map_y[pixel.x[i,j],pixel.y[i,j]]+=vec_final[j,1,i]
++hits[pixel.x[i,j],pixel.y[i,j]]

endfor
if i mod 25 eq 0 then print,'Finished', i, ' bolos'
endfor 

endif else begin
pixel = get_bolo_pixel(timestream, scope, scan, n_pix, spt=1)


delvarx, timestream

map_y = fltarr(n_pix, n_pix)
map_x = fltarr(n_pix, n_pix)
hits = fltarr(n_pix, n_pix)

make_basic_map, reform(vec_final[*,0,*]), pixel.x, pixel.y, pixel.xoff, pixel.yoff, map_x, hits

delvarx, hits
hits = fltarr(n_pix, n_pix)

make_basic_map, reform(vec_final[*,1,*]), pixel.x, pixel.y, pixel.xoff, pixel.yoff, map_y, hits
endelse

delvarx, pixel

x = map_x/hits
y = map_y/hits
delta = delta/hits

maps = {map_x:x, map_y:y, hits:hits, delta:delta}

;maps = delta/hits

print, 'End Time:',systime(/seconds)-timer

return, maps

END

