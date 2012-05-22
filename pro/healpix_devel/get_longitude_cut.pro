pro test_get_longitude_cut


   profile =  get_longitude_cut('wmap_band_smth_iqumap_r9_7yr_K_v4.fits')
   
   plot,profile[*,0],profile[*,1],xrange=[180,-180]
   oplot,profile[*,0],profile[*,2]

end

FUNCTION get_longitude_cut,inmap,lon_deg=lon_deg,phi0=phi0,dphi=dphi,$
                           fwhm_in=fwhm_in,fwhm_out=fwhm_out,$
                           nside_intres=nside_intres,nside_lowres=nside_lowres,$
                           order_in=order_in,outputbin_fileroot=outputbin_fileroot
   
   ; AUTHORS: Tess Jaffe - original script and code. S. Leach developer.
   ; PURPOSE: Smooth a map (Temperature or polarization) and
   ;          extract a longitude cut.


   if n_elements(lon_deg) eq 0 then lon_deg  = 0.0
   if n_elements(phi0) eq 0 then phi0  = !PI
   if n_elements(dphi) eq 0 then dphi  = !PI
   if n_elements(fwhm_in) eq 0 then fwhm_in  = 60.
   if n_elements(fwhm_out) eq 0 then fwhm_out = 180.
   if n_elements(nside_intres) eq 0 then nside_intres = 128
   if n_elements(nside_lowres) eq 0 then nside_lowres = 16
   if n_elements(order_in) eq 0 then order_in = 'NESTED'
   if n_elements(outputbin_fileroot) eq 0 then outputbin_fileroot = 'cut'

   order_out = 'RING'


   case datatype(inmap) of
       'STR': begin             ; fits file
           message,'Reading '+inmap,/continue
           read_fits_map,inmap,map,order=order_in,coord=coord_in,nside=nside_in
           read_map = 1
       end
       else : begin
           map      = inmap
           nside_in = npix2nside(n_elements(map[*,0])) 
           read_map = 0
       endelse
   endcase

   ; Establish whether map is polarized or not.
   ss         = size(map)
   simul_type = ss[0] ; = 1 for a map vector, 2 for a multi-column map, assumed to be a TQU map
   if simul_type eq 1 then begin
       ispol = 0
   endif else begin
       ispol = 1
   endelse


   ; Get pixel numbers of longitude cut
   ring_number_lowres  = long((lon_deg + 90.)*4.*nside_lowres/180.)
   list_lowres         = in_ring(nside_lowres,ring_number_lowres,phi0,dphi,nir)
   pix2ang_ring,nside_lowres,list_lowres,theta,phi
   lons_lowres         = phi*180./!PI

   ring_number_intres  = long((lon_deg + 90.)*4.*nside_intres/180.)
   list                = in_ring(nside_intres,ring_number_intres,phi0,dphi,nir)
   pix2ang_ring,nside_intres,list,theta,phi
   lons                = phi*180./!PI

   nintres      = n_elements(list)
   nsmth        = nside_lowres/2
   sigma_smooth = sqrt( fwhm_out^2 - fwhm_in^2 )


   ;Pol case
   ismoothing,map[*,0:2],map_smooth,fwhm_arcmin=sigma_smooth,simul_type=simul_type,order=order_in
   ud_grade,map_smooth,map_lowres,nside_out=nside_intres,order_in=order_in,order_out=order_out
   slice_map_lowres = map_lowres[list,*]
   
   ;Subtract profile of another map here
   ;
   ;
   ;
   ;
   ;
   ;
   ;
   ;
   

   ; Smooth I
   map_I_smth        = (smooth( [reverse(slice_map_lowres[*,0]),slice_map_lowres[*,0],reverse(slice_map_lowres[*,0])],nsmth))[nintres:2*nintres-1]
   map_I_smth_lowres = interpol( map_I_smth, lons, lons_lowres, /quadr )

   ; Smooth Q and U separately to get polarized flux P.
   if ispol then begin
       map_P_smth      = fltarr(nintres,2)
       map_P_smth[*,0] = (smooth( [reverse(slice_map_lowres[*,1]),slice_map_lowres[*,1],reverse(slice_map_lowres[*,1])],nsmth))[nintres:2*nintres-1]
       map_P_smth[*,1] = (smooth( [reverse(slice_map_lowres[*,2]),slice_map_lowres[*,2],reverse(slice_map_lowres[*,2])],nsmth))[nintres:2*nintres-1]
       map_P_smth_lowres = interpol( sqrt(map_P_smth[*,0]^2+map_P_smth[*,1]^2),lons,lons_lowres,/quadr)
   endif
   

   ; Reorder data
   index              = where(lons_lowres gt 180.)
   lons_lowres[index] = lons_lowres[index] - 360.
   index              = sort(lons_lowres)


   ; Write bin files in Tess' format
   outfile = outputbin_fileroot+'_I.bin'
   print,'Writing binary cut to '+outfile
   openw,1,outfile 
   for ii=0,n_elements(list_lowres)-1 do writeu,1,double(map_I_smth_lowres[ii])
   close,1
   
   if ispol then begin
       outfile = outputbin_fileroot+'_P.bin'
       print,'Writing binary cut to '+outfile
       openw,1,outfile 
       for ii=0,n_elements(list_lowres)-1 do writeu,1,double(map_P_smth_lowres[ii])
       close,1
   endif

   if ispol then begin
       outdata      = make_array(n_elements(list_lowres),3)
       outdata[*,0] = lons_lowres[index]
       outdata[*,1] = map_I_smth_lowres[index]
       outdata[*,2] = map_P_smth_lowres[index]
   endif else begin
       outdata      = make_array(n_elements(list_lowres),2)
       outdata[*,0] = lons_lowres[index]
       outdata[*,1] = map_I_smth_lowres[index]
   endelse

   return,outdata


