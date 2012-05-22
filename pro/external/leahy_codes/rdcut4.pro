PRO rdcut, nhead, map, longs, colats, NUM_CUTS = numcuts, VERBOSE=verbose
; procedure to read a GRASP8 or GRASP9 cuts file.
; input:   
;    nhead:    Number of lines in the overall header to ignore
;    numcuts:  Number of cuts in the file (>= actual number of cuts is
;              OK)
;
; output: 
;    map:      longitude-co-latitude grid made from cuts
;    longs:    list of longitudes for array
;    colats:   list of co-latitudes for array

IF N_ELEMENTS(nhead) NE 1 THEN BEGIN
    PRINT, 'Please enter number of header lines as second argument'
    GOTO, QUIT
ENDIF

; Defaults
lun = 1
junk = 'a string' & header = 'a title'
eps = 1e-4 ;       a small number
cor = 0d & coi = 0d & xr = 0d & xi = 0d

d2r = !dpi / 180d
alpha = 85d * d2r ; not used at present

IF ~ KEYWORD_SET(numcuts) THEN numcuts = 360

verbose = KEYWORD_SET(verbose)

FILEINPUT = DIALOG_PICKFILE(filter = '*.cut',PATH='/users/leahy/im_beam')
cutfile = STRMID(FILEINPUT,RSTRPOS(FILEINPUT,'\')+1)
OPENR, lun, cutfile

; read through nhead-line general header
FOR i = 0,nhead-1 DO BEGIN
    READF, lun, junk
ENDFOR

; Read each cut
ncut = 0
WHILE ~ EOF(lun) DO BEGIN
    IF ncut GE numcuts THEN BEGIN
        PRINT, 'RDCUT: Too many cuts: re-run with parameter NUM_CUTS set'
        GOTO, QUIT
    ENDIF
    
; read 1-line header   
    READF, lun, header

; read 1-line general data for cut
    READF, 1, V_INI, V_INC, V_NUM, C, ICOMP, ICUT, NCOMP

    test = V_INI + INDGEN(V_NUM)*V_INC
 
    IF ncut EQ 0 THEN BEGIN
        theta = test
        phi = C
        data = FLTARR(V_NUM,numcuts,4)
        IF verbose THEN PRINT, 'First phi value is', C
    ENDIF ELSE IF ncut EQ 1 THEN BEGIN
        dphi = C - phi
        IF verbose THEN PRINT, 'Interval in phi seems to be', dphi, ' degrees.'
        phi = [phi,C]
    ENDIF ELSE phi = [phi,C]

    IF MAX(ABS(theta-test)) GT eps THEN BEGIN
        PRINT, 'Inconsistent theta pixelisation on cut #', ncut
        GOTO, QUIT
    ENDIF
      
; read V_NUM lines of data
    FOR i=0, V_NUM-1 DO BEGIN
        READF, lun, cor, coi, xr, xi
        data[i,ncut,0] = cor & data[i,ncut,1] = coi
        data[i,ncut,2] = xr  & data[i,ncut,3] = xi
    ENDFOR

    ncut += 1
ENDWHILE	

IF VERBOSE THEN BEGIN 
    PRINT, 'Found', ncut, ' cuts'
    PRINT, 'Last phi value was', C
ENDIF

CLOSE, lun

; Trim arrays
data = data[*,0:ncut-1,*]

; data is arranged (theta,phi), with theta running -theta_max -> +theta_max

; re-arrange into (phi,theta) grid: 

; The cuts usually cross theta=0 at their centre, so split into left and
; right halves to make grid: 

middle = WHERE(ABS(theta) LT eps)
IF verbose THEN PRINT, 'Theta = 0 is at element', middle
IF 2*middle + 1 ne V_NUM THEN BEGIN
    PRINT, 'Last theta value is ',theta(V_NUM-1),' at element', V_NUM-1
    PRINT, 'Cannot make rectangular grid: quitting'
    GOTO, QUIT
ENDIF

; phi refers to postive theta ("right") side: negative thetas (left
; side) are diametrically opposed, so 180 degrees around in longitude:
rphi = phi
lphi = phi + 180.0                

lh = data[0:middle,*,*] 
rh = data[middle:V_NUM-1,*,*]
lhr = fltarr(ncut,middle+1,4) 
rhr = fltarr(ncut,middle+1,4)

FOR i=0,3 DO BEGIN
    lhr[*,*,i] = ROTATE(lh[*,*,i],3) ; rotate by 270 deg (-> (Y0, -X0))
    rhr[*,*,i] = ROTATE(rh[*,*,i],4) ; transpose         (-> (Y0,  X0))
ENDFOR

map    = [ rhr,  lhr]
longs  = [rphi, lphi]
colats = theta[middle:V_NUM-1]

QUIT:

END

;---------------------------------------------------------------------------
PRO pad, data, theta, phi, out, tout, pout
; Pads a 2-D (phi,theta) map of the sky for better interpolation

S = SIZE(data)
npix = 2

lastp = phi[S[1]-1]
lastt = theta[S[2]-1]
dp = (lastp - phi[0])   / (S[1]-1)
dt = (lastt - theta[0]) / (S[2]-1)
halfturn = FIX(180d0 / dp)
IF (ABS(halfturn*dp - 180d0) GT 0.001*dp) THEN BEGIN
    PRINT, '180 degree shift is not an integral number of pixels:'
    PRINT, 'Pixel size', dp
    GOTO, QUIT
ENDIF ELSE IF (ABS(theta[0]) GT 0.001*dt) THEN BEGIN
    PRINT, 'Grid does not start at pole:'
    PRINT, 'First theta value', theta[0]
    GOTO, QUIT
ENDIF
nospole = lastt LT 179.9d0 ; Can't wrap at south pole if not on grid!

;Squash any extra dimensions:
last = 1
IF S[0] gt 2 THEN FOR i=3,S[0] DO last *= S[i]
data = REFORM(data,S[1],S[2],last,/OVERWRITE)

; Pad first two dimensions by npix elements at each end
dims = [S[1:2]+2*npix,last]
ipmax = dims[0] - npix - 1
itmax = dims[1] - npix - 1
IF nospole THEN dims[1] -= npix

out = fltarr(dims)

; Put original in middle of padded array:
out[npix:ipmax,npix:itmax,*] = data

; Wrap in longitude:
out[0:npix-1, npix:itmax,*] = data[S[1]-npix:*,*,*]
out[ipmax+1:*,npix:itmax,*] = data[0:npix-1,   *,*]
pout = [phi[S[1]-npix:*]-360,phi,phi[0:npix-1]+360]

; Skip over pole:
polcap = out[*,npix+1:2*npix,*]
; Wrap by 180 degrees and swap rows (assumes npix = 2)
polcap = SHIFT(polcap,halfturn,1,0)
out[*,0:npix-1,*] = polcap

tout = [-REVERSE(theta[1:npix]),theta]

IF ~nospole THEN BEGIN
    polcap = out[*,itmax-npix:itmax-1,*]
    polcap = SHIFT(polcap,halfturn,1,0)
    out[*,itmax+1:*,*] = polcap
    tout = [tout, lastt + (INDGEN(npix) + 1)*dt]
ENDIF

; return files to original configuration
data = REFORM(data,S[1:S[0]],/OVERWRITE)
S[1:2] = dims[0:1]
out = REFORM(out,S[1:S[0]],/OVERWRITE)

RETURN

QUIT:

END

;---------------------------------------------------------------------------
FUNCTION stokes, data
; Converts from data array storing (copol_real, copol_imag,
; crosspol_real, cross_pol_imag) into stokes array storing (I,Q,U,V):

S = SIZE(data)
; Check that we have four planes:
IF S[S[0]] NE 4 THEN BEGIN
    PRINT, 'STOKES: incorrectly formated input array: must have four planes'
    RETURN, stokes ; undefined return
END

;Squash any extra dimensions:
first = 1
FOR i=1,S[0]-1 DO first *= S[i]
data = REFORM(data,first,4,/OVERWRITE)

stokes = data

copol = data[*,0]*data[*,0] + data[*,1]*data[*,1]
xpol  = data[*,2]*data[*,2] + data[*,3]*data[*,3]

stokes[0,0] = copol + xpol
stokes[0,1] = copol - xpol
stokes[0,2] = 2.0*(data[*,0]*data[*,2] + data[*,1]*data[*,3])
stokes[0,3] = 2.0*(data[*,1]*data[*,2] - data[*,0]*data[*,3])
; return input and output arrays to original configuration
data   = REFORM(data,S[1:S[0]],/overwrite)
stokes = REFORM(stokes,S[1:S[0]],/overwrite)
RETURN, stokes
END

;---------------------------------------------------------------------------
PRO ll2grid, map, longs, colats, grid, nuv, maxuv, VERBOSE=verbose
; Program to interpolate cuts data onto a uv (direction cosine) grid.
; map:    data read from cuts file, reformated to theta,phi grid
; longs:  set of longitudes (phi)
; colats: set of colatitudes (theta)
; grid[nuv,nuv,4]:   output uv grid
; nuv:             number of UV pixels on each axis
; maxuv:           UV coords on grid run from +/- maxuv


; Useful constants:
twopi = 2d*!dpi
r2d   = 360d/twopi
nan   = !values.F_NAN
nothing = ''

verbose = KEYWORD_SET(verbose)

maxtheta = MAX(colats)
IF verbose THEN PRINT, 'll2grid: Maximum colatitude in dataset is:', maxtheta

IF maxtheta gt 90d THEN BEGIN
    ; direction cosines are ambiguous
    PRINT, 'll2grid: Using northern hemisphere only'
    maxtheta = 90d
ENDIF

IF ~N_ELEMENTS(maxuv) THEN maxuv = SIN(maxtheta/r2d)
IF maxuv LE 0 THEN maxuv = SIN(maxtheta/r2d)

; Set up U, V coord arrays for output grid:
u = -maxuv + LINDGEN(nuv)*(2d*maxuv)/(nuv-1)
v = u

; Get theta & phi increments
nlats = N_ELEMENTS(colats)
V_INC = (colats[nlats-1] - colats[0]) / (nlats-1)

; Get phi increment (in principle phi could be on an irregular grid,
; but I don't know of any examples, so the following should work)

nlongs = N_ELEMENTS(longs)
PHI_INC = (longs[nlongs-1] - longs[0]) / (nlongs-1)

; Find offset in longs and lats arrays
offi = WHERE(ABS(longs) LT 0.5*PHI_INC)
offi = offi[0]
offj = WHERE(ABS(colats) LT 0.5*V_INC)
offj = offj[0] 
; Calculate (theta, phi) coords of grid points and use to set i,j indices:
i_grid = FLTARR(nuv,nuv)
j_grid = FLTARR(nuv,nuv)
FOR k=0,nuv-1 DO BEGIN
    phi_grid  = ATAN(v[k], u)*r2d

; Fold phi values into 0 -> 2 pi:
    negs = WHERE(phi_grid LT 0d0)
    IF negs[0] NE -1 THEN phi_grid[negs] += 360d0
    i_grid[*,k] = offi + (phi_grid / PHI_INC)

    theta_grid = ASIN(SQRT(v[k]^2 + u^2))*r2d
    j_grid[*,k] = offj + (theta_grid / V_INC)
ENDFOR

; Interpolate from polar to rectangular:
grid = fltarr(nuv,nuv,4)
FOR i=0,3 DO grid[*,*,i] = $
  INTERPOLATE(map[*,*,i], i_grid, j_grid, CUBIC=-0.5, MISSING=nan)

IF verbose THEN PRINT, 'll2grid: Minimum and maximum on grid:', $
  MIN(grid,/NAN), MAX(grid,/NAN)

END 

;---------------------------------------------------------------------------
PRO ll2hp2, map, longs, colats, hparray, nside
; Program to interpolate cuts data onto a healpix map
; map:    data read from cuts file, reformated to theta,phi grid
; longs:  set of longitudes (phi)
; colats: set of colatitudes (theta)

d2r = !dpi / 180d

; Get theta increment (kludge)
nlats = N_ELEMENTS(colats)
V_INC = (colats[nlats-1] - colats[0]) / (nlats-1)

nlongs = N_ELEMENTS(longs)
PHI_INC = (longs[nlongs-1] - longs[0]) / (nlongs-1)

; get coords of HEALPix pixels:

IF N_ELEMENTS(NSIDE) EQ 0 THEN nside = 256
npix = NSIDE2NPIX(nside)    
ipix = LINDGEN(npix)
PIX2ANG_RING, nside, ipix, theta, phi
    
; convert to effective pixels in the map grid:

HP_long = (phi/d2r - longs[0]) / PHI_INC
HP_lat =  (theta/d2r - colats[0]) / V_INC

PRINT, 'Range of longitude pixel numbers for healpix grid', $
MIN(HP_long), MAX(HP_long)
PRINT, 'Range of latitude pixel numbers for healpix grid ', $
MIN(HP_lat), MAX(HP_lat)

hparray = FLTARR(npix,4,/NOZERO)

FOR i=0,3 DO BEGIN
; Interpolate onto healpix grid:
    hparray[*,i] = INTERPOLATE(map[*,*,i], HP_long, HP_lat, CUBIC=-0.5)
ENDFOR

END

;---------------------------------------------------------------------------
FUNCTION intcutmap, map, longs, colats

; Integrates the power in a cut map

; TBD: 
; * add integrating dipole

d2r = !dpi/180d

; Get theta & phi increments

nlats = N_ELEMENTS(colats)
V_INC = (colats[nlats-1] - colats[0]) / (nlats-1)

nlongs = N_ELEMENTS(longs)
PHI_INC = (longs[nlongs-1] - longs[0]) / (nlongs-1)

; Find latitude-dependent weighting of pixels

; First work out lat and longs of boundaries between pixels

tops = colats - (V_INC / 2.)
bots = colats + (V_INC / 2.)

tops[0] = tops[0] > 0.

IF MIN(tops) LT 0. THEN BEGIN
    PRINT, 'Anomalous latitude sequence, seems to contain negatives'
    GOTO, QUIT
ENDIF

bots[nlats-1] = bots[nlats-1] < 180.

IF MAX(bots) GT 180. THEN BEGIN
    PRINT, 'Anomalous latitude sequence, seems to exceed 180 degrees'
    GOTO, QUIT
ENDIF

deltas = cos(tops*d2r) - cos(bots*d2r)

; Now do integral:

intstokes = DBLARR(4)
FOR i=0,3 DO BEGIN

; Sum arrays, first in constant-theta rows, then over latitude using
; correct weighting.

; Quadrature
    sum = TOTAL(map[0:nlongs-2,*,i],1,/DOUBLE)*PHI_INC

    FOR j = 0,nlats-1 DO BEGIN
        PRINT, i,j, sum[j], $
          FORMAT = "('Stokes',i2,', row',i4,':  Direct sum = ',E11.4)"
    ENDFOR
    intstokes[i] = TOTAL(deltas*sum)
ENDFOR

RETURN, intstokes*d2r

QUIT:

END
