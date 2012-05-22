function planet_diameter, planet=planet

  ; AUTHOR: S. Leach
  ; PURPOSE: Find planet diameter (km).

   if keyword_set(planet) then begin
       planetlist = ['MERCURY','VENUS','MARS', $
                     'JUPITER','SATURN','URANUS','NEPTUNE','PLUTO']
       index = 1 + where(planetlist eq strupcase(strtrim(planet,2)), Nfound) 
       if index[0] GE 3 then index = index + 1
       if Nfound EQ 0 then message,'Unrecognized planet of ' + planet
   endif else index = [1,2,4,5,6,7,8,9]
   
   ;Mean radius: From Wikipedia
   ;Mercury: 2439.7 .ANBN1 1.0 km
   ;Venus:   6051.8 .ANBN1 1.0 km
   ;Earth:   6371.0 km
   ;Mars:
;     Equatorial radius 3 396.2 .ANBN1 0.1 km
;     Polar radius 3 376.2 .ANBN1 0.1 km
   ;Jupiter:
;     Equatorial radius 71,492 .ANBN1 4 km
;     Polar radius 66,854 .ANBN1 10 km
   ;Saturn:
;     Equatorial radius 60 268 .ANBN1 4 km
;     Polar radius 54 364 .ANBN1 10 km
   ;Uranus:
;     Equatorial radius 25 559 .ANBN1 4 km
;     Polar radius 24 973 .ANBN1 20 km
   ;Neptune:
;     Equatorial radius 24,764 .ANBN1 15 km
;     Polar radius 24,341 .ANBN1 30 km
   ;Pluto: 1,195 km
   
   planets_data=[0.0,2439.7,6051.8,6371.0,3386.,69200.,57300.,25300.,24600.,1195.]
   diameter=fltarr(n_elements(index))
   for ii=0, N_elements(index)-1 do begin
       diameter[ii]=2.*planets_data[index[ii]]     
   endfor
   
   return,diameter
   end



; From Goldin et al 1995:

; "The effective mm/sub-mm band planetary equatorial radii and
; ellipticities of Hildebrand et al. 1985: Req (epsilon) = 3397 (0.006),
; 71495 (0.065), and 60233 km (0.096) for Mars, Jupiter, and Saturn,
; respectively, along with their geocentric distances and polar
; inclinations at the epoch of observation."
