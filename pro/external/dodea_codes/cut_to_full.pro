pro cut_to_full,                 $
in_file   = in_file,             $
out_file  = out_file,            $
out_struc = out_struc,           $
out_array = out_array,           $
out_nside = out_nside,           $
mask      = mask,                $
savemem   = savemem,             $
temperature = temperature,       $
q_polarisation = q_polarisation, $
u_polarisation = u_polarisation, $
n_obs     = n_obs
usage     = usage     

on_error, 2

catch, theError 
If theError ne 0 then begin
Catch, /cancel
help, /Last_Message, Output=traceback
print, traceback
print, 'Unknown error. Continuing somehow...'
return
endif


;catch, theError 
;If theError ne 0 then begin
;Catch, /cancel
;print, theError, '   ', !ERROR_STATE.MSG 
;help, /Last_Message, output=traceback
;print, strmid(traceback[1],0,14), strmid(traceback[1],16,30)
;if  n_elements(traceback) gt 2 then  print, strmid(traceback[2],0,14), strmid(traceback[2],16,30)
;n = n_elements(traceback)
;for i = 1, n-1 do print, strmid(traceback[i],0,14), strmid(traceback[i],16,30)
;print, 'Unknown error in cut_to_full'
;return
;endif

If n_elements(in_file) ne 1 then in_file = '~/spimc/out/step_run_nobb_10iters_100mHz_nominal/signal/maps/map_-10200.fits'
IF n_elements(mask)    ne 1 then mask = 0
IF n_elements(savemem) ne 1 then savemem = 0 ;Set to one to elimnate some fields to save memory
If n_elements(usage)   eq 1 then begin
print, 'cut_to_full--------------------------------------------' 
print, 'Reads my cut sky Healpix maps and extends them to full sky arrays'
print, 'Reads in_file and places output into out_struc, out_array and out_file.'
print, 'Out_nside can also be specified.'
print, 'eg cut_to_full, in_file = filename, out_struc=maps'
print, '------------------------------------------------------'
return
endif

;Read file into a structure
struc = mrdfits(in_file,1,header)
nside = sxpar(header, 'nside')
coord = sxpar(header, 'coordsys') 
order = sxpar(header, 'ordering')
units = sxpar(header, 'units')
If n_elements(units) ne 1 then units = sxpar(header, 'tunit2')

pixel_cut          = struc.pixel
n_pix_cut          = n_elements(pixel_cut)
n_pix              = nside^2*12

udgrd = 0
If n_elements(out_nside) eq 1 then begin
   if out_nside ne nside then udgrd = 1
endif

signal             = 0
n_obs              = 0
serror             = 0
temperature        = 0 
q_polarisation     = 0
u_polarisation     = 0
maska              = 0
Q_mask             = 0
U_mask             = 0

If arg_present(out_struc) then Out_struc = create_struct('header', header)
     
tags   = strarr(100)
tagnum = 0
if tag_exist(struc,'temperature') then begin 
   temperature_cut         = struc.temperature
   struc.temperature       = 0
   temperature             = fltarr(n_pix)     
   temperature(pixel_cut)  = temperature_cut
   if (udgrd eq 1) then ud_grade, temperature, temperature, nside_out =out_nside, order_in = order
   if arg_present(out_struc) then Out_struc = create_struct(out_struc, 'temperature', temperature) 
   tags[tagnum++] = 'temperature'
endif
     
if tag_exist(struc,'q_polarisation') then begin 
   q_polarisation_cut         = struc.q_polarisation
   struc.q_polarisation       = 0
   q_polarisation             = fltarr(n_pix)     
   q_polarisation(pixel_cut)  = q_polarisation_cut
   if (udgrd eq 1) then ud_grade, q_polarisation, q_polarisation, nside_out =out_nside, order_in = order
   if arg_present(out_struc) then Out_struc = create_struct(out_struc, 'q_polarisation', q_polarisation)
   tags[tagnum++] = 'q_polarisation'
endif
    
if tag_exist(struc,'u_polarisation') then begin 
   u_polarisation_cut         = struc.u_polarisation
   struc.u_polarisation       = 0
   u_polarisation             = fltarr(n_pix)     
   u_polarisation(pixel_cut)  = u_polarisation_cut
   if (udgrd eq 1) then ud_grade, u_polarisation, u_polarisation, nside_out =out_nside, order_in = order
   if arg_present(out_struc) then Out_struc = create_struct(out_struc, 'u_polarisation', u_polarisation)
      tags[tagnum++] = 'u_polarisation'
