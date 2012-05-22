PRO rdcard, head, name, var
; Reads data from a fits header card

ip = WHERE(STRCMP(head, name, 8))
ncard = N_ELEMENTS(ip)

CASE ncard OF
    1: READS, STRMID(head[ip],11), var
    0: PRINT, 'RDCARD: '+name+' card not found'
    ELSE: BEGIN
        PRINT, 'RDCARD: multiple ',+name+' cards found --- Using first'
        READS, STRMID(head[ip[0]],11), var
    END
ENDCASE
END

PRO polgridplot, file, maxuv, nuv, dbmax, grid

;
; Program to read and plot a GRASP data file formatted in polar grid format in
; a fits file, as stored in /lfi_dpc_test/LevelSinputs/beams/realistic/output
; 
; Input: 
;        file   contains the full filename relative to your current
;               working directory.
;        maxuv  the range of UV coords on the plotted grid is 
;               +/- maxuv
;        nuv    Number of UV pixels on each axis
;        dbmax  The plot is burnt out dbmax below the peak (but is
;        linear).
;
; Output:
;        grid   Beam interpolated onto square UV grid
;
; Requires the HEALPix IDL package to be loaded (hidl)

; Defaults:
ntheta = 10800 & nphi = 360 & maxtheta =  0.0349065850398866

; Useful constants:
twopi = 2d*!dpi
r2d   = 360d/twopi
nan   = !values.F_NAN
nothing = ''

READ_FITS_MAP, file, data, hdr, exthdr

; Find cards in header describing data:
RDCARD, exthdr, 'NTHETA  ', ntheta
RDCARD, exthdr, 'NPHI    ', nphi
RDCARD, exthdr, 'MAXTHETA', maxtheta

data = REFORM( data, nphi, ntheta)

; For convenience, rotate & transpose:
data = ROTATE(data,4)

; phi = 0 and 180 should be identical:

join = 0.5d*(data[*,0] + data[*,nphi-1])

; Add some wrapping to the array for better interpolation at phi = 0/360

data = [[data[*,nphi-10:nphi-2]], [join], [data[*,1:nphi-2]], [join], $
                                          [data[*,1:9]] ]

; theta, phi coords in data array, in case they are needed:
theta = (maxtheta*LINDGEN(ntheta) ) / (ntheta-1)
phi   = (twopi*LINDGEN(nphi)) / (nphi-1)

PRINT, 'Maximum value of theta:', maxtheta

; Set up U, V coord arrays for output grid:
u = -maxuv + LINDGEN(nuv)*(2d*maxuv)/(nuv-1)
v = u

; Calculate (theta, phi) coords of grid points and use to set i,j indices:
i_grid = FLTARR(nuv,nuv)
j_grid = FLTARR(nuv,nuv)
FOR k=0,nuv-1 DO BEGIN
    phi_grid  = ATAN(v[k], u)

; Fold phi values into 0 -> 2 pi:
    negs = WHERE(phi_grid LT 0d0)
    IF negs[0] NE -1 THEN phi_grid[negs] += twopi

    i_grid[*,k] = 9 + phi_grid * (nphi-1) / twopi

    theta_grid = ASIN(SQRT(v[k]^2 + u^2))
    j_grid[*,k] = theta_grid * (ntheta - 1) / maxtheta
ENDFOR

; Interpolate from polar to rectangular:
grid = INTERPOLATE(data, j_grid, i_grid, CUBIC=-0.5, MISSING=nan)

PRINT, 'Minimum and maximum on grid:', minmax(grid,/NAN)

; Plot on TV:
TV, 255*10^(0.1*dbmax)*grid^2/max(grid^2, /NAN), 0, /NAN
END
