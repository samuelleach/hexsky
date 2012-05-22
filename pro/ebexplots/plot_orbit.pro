pro plot_orbit


ps_start,file='test_antarctica.ps'

lon0 = 166.6
lat0 = -77.836

limit = [-90,0,-60,0]
Map_Set, -90.,0,180.-lon0,/gnomic, /Continents,/iso,/grid,/label,limit=limit,$
         charsize=1.2,title='Remember: 1) Antarctica rotates clockwise. 2) HA = LST - RA'

; So between   RA - 1 < LST < RA + 1   and   RA + 11 < LST < RA + 13 do calibrator scans.

jd       = dindgen(100)*5./99.
ncommand = n_elements(jd)
lon      = lon0 -0.1*jd*360.
lat      = make_array(ncommand,value=lat0)


red  = fsc_color('red')
oplot,lon,lat,thick=5,color=red,psym=0

;oplot,[lon[0],lon[0]],[lat[0],lat[0]],color=blue,psym=sym(1),thick=5


jd0        = jd[0]
njd        = floor(jd[ncommand-1]-jd0)
lon_perday = make_array(njd)
lat_perday = make_array(njd)

for jj = 0, njd-1 do begin
    index          = closest(jd0 + float(jj),jd)
    lon_perday[jj] = lon[index]
    lat_perday[jj] = lat[index]
endfor
blue  = fsc_color('blue')
oplot,lon_perday,lat_perday,color=blue,psym=sym(1),thick=5







ps_end

end
