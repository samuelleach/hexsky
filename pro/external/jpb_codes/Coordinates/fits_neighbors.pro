FUNCTION fits_neighbors,fits_header,fits_image,pixx,pixy,within,distance=distance, $
                         phi=phi,theta=theta,count=count,elapsed_time=elapsed_time

;Returns the index in the fits image of the neighbors of pixel pixx,pixy
;neighbors are those pixels with a distance from the given picel < within (in degrees)
;optionally the distance of all neighbors to the given pixel is returned (in degrees)
;The method used is to compare the phi,tehta of the given pixel with those
;in the fits file. However, this is inefficient with large arrays
;see fits_neighbors2.pro for an alternative way (less general, but faster)

time=systime(1)
;message,'Entering ...',/info

;h2pix,fits_header,i,j,/silent

IF not keyword_set(phi) OR not keyword_set(theta) THEN BEGIN
  pix2coo2,pixx,pixy,coo1,coo2,phi,theta,/silent
  ind=where(abs(phi) GT 180.,count)
  IF count NE 0 THEN BEGIN
    phi(ind)=!indef
    theta(ind)=!indef
  ENDIF
ENDIF

pix2coo2,pixx,pixy,c1,c2,phi0,theta0,/silent
phi0=phi0(0) & theta0=theta0(0)

index=[-1]
distance=[!indef]
count=0

ind1=where(abs(phi-phi0) LE 2.*within/cos(theta0/!radeg) AND abs(theta-theta0) LE 2.*within and $
          phi NE !indef and theta NE !indef AND fits_image NE !indef, count1)

IF count1 NE 0 THEN BEGIN
  gcirc,0,phi0/!radeg,theta0/!radeg,phi(ind1)/!radeg,theta(ind1)/!radeg,distance
  distance=distance*!radeg
  ind2=where(distance LE within,count2)
  IF count2 NE 0 THEN BEGIN
    index=ind1(ind2)
    distance=distance(ind2)
    count=count2
;    help,index,distance,count
  ENDIF
ENDIF

elapsed_time=systime(1)-time
;message,'Exiting ...'+strtrim((systime(1)-time)/60.,2),/info

RETURN,index

END