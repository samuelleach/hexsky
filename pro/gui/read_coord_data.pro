FUNCTION READ_COORD_DATA,FILENAME,TYPEFLAG

  ;Author : C.Bao
  ;Purpose: read in list of targets or sites containing the name and
  ;         coordinate information from file that is usable by
  ;         Easypoint GUI




  openr,1,filename,error=err  ; Load in default locations from file

 ;typeflat: 1, sites data
 ;          2, target data
 ;          3, calibrator data

  if typeflag eq 1 or typeflag eq 2 then $
     nelement = 6 else $
     nelement = 7

  if err eq 0 then begin
    temp=''
    readf,1,temp ; one empty line for comments
    readf,1,temp

    j = 0
    while strcompress(strupcase(temp)) ne 'END' do begin

      thebreak = strpos(temp,':')
      thisname = strtrim(strcompress( (byte(temp))(0:thebreak-1) ),2)
      thiscoord = fltarr(nelement)
      reads,string( (byte(temp))(thebreak+1:n_elements(byte(temp))-1) ), $
            thiscoord

      this_1st_coord = (thiscoord(0) ge 0) ? strtrim(string(thiscoord(0)$
                        +thiscoord(1)/60+thiscoord(2)/3600,$
                        format='(f8.3)'),2):strtrim(string(thiscoord(0)$
                        -thiscoord(1)/60-thiscoord(2)/3600,$
                        format='(f8.3)'),2)
      this_2nd_coord = (thiscoord(3) ge 0) ? strtrim(string(thiscoord(3)$
                        +thiscoord(4)/60+thiscoord(5)/3600,$
                        format='(f8.3)'),2):strtrim(string(thiscoord(3)$
                        -thiscoord(4)/60-thiscoord(5)/3600,$
                        format='(f8.3)'),2)
  
      if typeflag eq 2 or typeflag eq 3 then begin
        if thiscoord(0) lt 0 then this_type = abs(thiscoord(0)) $
        else this_type = 0
      endif

      if j eq 0 then begin

       if typeflag eq 2 or typeflag eq 3 then type = this_type

       names = thisname
       fst_coord = this_1st_coord
       snd_coord = this_2nd_coord

       if typeflag eq 3 then flux = thiscoord(6)

      endif $
      else begin

       if typeflag eq 2 or typeflag eq 3 then type = [type, this_type]

       names = [names,thisname]
       fst_coord = [fst_coord,this_1st_coord]
       snd_coord = [snd_coord,this_2nd_coord]

       if typeflag eq 3 then flux = [flux,thiscoord(6)]  

      endelse

      j = j + 1
      readf,1,temp
    endwhile
    close,1

    names = [names,'User Defined']

    ninput = n_elements(names)

    case typeflag of
       1: begin
          site = {site}
          sites = replicate(site,ninput)
          sites.name = names

          for i=0,ninput-2 do begin
           sites(i).latitude = fst_coord(i)
           sites(i).longitude = snd_coord(i)
          endfor

          return,sites
       end
       2: begin
          target = {target}
          targets = replicate(target,ninput)
          targets.name = names

          for i=0,ninput-2 do begin          
           targets(i).type = type(i)
           targets(i).RA = fst_coord(i)
           targets(i).DEC = snd_coord(i)
          endfor

          return,targets
       end

       3: begin
          calibrator = {calibrator}
          calibrators = replicate(calibrator,ninput) 
          calibrators.name = names

          for i=0,ninput-2 do begin 
           calibrators(i).type = type(i)
           calibrators(i).RA = fst_coord(i)
           calibrators(i).DEC = snd_coord(i)
           calibrators(i).flux = flux(i)
          endfor

          return,calibrators
       end

   endcase

  endif $
  else begin
    names = ['User Defined']
    case typeflag of
      1: begin
          site = {site}
          site.name = names
          site.latitude = '-77.500'
          site.longitude = '165.000'
          return,site
      end

      2: begin
          target = {target}
          target.name = names
          target.RA = '2.300'
          target.DEC = '-5.000'
          return,target
      end

      3: begin
          calibrator = {calibrator}
          calibrator.name = names
          calibrator.RA = '4.527'
          calibrator.DEC = '18.233'
          calibrator.flux = 0.
          return,calibrator
      end
  endcase


 endelse



END
