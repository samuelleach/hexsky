function GET_NA_WAFER,mychannel,all_detectors=all_detectors

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns an array of detector structs with boresight
  ;         information for wafers for the NA campaign.


  focalplanefile = !HEXSKYROOT+'/data/ebex_fpdb.txt'
  fp = read_focalplanefile(focalplanefile)
  readcol,!HEXSKYROOT+'/data/na_fp_v3.dat',channel,row,col,/silent

  for cc = 0,n_elements(mychannel)-1 do begin
    case(mychannel[cc]) of
    150: begin
      mywafer = 2
;      alpha   = -60
      alpha   = -120
    end
    250: begin
      mywafer = 1
;      alpha   = 180
      alpha   = 240
    end
    410: begin
      mywafer = 7
;      alpha   = -180
      alpha   = -120
    end
    else: message,'Use channel = 150, 250, or 410'
    endcase
  

    if(not keyword_set(all_detectors)) then begin
        index    = where(channel eq mychannel(cc)) &  wafer    = mywafer
        rowset   = row(index)
        colset   = col(index)
        nn       = n_elements(rowset)
        
        fpindex = make_array(nn,value=0L)
        for dd=0, nn-1 do begin
            index       = where(fp.row eq rowset[dd] and fp.col eq colset[dd] and fp.wafer eq mywafer)
            fpindex(dd) = index
        endfor
    endif else begin
        fpindex = where(fp.wafer eq mywafer)
    endelse

    wafer         = fp(fpindex)
    wafer.power   = 1
    wafer.channel = mychannel[cc]
    
    ;Peform rotation. 
    alpha = alpha*!dtor  
    az    = cos(alpha)*wafer.az -sin(alpha)*wafer.el
    el    = sin(alpha)*wafer.az +cos(alpha)*wafer.el

    ;Flip focalplane
;    az = -az

    
    wafer.el = el
    wafer.az = az
    
    

    if cc eq 0 then begin
      focalplane = wafer
    endif else begin
      focalplane = [wafer,focalplane]
    endelse
      
  endfor
    
  return,focalplane


end
