pro test_skyview

  ;AUTHOR: S. Leach
  ;PURPOSE: Illustrates the use of skyview.pro - Plotting of healpix maps
  ;         with target areas overplotted.
  
;  map = !HEXSKYROOT+'/data/cbdustmodel_150.000ghz.fits'
  map = !HEXSKYROOT+'/data/dust_carlo_150ghz_512_radec.fits'

  ;---------------------------
  ;Set up targets for plotting
  ;---------------------------

  ;EBEX area (late flight)
  ra_centre = 92. & dec_centre = -44.5 & delta_ra = 36. & delta_dec = 14.
  ra_min  = ra_centre - delta_ra/2.   & ra_max  = ra_centre + delta_ra/2. 
  dec_min = dec_centre - delta_dec/2. & dec_max = dec_centre + delta_dec/2 
  ebex_annulus2 = outline_annulus(ra_min,ra_max,dec_min,dec_max)
  ;EBEX area (early flight)
;  ra_centre = 68. & dec_centre = -44.5 & delta_ra = 36. & delta_dec = 14.
;  ra_centre = 82. & dec_centre = -44.5 & delta_ra = 25. & delta_dec = 19.
  ra_centre = 75. & dec_centre = -44.5 & delta_ra = 23. & delta_dec = 22.
  ra_min  = ra_centre - delta_ra/2.   & ra_max  = ra_centre + delta_ra/2. 
  dec_min = dec_centre - delta_dec/2. & dec_max = dec_centre + delta_dec/2 
  ebex_annulus1 = outline_annulus(ra_min,ra_max,dec_min,dec_max)
  ;Boomerang deep
  ra_min=76 & ra_max=90 & dec_min=-41 & dec_max=-50
  boomerangdeep_annulus= outline_annulus(ra_min,ra_max,dec_min,dec_max)
  boomerang_deep = outline_file(!HEXSKYROOT+'/data/BOOMERANG_deep.dat')
  ;Boomerang shallow 
  ra_min=62 & ra_max=102 & dec_min=-32 & dec_max=-58
  boomerangshallow_annulus= outline_annulus(ra_min,ra_max,dec_min,dec_max)
  boomerang_shallow = outline_file(!HEXSKYROOT+'/data/BOOMERANG_shallow.dat')
  ;Boomerang galaxy 
  boomerang_galaxy = outline_file(!HEXSKYROOT+'/data/BOOMERANG_galaxy.dat')
  ;QUAD pol
  ra_min=74 & ra_max=91 & dec_min=-43 & dec_max=-51
  quad_annulus= outline_annulus(ra_min,ra_max,dec_min,dec_max)
  ;QUAD bright arm  
  quad_brightarm = outline_file(!HEXSKYROOT+'/data/QUAD_brightarm.dat')
  ;QUAD faint arm
  quad_faintarm = outline_file(!HEXSKYROOT+'/data/QUAD_faintarm.dat')
  ;BICEP CMB
  ra_min=-45 & ra_max=45 & dec_min=-48 & dec_max=-67
  bicep_annulus= outline_annulus(ra_min,ra_max,dec_min,dec_max)
  ;BICEP galactic survey - Coords from Tomo
  ra_min=130 & ra_max=250 & dec_min=-45 & dec_max=-70
  bicep_gal_annulus= outline_annulus(ra_min,ra_max,dec_min,dec_max)
; Clover areas from Chris North, Cardiff.
;   04h30m -43deg
;   09h00m -05deg
;   15h00m -01deg
;   23h30m -40deg      
  diameter=20.
  clover1_circle= outline_circle(67.5,-43.,diameter)
  clover2_circle= outline_circle(352.5,-40.,diameter)
  clover3_circle= outline_circle(225.0,-1.,diameter)
  clover4_circle= outline_circle(135.,0.,diameter)
  ;QUIET/ATACAMA 6 hour per day observing constraint
  quiet_dec = -23
  quiet_elevationrange = 30
  dec = quiet_dec-quiet_elevationrange
  quiet_6hr=outline_contour(dec) ; col=0
  quiet_6hr.linestyle=2
  
  diam = 17
  quietcmb1 = outline_target('quiet_cmb-1',diam)
  quietcmb2 = outline_target('quiet_cmb-2',diam)
  quietcmb3 = outline_target('quiet_cmb-3',diam)
  quietcmb4 = outline_target('quiet_cmb-4',diam)
  quietg1   = outline_target('quiet_g-1',diam)
  quietg2   = outline_target('quiet_g-2',diam)

  
  cal1      =  outline_target('rcw38',2)
  cal2      =  outline_target('pks0537-441',2)




