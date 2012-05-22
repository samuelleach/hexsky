FUNCTION fits_neighbors2,fits_header,naxis1,naxis2,coo1,coo2,ipix_array,jpix_array,pixx,pixy, $
                         within,distance=distance, $
                         count=count,elapsed_time=elapsed_time

;Returns the index in the fits image of the neighbors of pixel pixx,pixy
;neighbors are those pixels with a distance from the given picel < within (in degrees)
;optionally the distance of all neighbors to the given pixel is returned (in degrees)
;The method used is to move from the given pixel into increasing size rings
;until the given distance (within) is exceeded for all pixels of the ring

time=systime(1)

;starting point
h2pix,fits_header,/silent
pix2coo2,pixx,pixy,c1,c2,/silent

i=round(pixx)>0<(naxis1-1)
j=round(pixy)>0<(naxis2-1)

gcirc,0,coo1(i,j)/!radeg,coo2(i,j)/!radeg,c1/!radeg,c2/!radeg,dist
dmin=dist
all_dist=[dist]
ij=lonarr(1,2) & ij(0,0)=i & ij(0,1)=j
all_index=[ij2index(ij,[naxis1,naxis2])]
nn=1L
IF dmin*!radeg LE within THEN BEGIN
  REPEAT BEGIN
    index=ring_index(i,j,naxis1,naxis2,nn,count=count)
    gcirc,0,coo1(index)/!radeg,coo2(index)/!radeg,c1/!radeg,c2/!radeg,dist
    ind=where(dist LE within/!radeg,count)
    IF count NE 0 THEN BEGIN
      ij=lonarr(count,2)
      ij(*,0)=ipix_array(index(ind)) & ij(*,1)=jpix_array(index(ind))
      all_dist=[all_dist,dist(ind)]
      all_index=[all_index,ij2index(ij,[naxis1,naxis2])]
    ENDIF ELSE BEGIN
      goto,the_end
    ENDELSE
    dmin=min(dist)
    nn=nn+1
;  print,dmin*!radeg,within
  ENDREP UNTIL (dmin*!radeg GT within)
ENDIF

the_end:

distance=all_dist*!radeg
elapsed_time=systime(1)-time
count=(size(all_index))(1)

RETURN,all_index

END