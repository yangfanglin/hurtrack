#!/bin/ksh
set -x

year=${1:-2019}
mkdir $year
cd $year ||exit 8

NHC=/gpfs/hps3/nhc/noscrub/data

#Atlantic and Eastern Pacific
adeck=$NHC/atcf-noaa/aid_nws
cp -p $adeck/aal*${year}* .
cp -p $adeck/acp*${year}* .
cp -p $adeck/aep*${year}* .

bdeck=$NHC/atcf-noaa/btk
cp -p $bdeck/bal*${year}* .
cp -p $bdeck/bcp*${year}* .
cp -p $bdeck/bep*${year}* .

#West and central Pacific:
adeck=$NHC/atcf-navy/aid
cp -p $adeck/awp*${year}.dat .

bdeck=$NHC/atcf-navy/btk
cp -p $bdeck/bwp*${year}.dat .


exit
#---------------------------------------------
#---------------------------------------------
#/com/nhc/prod/atcf has EMX data

#--final updated archive on teh web
#NHC:  ftp://ftp.nhc.noaa.gov/atcf/archive
#JTWC:  http://www.usno.navy.mil/NOOC/nmfc-ph/RSS/jtwc/best_tracks/



