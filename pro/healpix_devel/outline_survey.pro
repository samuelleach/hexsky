function outline_survey,survey

  ;AUTHOR: S. Leach
  ;PURPOSE: Creates an outline struct (CMB and mm-wave surveys) for use with
  ;         the Healpix plotting command outline_coord2uv

  case(strlowcase(survey)) of
      'quad_brightarm': begin
         outline = outline_file(!HEXSKYROOT+'/data/QUAD_brightarm.dat')
      end
      'quad_faintarm': begin 
         outline = outline_file(!HEXSKYROOT+'/data/QUAD_faintarm.dat')
      end
      'quad_pol': begin
         ra_min=74 & ra_max=91 & dec_min=-43 & dec_max=-51
         quad_annulus= outline_annulus(ra_min,ra_max,dec_min,dec_max)
      end
      'bicep_cmb': begin
         ra_min=-45 & ra_max=45 & dec_min=-48 & dec_max=-67
         outline = outline_annulus(ra_min,ra_max,dec_min,dec_max)
      end
      'bicep_galactic': begin
         ;Coords from Tomo
         ra_min=130 & ra_max=250 & dec_min=-45 & dec_max=-70
         outline = outline_annulus(ra_min,ra_max,dec_min,dec_max)
      end
      'boomerang_deep': begin
         outline = outline_file(!HEXSKYROOT+'/data/BOOMERANG_deep.dat')
      end
      'boomerang_shallow': begin
         outline = outline_file(!HEXSKYROOT+'/data/BOOMERANG_shallow.dat')
      end
      'herschel_atlas_south_23hr': begin
         ra  = [331.320, 329.971,  367.318, 367.132,331.320]
         dec = [-28.032, -34.034, -35.496, -29.995,-28.032]
         outline = outline_polygon(ra,dec)
      end
      'herschel_atlas_south_2hr': begin
         ra  = [30.408, 29.964, 43.536, 43.092,30.408]
         dec =[-29.841,  -35.816, -35.816, -29.841,-29.841]
         outline = outline_polygon(ra,dec)
      end
      'spt_87sqdeg': begin
         ra_min=77.8363 & ra_max=87.1637 & dec_min=-50.3363 & dec_max=-59.6637 ; Approx coords guessed from arxiv/0912.2338         
         outline = outline_annulus(ra_min,ra_max,dec_min,dec_max)              ; Centred on RA = 82.5, Dec = -55.0
      end
      else: message,'Survey not recognised: ',survey
  endcase
  

  return, outline
  
END
