#!/bin/bash

# Script to download some larger data files used in the hexsky library.

#Map templates:
wget http://people.sissa.it/~leach/miramare/data/dust_carlo_150ghz_512_radec.fits

#Data files need as part of astrolib.
#Need to set environment variable ASTRO_DATA to this directory.
wget http://idlastro.gsfc.nasa.gov/ftp/data/aaareadme.txt
wget http://idlastro.gsfc.nasa.gov/ftp/data/testpo.405
wget http://idlastro.gsfc.nasa.gov/ftp/data/JPLEPH.405


#PMN source catalogues
wget ftp://ftp.atnf.csiro.au/pub/data/pmn/PLAINTXT/pmne.txt
wget ftp://ftp.atnf.csiro.au/pub/data/pmn/PLAINTXT/pmnt.txt
wget ftp://ftp.atnf.csiro.au/pub/data/pmn/PLAINTXT/pmns.txt
wget ftp://ftp.atnf.csiro.au/pub/data/pmn/PLAINTXT/pmnz.txt
