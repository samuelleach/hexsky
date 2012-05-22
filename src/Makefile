# To compile bin/hexsky with gcc, insert e.g. 'export ARCH=vaio'
# into your .bashrc file, then run 'make all'.

# hexsky compiles with gcc and needs the GetData (dirfile) library
# which is available from http://getdata.sourceforge.net/

# Modify this Makefile for your platform in two places. 1) Just below
# to establish path of the GetData library (other libraries are not
# currently used). 2) Further below to define your C compiler and
# compiler flags.

# Run 'make hexsky' to compile the binary.

GETDATADIR=/usr/local
ifeq ($(ARCH),spiral)
 HOME=/scratch/leach
 GETDATADIR=${HOME}/getdata/getdata_ifort
 FITSIODIR=${HOME}/cfitsio
 CHEALPIXDIR=${HOME}/Healpix/Healpix_2.01/src/C/subs
 GSLDIR=${HOME}/gsl/gsl_gcc
endif
ifeq ($(ARCH),hg1)
 HOME=/u/ap/leach/usr/local
 GETDATADIR=/planck/leach/getdata
 FITSIODIR=
 CHEALPIXDIR=
 GSLDIR=
endif
ifeq ($(ARCH),umn)
 HOME=/home/grad/bao
 GETDATADIR=${HOME}/getdata
 FITSIODIR=${HOME}/cfitsio
 CHEALPIXDIR=${HOME}/Healpix/Healpix_2.11/src/C/subs
 GSLDIR=${HOME}/gsl/gsl_gcc
endif
ifeq ($(ARCH),vaio)
 HOME=/home/leach
 GETDATADIR=/usr
 FITSIODIR=${HOME}/cfitsio
 CHEALPIXDIR=${HOME}/Healpix/Healpix_2.01/src/C/subs
 GSLDIR=${HOME}/gsl
endif
ifeq ($(ARCH),pearl)
 HOME=/home/leach
 GETDATADIR=/usr/local
 FITSIODIR=${HOME}/cfitsio
 CHEALPIXDIR=${HOME}/healpix/Healpix_2.13a/src/C/subs
 GSLDIR=${HOME}/usr
endif
ifeq ($(ARCH),sauron)
 FITSIODIR=/usr/local/cfitsio_gnu
 CHEALPIXDIR=/usr/local/healpix
 GSLDIR=/usr/local/gsl.gcc
endif
ifeq ($(ARCH),bassi)
 FITSIODIR=/usr/common/usg/cfitsio/3.03/
 CHEALPIXDIR=/project/projectdirs/cmb/modules/bassi/2.1/healpix_2.01-2.1.0/
 GSLDIR=/usr
 GETDATADIR=/project/projectdirs/cmb/modules/bassi/2.3.7/getdata_0.4.1-2.3.7/
endif
ifeq ($(ARCH),franklin)
 GETDATADIR=/project/projectdirs/cmb/modules/franklin/pgi/cmb/2.4.2/getdata_0.5.0-2.4.2/
 FITSIODIR=
 CHEALPIXDIR=
 GSLDIR=/usr
endif
ifeq ($(ARCH),carver)
 GETDATADIR=/project/projectdirs/ebex/user/leach/getdata_carver
 FITSIODIR=
 CHEALPIXDIR=
 GSLDIR=/usr
endif
ifeq ($(ARCH),euclid)
 GETDATADIR=/project/projectdirs/ebex/user/leach/euclid/getdata/
 FITSIODIR=
 CHEALPIXDIR=
 GSLDIR=/usr
endif

###################################################################
FITSIO_LIBS=-L$(FITSIODIR)/lib -lcfitsio -I$(FITSIODIR)
FITSIO_INCL=-I$(FITSIODIR)/include
CHEALPIX_LIBS=-L$(CHEALPIXDIR)/lib -lchealpix
CHEALPIX_INCL=-I$(CHEALPIXDIR)/include
GSL_LIBS=-L${GSLDIR}/lib -lgsl -lgslcblas
GSL_INCL=-I${GSLDIR}/include
GETDATA_LIBS=-L${GETDATADIR}/lib -lgetdata -lz
GETDATA_INCL=-I${GETDATADIR}/include

INCLUDE=${GSL_INCL} ${CHEALPIX_INCL} ${FITSIO_INCL} ${GETDATA_INCL}

CC=gcc
CFLAGS= ${INCLUDE} -Wall

ifeq ($(ARCH),spiral)
 CC=gcc
 CFLAGS= ${INCLUDE} -Wall
endif
ifeq ($(ARCH),hg1)
 CC=gcc
 CFLAGS= ${INCLUDE} -Wall
endif
ifeq ($(ARCH),umn)
 CC=gcc
 CFLAGS= ${INCLUDE}
endif
ifeq ($(ARCH),vaio)
 CC=gcc
 CFLAGS=  ${INCLUDE}
endif
ifeq ($(ARCH),pearl)
 CC=gcc
 CFLAGS=  ${INCLUDE}
endif
ifeq ($(ARCH),sauron)
 CC = gcc
 CFLAGS= ${INCLUDE}
endif
ifeq ($(ARCH),bassi)
 CC=xlc
 CFLAGS= -O3 -qstrict -qcpluscmt -bmaxstack:0x10000000 -bmaxdata:0x70000000 ${INCLUDE}
endif
ifeq ($(ARCH),franklin)
 CC=cc
 CFLAGS=
endif
ifeq ($(ARCH),carver)
 CC=gcc
 CFLAGS=
endif
ifeq ($(ARCH),euclid)
 CC=gcc
 CFLAGS=
endif


LIBNAME=scan

SOURCES = utilities_pointing.c ebex_scanning.c\
	ebex_focalplane.c ebex_gondola.c\
	utilities_parameters.c ebex_parameters.c\
	utilities_squarepixel.c utilities_gnuplot.c\
	pointing_library.c utilities_baselines.c\
	prandom.c reconstructErrors.c\
	myPointingRoutine.c myFocalPlane.c myUtility.c
#	conditionNumber.c utilities_fitsio.c utilities_healpix.c
#	ebex_focalplane.c ebex_gondola.c utilities_pointing.c\

OBJECTS = ${SOURCES:.c=.o}

all: hexsky

libs: lib$(LIBNAME).a lib$(LIBNAME).so

hexsky: 	hexsky_radecbeta.c $(OBJECTS)
		$(CC) $(CFLAGS) hexsky_radecbeta.c $(OBJECTS) -o ../bin/$@ -lm \
		$(GETDATA_LIBS) $(GETDATA_INCL)

hexsky2: 	hexsky_fpc.c $(OBJECTS)
		$(CC) $(CFLAGS) hexsky_fpc.c $(OBJECTS) -o ../$@ -lm

healpix_tester: healpix_tester.o utilities_healpix.o
		$(CC) $(CFLAGS) healpix_tester.o utilities_healpix.o -o ../$@ \
		-lm $(CHEALPIX_LIBS) $(FITSIO_LIBS)

lib$(LIBNAME).a:	${OBJECTS}
			ar rv $@ ${OBJECTS}; \
			ranlib $@;

lib$(LIBNAME).so:	${OBJECTS}
			$(CC) -shared -o $@ ${OBJECTS} -lm

%.o: %.c
	$(CC) $(CFLAGS) -c $*.c

clean: 
	rm -rf *.o *~ ../bin/hexsky ../healpix_tester lib$(LIBNAME).a\
	lib$(LIBNAME).so ../gmon.out ../ebex_fpdb.txt ../azel.dat