;From Johnson et al '03 MAXIPOL1
;Observation Length Average Dust RMS Dust   Observation Time
;                        in [hours]      Level [uK]  Level [uK]
;Beta Ursae Minoris         7.5             20         3.2           night
;Polaris                   2.25            173          23            day
;Gamma Ursae Majori         2.5             11         2.5            day
;Gamma Virgo                0.5             22         3.2            day
;Arcturus                   2.0             27         5.1            day					     
;Beta UMi
  ra=222.677  & dec=74.1617    ; From Johsnon et al, Maxipol ApJ paper
  ra_min= ra-1.5 & ra_max=ra+1.5 & dec_min=dec-1.5 & dec_max=dec+1.5
  maxipol_bumi_annulus = outline_annulus(ra_min,ra_max,dec_min,dec_max)
;Polaris
;Right ascension 02h 31m 48.7s
;Declination +89Â° 15â² 51â³
  ra=37.9529  & dec=  89.2642   ; Polaris
  ra_min= ra-1.5 & ra_max=ra+1.5 & dec_min=dec-1.5 & dec_max=dec+0.7
  maxipol_polaris=outline_annulus(ra_min,ra_max,dec_min,dec_max)
;Gamma Ursae Majori
;Right ascension 11h 53m 49.8s
;Declination +53Â° 41' 41"
   ra=178.458  & dec= 53.6947
   ra_min= ra-1.5 & ra_max=ra+1.5 & dec_min=dec-1.5 & dec_max=dec+1.5
   maxipol_buma_annulus=outline_annulus(ra_min,ra_max,dec_min,dec_max)
;Gamma Virgo (Virginis)
;Right ascension 12h 41m 39.6s
;Declination -1Â° 26â² 58â³
   ra=190.457  & dec= -1.44944
   ra_min= ra-1.5 & ra_max=ra+1.5 & dec_min=dec-1.5 & dec_max=dec+1.5
   maxipol_gammavir_annulus=outline_annulus(ra_min,ra_max,dec_min,dec_max)
;Arcturus
;Right ascension 14h 15 m 39.7s
;Declination +19Â° 10' 56"
   ra=213.915 & dec= 19.1822
   ra_min= ra-1.5 & ra_max=ra+1.5 & dec_min=dec-1.5 & dec_max=dec+1.5
   maxipol_arcturus_annulus=outline_annulus(ra_min,ra_max,dec_min,dec_max)
;Maxima-1
   ra=232.5 & dec= 58.
   ra_min= ra-10. & ra_max=ra+10. & dec_min=dec-6. & dec_max=dec+6.
   maxima1_annulus=outline_annulus(ra_min,ra_max,dec_min,dec_max)
;High velocity cloud (cold dust)
   ra=259.5  & dec=59.5         ; From M.-A.M.-D. 2005
   ra_min= ra-1.5 & ra_max=ra+1.5 & dec_min=dec-2.5 & dec_max=dec+2.5
   hvc_complexc_annulus=outline_annulus(ra_min,ra_max,dec_min,dec_max)
;NRAO 'spider'
   ra=158  & dec=73.  
   ra_min= ra-8. & ra_max=ra+8. & dec_min=dec-2.5 & dec_max=dec+2.5
   nrao_spider_annulus=outline_annulus(ra_min,ra_max,dec_min,dec_max)
;GBT - NEP : 90 < l < 104  , 24 < b < 36 
; glactc,ra3,dec3,2001,96.,30,2,/degree
   ra=269  & dec=65.3
   ra_min= ra-8 & ra_max=ra+8 & dec_min=dec-5. & dec_max=dec+5.
   gbt_nep_annulus=outline_annulus(ra_min,ra_max,dec_min,dec_max)
