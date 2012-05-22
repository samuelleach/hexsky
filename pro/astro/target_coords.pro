pro target_coords,ra,dec,target

  ;AUTHOR: S. Leach
  ;PURPOSE: Returns the RA and Dec (in degrees) of certain targets.


  case(strlowcase(target)) of
     'cygnusa': begin
         ra  = 299.868
         dec = 40.7339
     end
     'polaris': begin
         ra  = 37.95
         dec = 89.26
     end
     'casa': begin              ; Cassiopeia A supernova remnant.
         ra  = 350.858
         dec = 58.8
     end
     'keplersnr': begin         ; Kepler's supernova remnant.
         ra  = 262.675
         dec = -21.483
     end
     'tychosnr': begin          ; Tycho's supernova remnant.
         ra  = 5.750
         dec = 64.15
     end
     'galcentre': begin         ; Galactic Center
         ra  = 266.43
         dec = -29.0
     end
     'cena': begin              ; Centaurus A radio galaxy (QuaD)
         ra  = 201.365
         dec = -43.0192
     end
     'rcw38': begin             ; RCW 38 Star cluster (Boomerang)
         ra  = 134.94651
         dec = -47.527408
     end
     'rcw38_blast1': begin      ; RCW 38 ; BLAST J085900-473040
         ra  =  134.75245
         dec =  -47.511184
     end
     'rcw38_blast2': begin      ; RCW 38 ; BLAST J085905-472937
         ra  = 134.77163
         dec = -47.493614
      end
     'vycma': begin             ; VY Canis Majoris ; BLAST's primary calibrator from Truch et al 2009.
        ra  = 110.743
        dec = -25.7676
     end
     'mat5a': begin             ; HII calibrator source used by SPT (STANISZEWSKI et al, 2009ApJ...701...32S)
         ra  = 167.900          ; Possibly this is better known as NGC 3576 ?
         dec = -61.3500
     end
     '1jy0537-441':begin        ; (Boomerang) ; One of the brighter sources in the field. See Giommi and Colafrancesco 2004
         ra  = 84.7129
         dec = -44.085
     end
     'pks0537-441': begin       ; z=0.894 blazar (Boomerang) ; One of the brighter sources in the field.
         ra  = 84.7083          ; Also observed by QUAD (Hinderks et al)
         dec = -44.0856
     end
     'iras08576': begin         ; (Boomerang) ; Masi et al 2006 - near Galactic plane
         ra  = 134.854          ; Also observed by QUAD.
         dec = -43.7628
     end
     'iras1022': begin          ; (Boomerang) ; Masi et al 2006 - near Galactic plane
         ra  = 156.113          ; Also observed by QUAD.
         dec = -24.0231
     end
     'pks0518-45':begin
         ra  = 79.9542
         dec = -45.7794
     end
     'pks0521-365':begin
         ra  = 80.7479
         dec = -36.4672
     end
     'pmnj0321-3711':begin
         ra  = 50.3467
         dec = -37.1925
     end
     '0438-43':begin
         ra  = 70.0738
         dec = -43.5489
     end
     '1jy0454-463':begin
         ra  = 73.9637
         dec = -46.2672
     end
     'pks0511-484':begin
         ra  = 78.21458
         dec = -48.4025
     end
     '1jy0514-459':begin
         ra  = 78.9508
         dec = -45.95
     end
     'pks0450-469':begin
         ra  = 72.9688
         dec = -46.8839
     end
     'ngc6334': begin           ; (GMC observed by SPARO - Li et al 2003 ApJ 648)
         ra  = 260.224
         dec = -35.7511
     end
     'carina_nebula': begin     ; (GMC observed by SPARO - Li et al 2003 ApJ 648)
         ra  = 160.833
         dec = -59.5875         
     end
     'g333.6-0.2': begin        ; (GMC observed by SPARO - Li et al 2003 ApJ 648)
         ra  = 245.536
         dec = -50.1164
     end
     'g331.5-0.1': begin        ; (GMC observed by SPARO - Li et al 2003 ApJ 648)
         ra  = 243.043
         dec = -51.4642
     end
     'ngc3576': begin           ; (Observed by the SEST telescope- see arxiv.org/pdf/astro-ph/0301599)
         ra  =  167.886
         dec = -60.6378
     end
     'sgra': begin              ; Radio source
         ra  =  266.29986
         dec = -28.804915
     end
     'sgrb': begin              ; Radio source
         ra  = 266.75792          
         dec = -28.423402
     end
     'sgrc': begin              ; HII region
         ra  = 266.15120
         dec = -29.470264
     end
     'sgrd': begin              ; Molecular cloud
         ra  = 267.17502
         dec = -28.023867
     end
     'oriona': begin            ; HII region
        ra  = 83.822071
        dec = -5.3910773
     end
     'm42': begin            ; HII region
        ra  = 83.821915
        dec = -5.3872339
     end
     'm40': begin            ; HII region
        ra  = 83.8221
        dec = -5.39111
      end
     'orionb': begin            ; Molecular cloud
         ra  = 85.431246
         dec = -1.9046975
     end
     'omega_nebula': begin      ; HII region (M17)
         ra  = 275.10859
         dec = -16.177062
     end
     'sep': begin               ; South ecliptic pole
         ra  = 90.000000
         dec = -66.560709
     end
     'nep': begin               ; North ecliptic pole
         ra  = 270.0000
         dec = 66.560709
     end
     'crab': begin              ; Crab nebula
         ra  = 83.6332      
         dec = 22.0145
     end
     'rosette': begin           ; The Rosette nebula HII region               
        ra  = 97.99
        dec = 4.760
     end
     'pmn j0455-4616': begin    ; S(4.85GHz)=1653mJy, S(150GHz)=2898+/-60mJy and spectral index = 0.16
         ra  = 73.9642
         dec = -46.2667
     end
     'pmn j0538-4405': begin    ; S(4.85GHz)=4805mJy, S(150GHz)=7114+/-87mJy and spectral index = 0.11
         ra  = 84.7133
         dec = -44.0853
     end 
     'pmn j1256-0547': begin
        ra  = 194.042
        dec = -5.78944
     end
     'goldregion1': begin       ; From Gold et al 2010 Galactic emission paper
        ra  = 281.56577
        dec = 1.8620545
     end
     'goldregion2': begin      ; From Gold et al 2010 Galactic emission paper
        ra  = 321.23725
        dec = 50.469016
     end
     'w5': begin     
        ra  = 42.3375   ; 1.5 deg x 1 deg
        dec = 60.63
     end
     'w4': begin     
        ra  = 38.16
        dec = 61.44
     end
     'w3': begin     
        ra  = 36.76
        dec = 61.87
     end
     'm8': begin          
        ra  =   274.45082     ;270.90  ; Lagoon Nebula, 90' x 40'
        dec =  -11.899142     ;-24.39
     end
     'm20': begin          
        ra  = 270.60  ; Triffid Nebula, 28'
        dec = -23.03
     end
     'rcw49': begin          
        ra  = 156.05254
        dec = -57.774566
     end
     'w49': begin          
        ra  = 168.68094
        dec = -61.196170
     end
     'ngc3372': begin          
        ra  =  161.08313
        dec = -59.885514
     end
     'ngc1499': begin   ; 2 deg extent, California Nebula
        ra  = 60.83 
        dec = 36.42
     end
     'california': begin   ; 2 deg extent, California Nebula
        ra  = 60.83 
        dec = 36.42
     end
     'coma': begin
        ra  = 194.954
        dec = 27.981
     end
     'virgo': begin
        ra  = 186.750
        dec = 12.7167
     end
     'hercules': begin
        ra  = 241.313
        dec = 17.7486
     end
     'norma': begin
        ra  = 243.887
        dec = -60.9083
     end
     'ic2944': begin   ; Running Chicken Nebula (who makes these names up?)
        ra  = 176.44   ; 75' size
        dec = -60.19
     end
     'w35': begin   
        ra  = 287.57656       ;274.45 
        dec = 9.0969681       ;-11.98
     end
     'ngc281': begin   
        ra  = 13.25
        dec = 56.62
     end
     'ldn1111': begin   
        ra  = 325.125
        dec = 57.8000
     end
     'rcw175': begin   
        ra  = 281.599
        dec = -3.77389
     end
     'perseus': begin   ;Molecular cloud
        ra  = 55.4000 ;From Watson et al.
        dec = 31.8000
     end
     'g159.6-18.5': begin ; HII region superimposed on Perseus
        ra  =  54.32
        dec = 32.52
     end
     'g160.3-18.4': begin
        ra  =  55.53
        dec = 31.82
     end
     'perseus2':begin
        ra  = 52.34
        dec = 31.20
     end
     'perseus3':begin
         ra  = 60.42
         dec = 36.32
     end
     'b1358+305':begin
         ra  = 209.604
         dec = 30.5333
      end
     'rhooph': begin  
        ra  =  246.488
        dec = -24.3472
     end
     'saturn_yr1':begin
         ra  = 320.07133
         dec = -16.610982
     end
     'mars_yr1':begin
         ra  = 124.94
         dec = 19.73
     end
     'ldn1622':begin
         ra  = 88.5958
         dec = 1.78167
     end  
     'ldn1780':begin
         ra  = 235.12
         dec = -7.36 
     end  
     'w40':begin
         ra  = 280.705
         dec = -3.54083
     end
     'fornaxa':begin
         ra  = 50.58      ; WMAP pol'n source in POWPS catalog
         dec = -37.177
     end
     'pks0829+04':begin
         ra  = 127.95     ; WMAP pol'n source in POWPS catalog (rising dust spectra)
         dec = 4.559
     end
     '3c273':begin
         ra  = 187.275    ; WMAP pol'n source in POWPS catalog
         dec = 2.044
     end
     'pks1320-44':begin
         ra  = 201.330    ; WMAP pol'n source in POWPS catalog
         dec = -43.025
     end
     'newps432':begin           ; WMAP pol'n source in POWPS catalog
        ra  = 304.170 
        dec = 45.776
     end
     'ngc7293':begin   
        ra  = 337.411
        dec = -20.8371
     end
     'm31': begin
        ra  = 10.6846
        dec = 41.3192
     end
     'lmc': begin
        ra  = 84.712
        dec = -69.184
     end
     'smc': begin
        ra  = 13.1867
        dec = -72.8286
     end
     'quiet_cmb-1': begin  ; 905 hours
        ra  = 181.
        dec = -39.
     end
     'quiet_cmb-2': begin
        ra  =  78.         ; 703 hours
        dec = -39.
     end
     'quiet_cmb-3': begin
        ra  = 12.          ; 837 hours
        dec = -48.
     end
     'quiet_cmb-4': begin
        ra  = 341.         ; 223 hours
        dec = -36.
     end
     'quiet_g-1': begin
        ra  = 240.         ; 311 hours
        dec = -53.
     end
     'quiet_g-2': begin
        ra  = 266.5        ; 92 hours
        dec = -28.93
     end
     '3c279':begin
         ra  = 194.046
         dec = -5.78944
     end
     'virgoa': begin
        ra  = 187.63
        dec = 12.350
     end
     'm17': begin
        ra  = 275.10443
        dec = -16.176058
     end
     'm16': begin
         ra  = 274.70109
         dec = -13.811816
     end     
     'perseus_arm': begin
        ra  = 46.813294
        dec = 58.297705
     end
      'cygnus_arm': begin
         ra  = 308.97122
         dec = 40.663616
      end
      'cygnus': begin
         ra  = 310.02686       
         dec = 42.197783
      end
      'sagittarius_arm': begin
         ra  =  290.82914
         dec =  15.142373
      end
      'scutumcrux_arm': begin
         ra  = 208.07151
         dec = -62.033844
       end
      'carina_arm': begin
         ra  = 166.13130 
         dec = -60.159624
     end
     'vela': begin
         ra  = 128.836
         dec = -45.1757
     end
     'ldb0.5': begin
         ra  = 82.5
         dec = -44.5
     end
     'jupiter_survey1': begin
         ra  = 320.41
         dec = -16.47
     end
     'highgal1': begin
         ra  = 2.24
         dec = -36.40
     end
     'highgal2': begin
         ra  = 205.42
         dec = 41.59
     end
     'src210.9-36.54': begin
         ra  = 68.796412
         dec = -14.248752
     end
     'ngc6357': begin
         ra  = 270.90868
         dec = -24.386132
     end
     'dwb49': begin
         ra  = 261.07855
         dec = -34.332321
     end
     'eridanus': begin
         ra  = 60.633995
         dec = 11.012405
     end
     'serpens': begin
         ra  = 277.500     
         dec = -3.00000
     end
     'lupus': begin
         ra  =  234.07376      
         dec = -34.786246    
     end
     'taurus': begin
         ra  = 67.5000
         dec = 26.0000
     end
     else: message,'Target not recognised: '+target
  endcase
  
end