endif


if tag_exist(struc,'signal') AND (savemem ne 1) then begin
   signal_cut         = struc.signal
   struc.signal       = 0
   signal             = fltarr(n_pix)
   signal(pixel_cut)  = signal_cut
   if (udgrd eq 1) then ud_grade, signal, signal, nside_out =out_nside, order_in = order
   if arg_present(out_struc) then Out_struc = create_struct(out_Struc, 'signal', signal)
   tags[tagnum++] = 'signal'
endif

if tag_exist(struc,'n_obs')  then begin
   n_obs_cut          = struc.n_obs
   struc.n_obs        = 0
   n_obs              = fltarr(n_pix)
   n_obs(pixel_cut)   = n_obs_cut 
   if (udgrd eq 1) then  ud_grade, n_obs, n_obs, nside_out =out_nside, order_in = order
   if arg_present(out_struc) then Out_struc = create_struct(out_struc, 'n_obs', n_obs)
      tags[tagnum++] = 'n_obs'
endif

if tag_exist(struc,'serror')  AND (savemem ne 1) then begin 
   serror_cut         = struc.serror
   struc.serror       = 0
   serror             = fltarr(n_pix)     
   serror(pixel_cut)    = serror_cut
   if (udgrd eq 1) then ud_grade, serror, serror, nside_out =out_nside, order_in = order
   if arg_present(out_struc) then Out_struc = create_struct(out_struc, 'serror', serror)
   tags[tagnum++] = 'serror'
endif

if tag_exist(struc,'mask') then begin 
   mask_cut         = struc.mask
   struc.mask       = 0
   maska            = fltarr(n_pix)     
   maska(pixel_cut) = mask_cut
   if (udgrd eq 1) then ud_grade, maska, maska, nside_out =out_nside, order_in = order
   if arg_present(out_struc) then Out_struc = create_struct(out_struc, 'mask', maska)
   tags[tagnum++] = 'mask'
endif

if tag_exist(struc,'q_mask') then begin 
   q_mask_cut         = struc.q_mask
   struc.q_mask       = 0
   q_mask             = fltarr(n_pix)     
   q_mask(pixel_cut)  = q_mask_cut
   if (udgrd eq 1) then ud_grade, q_mask, q_mask, nside_out =out_nside, order_in = order
   if arg_present(out_struc) then Out_struc = create_struct(out_struc, 'q_mask', q_mask)
   tags[tagnum++] = 'q_mask'
endif

if tag_exist(struc,'u_mask') then begin 
   u_mask_cut         = struc.u_mask
   struc.u_mask       = 0
   u_mask             = fltarr(n_pix)     
   u_mask(pixel_cut)  = u_mask_cut
   if (udgrd eq 1) then ud_grade, u_mask, u_mask, nside_out =out_nside, order_in = order
   if arg_present(out_struc) then Out_struc = create_struct(out_struc, 'u_mask', u_mask)
   tags[tagnum++] = 'u_mask'
endif


if tag_exist(struc,'unknown1') then begin 
   unknown1_cut         = struc.unknown1
   struc.unknown1       = 0
   unknown1             = fltarr(n_pix)     
   unknown1(pixel_cut)  = unknown1_cut
   if (udgrd eq 1) then ud_grade, unknown1, unknown1, nside_out =out_nside, order_in = order
   if arg_present(out_struc) then Out_struc = create_struct(out_struc, 'unknown1', unknown1)
   tags[tagnum++] = 'unknown1'
endif


Case mask of 
  1: begin
     IF n_elements(maska) lt 2 then maska = signal

     If n_elements(out_file) eq 1 then $
        write_fits_map, out_file, maska,  coordsys = coord,  ordering = order 
     
     If arg_present(out_array) eq 1 then begin
        out_array = maska ;Changed mask from signal
     endif
     end

  else: begin 
   
     mask = n_obs gt 0
  
     If n_elements(out_file) eq 1 then $
        write_TQU, out_file, [[temperature],[q_polarisation],[u_polarisation]], $
                   coordsys = coord, units    = units, ordering = order
     
     If arg_present(out_array) eq 1 then $
        out_array = [[temperature],[q_polarisation],[u_polarisation]]

  end 
endcase
end