;WMAP cold spot
;03h15m05s, Î´ = â19d35m02s
   ra=48.7708 & dec= -19.5839
   ra_min= ra-2.5 & ra_max=ra+2.5 & dec_min=dec-2.5 & dec_max=dec+2.5
   wmapcoldspot_annulus=outline_annulus(ra_min,ra_max,dec_min,dec_max)

   ; BLAST vela region
   lon = [269,259,262,276,269]
   lat = [-2.75,-0.75,3,1.5,-2.75]
   euler,lon,lat,ra,dec,2
   blast_vela = outline_polygon(ra,dec)
   

   
   if 0 then begin
       myfield    = make_array(18,value={outline})
       myfield(0) = boomerangdeep_annulus
       myfield(1) = boomerangdeep_annulus
       myfield(2) = boomerangshallow_annulus
       myfield(3) = boomerang_galaxy
       myfield(4) = quad_annulus
       myfield(5) = quad_faintarm
       myfield(6) = quad_brightarm
       myfield(7) = bicep_annulus
       myfield(8) = bicep_gal_annulus
       myfield(9) = quietcmb1
       myfield(10)= quietcmb2
       myfield(11)= quietcmb3
       myfield(12)= quietcmb4
       myfield(13)= quietg1
       myfield(14)= quietg2
       myfield(15)= ebex_annulus1
       myfield(16)= cal1
       myfield(17)= cal2
       color_field= [make_array(15,val=0),255,255,255]
   endif else begin
       myfield    = make_array(7,value={outline})
       myfield(0) = boomerangdeep_annulus
       myfield(1) = boomerangshallow_annulus
;       myfield(2) = boomerang_galaxy
       myfield(2) = quad_annulus
;       myfield(4) = quad_faintarm
;       myfield(5) = bicep_gal_annulus
       myfield(3)= quietcmb2
;       myfield[7]= blast_vela
       myfield(4)= ebex_annulus1
       myfield(5)= cal1
       myfield(6)= cal2
       color_field= [make_array(4,val=0),255,255,255]
   endelse

  ;------------
  ; Run skyview
  ;------------
   units= textoidl('\muK') ;'!4l!3K

  ;  skyview,map,proj='orth',rot_code='c2g',factor=1.e0,min=0.,max=100.
  ;  skyview,map,rot_ang=[68.0000,-85.0000,0.00000],factor=1.e0,min=0.,max=100.
  ;  skyview,map,rot_ang=[68.0000,-85.0000,0.00000],$
  ;    factor=1.,min=0.,max=100.,proj='moll'
  ;  skyview,map,rot_ang=[68.0000,-44.5000,0.00000],proj='gnom',$
  ;    factor=1.e0,min=0.,max=100.
  ;  skyview,map,rot_ang=[90.0000,65.000,0.00000],proj='orth',factor=1.e0,min=0.,max=100.

  ;For collaboration talks
  skyview,map,field=myfield,color_field=color_field,$
    rot_ang=[75.0000,-55.000,0.00000],proj='orth',$
;    rot_ang=[80.0000,-75.000,0.00000],proj='orth',$
    factor=1.e0,min=0.,max=200.,units=units,grat=[30,30],title=' '

;  skyview,map,field=myfield,color_field=color_field,$
;    rot_ang=[-104.2333,34.467,0.00000],proj='moll',$
;    factor=1.e0,min=0.,max=200.,units=units


  ;--------------
  ;Obsolete code:
  ;--------------

  ;cmbmapfile='map_output.fits'
  ;read_tqu,cmbmapfile,cmbmap
  ;index=where(cmbmap(*,0) ne !healpix.bad_value)
  ;stokesq = cmbmap(*,1)
  ;stokesq = (stokesq*(max_uk/2.)/10.  + max_uk/2.)/factor
  ;map(index)=stokesq(index)

  ;scanfile='scan.fits'
  ;read_fits_map,scanfile,scan
  ;index=where(scan ne 0)
  ;map(index)=max_uk/2./factor

  ;planckdeepfield='hitmap_143GHz_512_C.fits'
  ;read_fits_map,planckdeepfield,pdf
  ;index=where(pdf gt 6000)
  ;map(index)=max_uk/2./factor
  

  
end
