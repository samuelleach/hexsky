PRO get_declination_centres,centraldec_deg,decrange_total_deg,nbrick,nlayer,$
                            brick_centraldec_deg,brick_decrange_deg,brick_layer,$
                            pointing_period_fraction,$
                            layering_type=layering_type

  ;AUTHOR: S. Leach
  ;PURPOSE: Suggest declination centres for a list of scanning commands.
  ;          A test program test_get_declination_centres is provided.

  ;---------
  ;  INPUTS:
  ;---------
  ;  centraldec_deg       = Desired central declination [deg] of patch to be scanned.
  ;  decrange_total_deg   = Desired total declination range [deg] to be scanned.
  ;  nbrick               = Number of 'bricks' (commands) with which to acheive
  ;                         the scanning of the chosen total declination range.
  ;  nlayer               = Number of surveys repeats.

  ;---------
  ;  OPTIONS
  ;---------
  ;  Layering type = 0 (Unequal time pointing periods) (default)
  ;  Layering type = 1 (Equal time pointing periods)

  ;----------
  ;  OUTPUTS:
  ;----------
  ;  brick_centraldec_deg = List of declination centres [deg] for each
  ;                         command.
  ;  brick_decrange_deg   = List of declination ranges [deg] for each
  ;                         command.
  ;  brick_layer          = List of integers (1-nlayer) giving the layer
  ;                         number of each command.
  ;  pointing_period_fraction = List of normalised length of command. 
  ;                             i.e. A value of 1 corresponds to a command
  ;                             that will have unit length (in units of
  ;                             the command duration. A value of 0.5 
  ;                             corresponds to a command with only
  ;                             50% duration (this is used with
  ;                             layering_type = 0).

  if n_elements(layering_type) eq 0 then layering_type = 0

  decrange_stretcher = decrange_total_deg/float(nbrick)
  decrange_header    = decrange_total_deg/float(nbrick)/2.


  layercount               = 0
  brick_centraldec_deg     = 0.
  brick_decrange_deg       = 0.
  brick_layer              = 0
  pointing_period_fraction = 0.

  case layering_type of
     0: begin ; Uses unequal time pointing periods
        for ll = 0, nlayer - 1 do begin
           if (ll mod 2) eq 0 then begin ; "Base" layers
              dec0 = centraldec_deg - decrange_total_deg/2. + decrange_stretcher/2.
              for bb = 0, nbrick - 1 do begin
                 brick_layer          = [brick_layer,ll+1]
                 brick_centraldec_deg = [brick_centraldec_deg, dec0 + float(bb)*decrange_stretcher]
                 brick_decrange_deg   = [brick_decrange_deg, decrange_stretcher]
                 pointing_period_fraction = [pointing_period_fraction,1.]
              endfor
           endif
           
           if (ll mod 2) eq 1 then begin ; "Interleave" layers with "headers"
              for bb = 0, nbrick  do begin
                 brick_layer = [brick_layer,ll+1]
                 case bb of
                    0: begin    ; Header
                       dec0                 = centraldec_deg - decrange_total_deg/2. + decrange_header/2.
                       brick_centraldec_deg = [brick_centraldec_deg, dec0 ]
                       brick_decrange_deg   = [brick_decrange_deg, decrange_header]
                       pointing_period_fraction = [pointing_period_fraction,0.5]
                    end
                    nbrick: begin ; Header
                       dec0                 = centraldec_deg + decrange_total_deg/2. - decrange_header/2.
                       brick_centraldec_deg = [brick_centraldec_deg, dec0 ]
                       brick_decrange_deg   = [brick_decrange_deg, decrange_header]
                       pointing_period_fraction = [pointing_period_fraction,0.5]
                    end
                    else: begin ; Intervleave
                       dec0                 = centraldec_deg - decrange_total_deg/2. + decrange_stretcher
                       brick_centraldec_deg = [brick_centraldec_deg, dec0 + float(bb-1)*decrange_stretcher ]
                       brick_decrange_deg   = [brick_decrange_deg, decrange_stretcher]
                       pointing_period_fraction = [pointing_period_fraction,1.0]
                    end
                 endcase
              endfor
           endif
        endfor
     end
     1: begin  ; Simple "Stretcher bond" design with equal pointing periods.
        for ll = 0, nlayer - 1 do begin
           if (ll mod 2) eq 0 then begin 
              dec0 = centraldec_deg - decrange_total_deg/2. - decrange_stretcher/4.
           endif else begin
              dec0 = centraldec_deg - decrange_total_deg/2. + decrange_stretcher/4.
           endelse
           for bb = 0, nbrick - 1 do begin
              brick_layer          = [brick_layer,ll+1]
              brick_centraldec_deg = [brick_centraldec_deg, dec0 + float(bb)*decrange_stretcher]
              brick_decrange_deg   = [brick_decrange_deg, decrange_stretcher]
              pointing_period_fraction = [pointing_period_fraction,1.0]
           endfor
        endfor
     end
  endcase



  nbricktotal          = n_elements(brick_layer) - 1
  brick_layer          = brick_layer[1:nbricktotal]
  brick_centraldec_deg = brick_centraldec_deg[1:nbricktotal] 
  brick_decrange_deg   = brick_decrange_deg[1:nbricktotal]
  pointing_period_fraction = pointing_period_fraction[1:nbricktotal]

  
  index                = sort(brick_centraldec_deg)
  brick_layer          = brick_layer[index]
  brick_centraldec_deg = brick_centraldec_deg[index] 
  brick_decrange_deg   = brick_decrange_deg[index]
  pointing_period_fraction = pointing_period_fraction[index]
  

end

pro test_get_declination_centres

  centraldec_deg     = -44.5
  decrange_total_deg = 14.
  nbrick             = 5
  nlayer             = 4


  ps_start,file='dec_wall.ps'

 ;-------------------------------------------------- 
 ; Layering type = 0 (Unequal time pointing periods)
 ; Layering type = 1 (Equal time pointing periods)
 ;-------------------------------------------------- 
  layering_type = [0,1]

  for ll = 0, n_elements(layering_type)-1 do begin
      get_declination_centres,centraldec_deg,decrange_total_deg,nbrick,nlayer,$
        brick_centraldec_deg,brick_decrange_deg,brick_layer,$
        pointing_period_fraction,layering_type=layering_type[ll]


      plot,[0.5,max(brick_layer)+0.5], centraldec_deg - decrange_total_deg*[0.5,-0.5]*1.2,/nodata,$
        xtitle='Layer',ytitle='Declination [deg]',chars=2,$
        title=strtrim(n_elements(brick_layer),2)+' commands',$
        xthick=5,ythick=5,xstyle=1
      oploterror,brick_layer,brick_centraldec_deg,brick_decrange_deg/2.,psym=3,errthick=5


      print,brick_centraldec_deg
      print,brick_layer
      print,pointing_period_fraction

  endfor


  ps_end

  

end
