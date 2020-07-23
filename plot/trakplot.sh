#!/usr/bin/ksh

# This script plot tracks of individual storms using GrADS interactive display.
# 1. Developed by Tim Marchok (timothy.marchok@noaa.gov)
# 2. Modified by Fanglin Yang (Jan 2009)
#
# USAGE:  trakplot.sh <basin>
# where basin = "al" or "ep"  (al is the default)
#

basin=${1:-al}

echo " "
echo "+++ Basin to be used is ${basin}"
echo " "

#-----------------------------------------------
chost=`echo $(hostname) |cut -c 1-1`

export exp=v16rt2  

#export gradsibmv8=/usrx/local/dev/packages/grads/2.2.0/bin/grads
#export GADDIR=/usrx/local/dev/packages/grads/2.2.0/lib          

#--works on Surge/Luna
export gradsibmv8=/usrx/local/dev/GrADS/2.0.2/bin/grads              
export GADDIR=/usrx/local/dev/GrADS/data                        
export arcdir=/gpfs/dell2/emc/modeling/noscrub/Fanglin.Yang/VRFY/hurtrack/arch
export scrdir=/gpfs/dell2/emc/modeling/noscrub/Fanglin.Yang/VRFY/hurtrack/plot

#export netdir=/stmpd2/Fanglin.Yang/track2498/prfv3rt1/
export netdir=/gpfs/dell3/stmp/Fanglin.Yang/track7083/Gonzalo/


if [ ! -d $netdir ]; then mkdir -p $netdir; fi
cd $netdir
cp -p ${scrdir}/*  .
#cp -p ${arcdir}/${exp}/*  .    

${gradsibmv8} -cl "run trakplot.gs ${LOGNAME} ${basin} ${netdir}"



