pro testview_ercsc

  channel  = ['143','217','353']
  flux_cut = [180,400,800,1600]
  nside    = 512

  target_lon = 250.08233
  target_lat = -31.090707

  for cc = 0,n_elements(channel)-1 do begin
     data  = mrdfits('ERCSC_4.3/catalogs/ERCSC_f'+channel[cc]+'.fits',1)
;     help,data,/struct

     index2 = where(abs(data.glon-target_lon) eq min(abs(data.glon-target_lon)))
     print,index2,data[index2].flux,data[index2].glon,data[index2].glat

     for ff = 0 , n_elements(flux_cut) -1 do begin
        index = where(data.flux gt flux_cut[ff])
        ang2pix_ring,nside,!pi/2. - data[index].glat*!dtor,data[index].glon*!dtor,pix
        map      = make_array(nside2npix(nside),value=0.) ;!healpix.bad_value) 
        map[pix] = data[index].flux
        mollview,map,/log,title='ERCSC '+channel[cc]+'GHz sources with flux [mJy] > '+number_formatter(flux_cut[ff]),$
                 png = channel[cc]+'_fc'+number_formatter(flux_cut[ff])+'.png',units='mJy',$
                 WINDOW=1,/SILENT ;,outline=outline_target('pks0537-441',8)
     endfor
  endfor

end