;read_fits_map,'$work/regions/fits_files_ns128/ka_ff_mem_3deg.fits',ff_mem
;   ismoothing,'wmap_Ka_mem_freefree_7yr_v4.fits',ff_mem_lowres,$
;     fwhm_arcmin=sigma_smooth,simul_type=1
;   ud_grade,ff_mem_lowres,ff_mem2,order_in=order_in,order_out=order_out,nside_out=nside_intres
;   slice_ff_mem = ff_mem2[list]



; ------------------------------------------
; print,'Getting WMAP data'

; ; Was smoothed to 1deg by WMAP.  To get 3deg map, then, smooth with
; ismoothing,'wmap_band_smth_iqumap_r9_7yr_W_v4.fits',wmapW_nest_lowres,fwhm_arcmin=sigma_smooth,simul_type=2
; ud_grade,wmapW_nest_lowres,wmapW,nside_out=nside_intres,order_in=order_in,order_out=order_out

; slice_wmapK = wmapK[list,*]
; wmapW[*,0]  = wmapW[*,0] - ff_mem2*(94./33.)^(-2.1) ; correct for free-free
; write_fits_map,'./data_plane/wmap_W-FF_map.fits',wmapW[*,0],/ring

; slice_wmapW = wmapW[list,*]
; wmapKP_smth = fltarr(n_elements(list),2)
; wmapWP_smth = fltarr(n_elements(list),2)
; ; smooth Q and U separately
; wmapKP_smth[*,0] = (smooth( [reverse(slice_wmapK[*,1]),slice_wmapK[*,1],reverse(slice_wmapK[*,1])],nsmth))[n:2*n-1]
; wmapKP_smth[*,1] = (smooth( [reverse(slice_wmapK[*,2]),slice_wmapK[*,2],reverse(slice_wmapK[*,2])],nsmth))[n:2*n-1]

; wmapWI_smth = (smooth( [reverse(slice_wmapW[*,0]),slice_wmapW[*,0],reverse(slice_wmapW[*,0])],nsmth))[n:2*n-1]
; wmapWP_smth[*,0] = (smooth( [reverse(slice_wmapW[*,1]),slice_wmapW[*,1],reverse(slice_wmapW[*,1])],nsmth))[n:2*n-1]
; wmapWP_smth[*,1] = (smooth( [reverse(slice_wmapW[*,2]),slice_wmapW[*,2],reverse(slice_wmapW[*,2])],nsmth))[n:2*n-1]

; ; Compute P and interpolate 
; wmapKP_smth_lowres = interpol( sqrt(wmapKP_smth[*,0]^2+wmapKP_smth[*,1]^2),lons,lons_lowres,/quadr)
; wmapWP_smth_lowres = interpol( sqrt(wmapWP_smth[*,0]^2+wmapWP_smth[*,1]^2),lons,lons_lowres,/quadr)
; wmapWI_smth_lowres = interpol( wmapWI_smth, lons, lons_lowres, /quadr )

; openw,1,'./data_plane/wmapKP_double.bin'
; for i=0,n_elements(list_lowres)-1 do writeu,1,double(wmapKP_smth_lowres[i])
; close,1
; window,0
; plot,modpos(lons_lowres,wrap=180,/zero_cent),wmapKP_smth_lowres,xrange=[180,-180]


; openw,1,'./data_plane/wmapWI_double.bin'
; for i=0,n_elements(list_lowres)-1 do writeu,1,double(wmapWI_smth_lowres[i])
; close,1

; openw,1,'./data_plane/wmapWP_double.bin'
; for i=0,n_elements(list_lowres)-1 do writeu,1,double(wmapWP_smth_lowres[i])
; close,1

; openw,1,'./data_plane/wmapKP_double_plotting.bin'
; for i=0,n_elements(list)-1 do writeu,1,double(sqrt(wmapKP_smth[i,0]^2+wmapKP_smth[i,1]^2))
; close,1

; openw,1,'./data_plane/wmapWI_double_plotting.bin'
; for i=0,n_elements(list)-1 do writeu,1,double(wmapWI_smth[i])
; close,1

; openw,1,'./data_plane/wmapWP_double_plotting.bin'
; for i=0,n_elements(list)-1 do writeu,1,double(sqrt(wmapWP_smth[i,0]^2+wmapWP_smth[i,1]^2))
; close,1



end
